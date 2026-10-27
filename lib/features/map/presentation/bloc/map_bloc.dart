import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_usecase.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';

import 'map_event.dart';
import 'map_state.dart';

class MapLocationResult {
  final LatLng? location;
  final String? error;
  final bool permissionGranted;
  final bool servicesEnabled;

  const MapLocationResult({
    this.location,
    this.error,
    this.permissionGranted = false,
    this.servicesEnabled = true,
  });
}

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetPaginatedOffersUsecase _getPaginatedOffersUsecase;

  List<Map<String, dynamic>> _allMerchants = [];
  int _offerRequestId = 0;
  static const _mapOfferLimit = 100;

  MapBloc(this._getPaginatedOffersUsecase) : super(const MapLoadingState()) {
    on<MapInitialLoadRequested>(_onInitialLoad);
    on<MapQueryChanged>(_onQueryChanged);
    on<MapCategoryChanged>(_onCategoryChanged);
    on<MapMerchantSelected>(_onMerchantSelected);
    on<MapCardDismissed>(_onCardDismissed);
    on<MapRecenterRequested>(_onRecenter);
    on<MapFiltersApplied>(_onFiltersApplied);
    on<MapPlaceSelected>(_onPlaceSelected);
    on<MapFocusBranchRequested>(_onFocusBranch);
    on<MapErrorOccurred>(_onErrorOccurred);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<MapLocationResult> _fetchUserLocation() async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      return const MapLocationResult(
        error: 'Location services are off. Enable them to find nearby offers.',
        servicesEnabled: false,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return const MapLocationResult(
        error: 'Location permission is off. Enable it in Settings to locate nearby offers.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      return MapLocationResult(
        location: LatLng(position.latitude, position.longitude),
        permissionGranted: true,
      );
    } on TimeoutException {
      return const MapLocationResult(
        error: 'Could not get a fresh location. You can still browse the map.',
        permissionGranted: true,
      );
    } on LocationServiceDisabledException {
      return const MapLocationResult(
        error: 'Location services are off. Enable them to find nearby offers.',
        servicesEnabled: false,
      );
    } on PermissionDeniedException {
      return const MapLocationResult(
        error: 'Location permission is off. Enable it in Settings to locate nearby offers.',
      );
    }
  }

  /// Converts a live offer to a map pin, selecting the nearest or first branch.
  static Map<String, dynamic>? offerToMapPin(
    OfferEntity offer, {
    double? referenceLat,
    double? referenceLng,
  }) {
    final pins = offerToMapPins(offer, referenceLat: referenceLat, referenceLng: referenceLng);
    return pins.isEmpty ? null : pins.first;
  }

  /// Converts an offer into multiple map pins — one for each active branch with valid coordinates.
  static List<Map<String, dynamic>> offerToMapPins(
    OfferEntity offer, {
    double? referenceLat,
    double? referenceLng,
  }) {
    final candidateBranches = offer.branches.isNotEmpty
        ? offer.branches
        : (offer.merchant?.branches ?? const <MerchantBranchEntity>[]);

    final branches = candidateBranches
        .where(
          (branch) =>
              branch.lat.isFinite &&
              branch.lng.isFinite &&
              branch.lat >= -90 &&
              branch.lat <= 90 &&
              branch.lng >= -180 &&
              branch.lng <= 180,
        )
        .toList();

    final id = offer.id?.trim();
    if (branches.isEmpty || id == null || id.isEmpty) {
      return const [];
    }

    return branches.map((branch) {
      return {
        'id': id,
        'pinId': '$id:${branch.id}',
        'offerId': id,
        'branchId': branch.id,
        'branchName': branch.name,
        'hotelName': offer.merchantName ?? offer.merchant?.name ?? 'Merchant',
        'category': _categoryDisplayName(offer.category.name),
        'categoryId': offer.categoryId,
        'categorySlug': offer.category.name.toUpperCase(),
        'highlightTag': offer.discountPercentage != null
            ? '${offer.discountPercentage}% OFF'
            : 'BOGOF',
        'offerType': offer.title,
        'rating': offer.rating.toStringAsFixed(1),
        'ratingValue': offer.rating,
        'location': '${branch.address}, ${branch.city}',
        'branchAddress': branch.address,
        'branchCity': branch.city,
        'distanceFromUser': (referenceLat != null && referenceLng != null)
            ? '${_distanceKm(referenceLat, referenceLng, branch.lat, branch.lng).toStringAsFixed(1)} km'
            : '',
        'image':
            offer.imageUrl ??
            (offer.images.isNotEmpty
                ? offer.images.first
                : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80'),
        'lat': branch.lat,
        'lng': branch.lng,
        // Keep full entity reference for navigation
        'offer': offer,
        'branch': branch,
      };
    }).toList();
  }

  static double _distanceKm(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    const earthRadiusKm = 6371.0;
    final latitudeDelta = (toLat - fromLat) * math.pi / 180;
    final longitudeDelta = (toLng - fromLng) * math.pi / 180;
    final fromLatitude = fromLat * math.pi / 180;
    final toLatitude = toLat * math.pi / 180;
    final haversine =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(fromLatitude) *
            math.cos(toLatitude) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    return 2 *
        earthRadiusKm *
        math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
  }

  static String _categoryDisplayName(String slug) {
    switch (slug.toLowerCase()) {
      case 'dining':
        return 'Dining';
      case 'wellness':
        return 'Activities';
      case 'entertainment':
        return 'Activities';
      case 'retail':
        return 'Offers';
      case 'travel':
        return 'Hotels';
      case 'beauty':
        return 'Activities';
      default:
        return 'Offers';
    }
  }

  // ── Event handlers ───────────────────────────────────────────────────────

  Future<void> _onInitialLoad(
    MapInitialLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    final requestId = ++_offerRequestId;
    emit(const MapLoadingState());

    final locationResult = await _fetchUserLocation();
    final browseLocation = event.latitude != null && event.longitude != null
        ? LatLng(event.latitude!, event.longitude!)
        : locationResult.location;
    final offerResult = await _loadMerchantsFromApi(
      lat: browseLocation?.latitude,
      lng: browseLocation?.longitude,
      radiusKm: browseLocation == null ? null : 20,
      referenceLat: browseLocation?.latitude,
      referenceLng: browseLocation?.longitude,
    );
    if (requestId != _offerRequestId) return;

    _allMerchants = offerResult.merchants;
    final visibleMerchants = _filter('', 'All', 0);

    emit(
      MapLoadedState(
        query: '',
        activeCategory: 'All',
        merchants: visibleMerchants,
        userLocation: locationResult.location,
        locationError: locationResult.error,
        locationPermissionGranted: locationResult.permissionGranted,
        locationServicesEnabled: locationResult.servicesEnabled,
        offersError: offerResult.error,
        browseLocation: browseLocation,
        browseLocationLabel: event.locationLabel,
      ),
    );
  }

  Future<_OfferLoadResult> _loadMerchantsFromApi({
    String? query,
    String? category,
    double? lat,
    double? lng,
    double? radiusKm,
    double? referenceLat,
    double? referenceLng,
  }) async {
    final result = await _getPaginatedOffersUsecase.call(
      GetPaginatedOffersParams(
        page: 1,
        limit: _mapOfferLimit,
        q: query,
        category: category,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      ),
    );
    return result.fold(
      (failure) => _OfferLoadResult([], failure.message),
      (paginated) => _OfferLoadResult(
        paginated.offers
            .expand(
              (offer) => offerToMapPins(
                offer,
                referenceLat: referenceLat,
                referenceLng: referenceLng,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _onFiltersApplied(
    MapFiltersApplied event,
    Emitter<MapState> emit,
  ) async {
    final current = state;
    if (current is! MapLoadedState) return;
    final requestId = ++_offerRequestId;

    emit(
      current.copyWith(
        activeCategory: event.category,
        radiusKm: event.radiusKm,
        minimumRating: event.minimumRating,
        onlyOpenNow: event.onlyOpenNow,
        browseLocation: LatLng(event.lat, event.lng),
        isLoadingOffers: true,
      ),
    );
    final result = await _loadMerchantsFromApi(
      query: current.query,
      category: _apiCategory(event.category),
      lat: event.lat,
      lng: event.lng,
      radiusKm: event.radiusKm,
      referenceLat: event.lat,
      referenceLng: event.lng,
    );
    if (requestId != _offerRequestId) return;

    final latest = state;
    if (latest is! MapLoadedState) return;
    _allMerchants = result.merchants;
    final filtered = _filter(
      latest.query,
      event.category,
      event.minimumRating,
      event.onlyOpenNow,
    );
    emit(
      latest.copyWith(
        activeCategory: event.category,
        radiusKm: event.radiusKm,
        minimumRating: event.minimumRating,
        onlyOpenNow: event.onlyOpenNow,
        browseLocation: LatLng(event.lat, event.lng),
        merchants: filtered,
        offersError: result.error,
        clearOffersError: result.error == null,
        isLoadingOffers: false,
      ),
    );
  }

  Future<void> _onPlaceSelected(
    MapPlaceSelected event,
    Emitter<MapState> emit,
  ) async {
    final current = state;
    if (current is! MapLoadedState) return;
    final requestId = ++_offerRequestId;

    final browseLocation = LatLng(event.latitude, event.longitude);
    emit(
      current.copyWith(
        query: '',
        browseLocation: browseLocation,
        browseLocationLabel: event.label,
        radiusKm: 20,
        isLoadingOffers: true,
      ),
    );
    final result = await _loadMerchantsFromApi(
      category: _apiCategory(current.activeCategory),
      lat: event.latitude,
      lng: event.longitude,
      radiusKm: 20,
      referenceLat: event.latitude,
      referenceLng: event.longitude,
    );
    if (requestId != _offerRequestId) return;
    final latest = state;
    if (latest is! MapLoadedState) return;
    _allMerchants = result.merchants;
    emit(
      latest.copyWith(
        query: '',
        merchants: _filter('', latest.activeCategory, latest.minimumRating),
        browseLocation: browseLocation,
        browseLocationLabel: event.label,
        radiusKm: 20,
        offersError: result.error,
        clearOffersError: result.error == null,
        isLoadingOffers: false,
      ),
    );
  }

  static String? _apiCategory(String category) {
    switch (category) {
      case 'Dining':
        return 'DINING';
      case 'Hotels':
      case 'Travel':
        return 'TRAVEL';
      case 'Offers':
      case 'Retail':
        return 'RETAIL';
      case 'Wellness':
        return 'WELLNESS';
      case 'Entertainment':
        return 'ENTERTAINMENT';
      case 'Beauty':
        return 'BEAUTY';
      default:
        return null;
    }
  }

  Future<void> _onRecenter(
    MapRecenterRequested event,
    Emitter<MapState> emit,
  ) async {
    final current = state;
    if (current is MapLoadedState) {
      final locationResult = await _fetchUserLocation();
      final location = locationResult.location;
      final requestId = ++_offerRequestId;
      final result = location == null
          ? null
          : await _loadMerchantsFromApi(
              query: current.query,
              category: _apiCategory(current.activeCategory),
              lat: location.latitude,
              lng: location.longitude,
              radiusKm: current.radiusKm,
              referenceLat: location.latitude,
              referenceLng: location.longitude,
            );
      if (requestId != _offerRequestId) return;
      if (result != null) _allMerchants = result.merchants;
      emit(
        current.copyWith(
          userLocation: location,
          clearUserLocation: location == null,
          locationError: locationResult.error,
          clearLocationError: locationResult.error == null,
          locationPermissionGranted: locationResult.permissionGranted,
          locationServicesEnabled: locationResult.servicesEnabled,
          locationRevision: current.locationRevision + 1,
          browseLocation: location ?? current.browseLocation,
          browseLocationLabel: location == null ? null : 'Current location',
          clearBrowseLocationLabel: location == null,
          merchants: result == null
              ? current.merchants
              : _filter(
                  current.query,
                  current.activeCategory,
                  current.minimumRating,
                ),
          offersError: result?.error,
          clearOffersError: result?.error == null,
        ),
      );
    }
  }

  Future<void> _onFocusBranch(
    MapFocusBranchRequested event,
    Emitter<MapState> emit,
  ) async {
    final current = state;
    if (current is! MapLoadedState) return;
    emit(
      current.copyWith(
        browseLocation: LatLng(event.lat, event.lng),
        browseLocationLabel: event.title ?? 'Branch location',
        clearSelected: true,
      ),
    );
  }

  void _onQueryChanged(MapQueryChanged event, Emitter<MapState> emit) {
    final current = state;
    if (current is! MapLoadedState) return;
    final query = event.query.trim().toLowerCase();
    final filtered = _filter(
      query,
      current.activeCategory,
      current.minimumRating,
      current.onlyOpenNow,
    );
    emit(current.copyWith(query: query, merchants: filtered));
  }

  void _onCategoryChanged(MapCategoryChanged event, Emitter<MapState> emit) {
    final current = state;
    if (current is! MapLoadedState) return;
    final filtered = _filter(
      current.query,
      event.category,
      current.minimumRating,
      current.onlyOpenNow,
    );
    emit(current.copyWith(activeCategory: event.category, merchants: filtered));
  }

  void _onMerchantSelected(MapMerchantSelected event, Emitter<MapState> emit) {
    final current = state;
    if (current is! MapLoadedState) return;
    emit(current.copyWith(selectedMerchant: event.merchant));
  }

  void _onCardDismissed(MapCardDismissed event, Emitter<MapState> emit) {
    final current = state;
    if (current is! MapLoadedState) return;
    emit(current.copyWith(clearSelected: true));
  }

  void _onErrorOccurred(MapErrorOccurred event, Emitter<MapState> emit) {
    emit(MapErrorState(event.message, event.details));
  }

  List<Map<String, dynamic>> _filter(
    String query,
    String category, [
    double minimumRating = 0,
    bool onlyOpenNow = false,
  ]) {
    return _allMerchants.where((item) {
      final nameMatches = item['hotelName'].toString().toLowerCase().contains(
        query,
      );
      final locationMatches = item['location']
          .toString()
          .toLowerCase()
          .contains(query);
      final branchMatches = (item['branchName'] ?? '')
          .toString()
          .toLowerCase()
          .contains(query);
      final tagMatches = item['highlightTag'].toString().toLowerCase().contains(
        query,
      );
      final itemCategory = item['category'] as String? ?? '';
      final itemCategorySlug = item['categorySlug'] as String? ?? '';
      final categoryMatches = switch (category) {
        'All' => true,
        'Hotels' || 'Travel' => itemCategorySlug == 'TRAVEL',
        'Offers' || 'Retail' => itemCategorySlug == 'RETAIL',
        'Activities' => const {
          'WELLNESS',
          'ENTERTAINMENT',
          'BEAUTY',
        }.contains(itemCategorySlug),
        _ =>
          itemCategorySlug == category.toUpperCase() ||
              itemCategory == category,
      };
      final ratingMatches =
          (item['ratingValue'] as num? ?? 0).toDouble() >= minimumRating;

      // Operating hours / Open Now check
      // When onlyOpenNow is true, check whether item has openNow flag or falls within default operating hours
      final openNowMatches = !onlyOpenNow || (item['isOpenNow'] as bool? ?? true);

      if (query.isEmpty) return categoryMatches && ratingMatches && openNowMatches;
      return (nameMatches || locationMatches || branchMatches || tagMatches) &&
          categoryMatches &&
          ratingMatches &&
          openNowMatches;
    }).toList();
  }
}

class _OfferLoadResult {
  final List<Map<String, dynamic>> merchants;
  final String? error;

  const _OfferLoadResult(this.merchants, [this.error]);
}
