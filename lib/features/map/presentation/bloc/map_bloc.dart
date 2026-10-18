import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_usecase.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';
import 'map_event.dart';
import 'map_state.dart';

/// Fallback demo merchants used when API returns no data
const List<Map<String, dynamic>> _demoMerchants = [
  {
    'id': 'demo-m1',
    'hotelName': 'Tribes Restaurant & Grill',
    'category': 'Dining',
    'highlightTag': 'BOGOF',
    'offerType': 'Buy 1 Get 1 Main Course',
    'rating': '4.9',
    'location': 'Durbar Marg, Kathmandu',
    'distanceFromUser': '0.8 km',
    'image': 'https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
    'latitude': 27.7172,
    'longitude': 85.3240,
  },
  {
    'id': 'demo-m2',
    'hotelName': 'Grand Horizon Luxury Resort',
    'category': 'Hotels',
    'highlightTag': 'Staycation',
    'offerType': 'Buy 1 Night Get 1 Free',
    'rating': '4.9',
    'location': 'Lazimpat, Kathmandu',
    'distanceFromUser': '3.8 km',
    'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80',
    'latitude': 27.7280,
    'longitude': 85.3400,
  },
];

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetPaginatedOffersUsecase _getPaginatedOffersUsecase;

  List<Map<String, dynamic>> _allMerchants = [];

  MapBloc(this._getPaginatedOffersUsecase) : super(const MapLoadingState()) {
    on<MapInitialLoadRequested>(_onInitialLoad);
    on<MapQueryChanged>(_onQueryChanged);
    on<MapCategoryChanged>(_onCategoryChanged);
    on<MapMerchantSelected>(_onMerchantSelected);
    on<MapCardDismissed>(_onCardDismissed);
    on<MapRecenterRequested>(_onRecenter);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<LatLng> _fetchUserLocation() async {
    const defaultLocation = LatLng(27.7172, 85.3240);
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) return defaultLocation;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return defaultLocation;
      }

      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return LatLng(lastKnown.latitude, lastKnown.longitude);
        }
      } catch (_) {}

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      ).timeout(
        const Duration(seconds: 4),
        onTimeout: () => throw Exception('Location fetch timed out'),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return defaultLocation;
    }
  }

  /// Convert an [OfferEntity] to the map-pin data map.
  /// Uses the first branch lat/lng if available, else drops the pin at
  /// the default Kathmandu centre with a small random scatter.
  static Map<String, dynamic> _offerToMapPin(OfferEntity offer, int index) {
    final branch = offer.merchant?.branches.isNotEmpty == true
        ? offer.merchant!.branches.first
        : null;
    final double lat = (branch?.lat ?? 0.0) != 0.0
        ? branch!.lat
        : 27.7172 + (index % 5) * 0.008 - 0.016;
    final double lng = (branch?.lng ?? 0.0) != 0.0
        ? branch!.lng
        : 85.3240 + (index % 7) * 0.007 - 0.021;

    final categoryStr = offer.merchant?.branches.isNotEmpty == true
        ? offer.category.name
        : offer.category.name;

    return {
      'id': offer.id ?? 'map-$index',
      'hotelName': offer.merchantName ?? offer.merchant?.name ?? 'Merchant',
      'category': _categoryDisplayName(categoryStr),
      'highlightTag': offer.discountPercentage != null
          ? '${offer.discountPercentage}% OFF'
          : 'BOGOF',
      'offerType': offer.title,
      'rating': offer.rating.toStringAsFixed(1),
      'location': branch != null
          ? '${branch.address}, ${branch.city}'
          : 'Kathmandu, Nepal',
      'distanceFromUser': '${(0.5 + index * 0.4).toStringAsFixed(1)} km',
      'image': offer.imageUrl ??
          (offer.images.isNotEmpty
              ? offer.images.first
              : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80'),
      'latitude': lat,
      'longitude': lng,
      // Keep full entity reference for navigation
      'offer': offer,
    };
  }

  static String _categoryDisplayName(String slug) {
    switch (slug.toLowerCase()) {
      case 'dining': return 'Dining';
      case 'wellness': return 'Activities';
      case 'entertainment': return 'Activities';
      case 'retail': return 'Offers';
      case 'travel': return 'Hotels';
      case 'beauty': return 'Activities';
      default: return 'Offers';
    }
  }

  // ── Event handlers ───────────────────────────────────────────────────────

  Future<void> _onInitialLoad(
    MapInitialLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoadingState());

    // Fetch user location and API data concurrently
    final results = await Future.wait([
      _fetchUserLocation(),
      _loadMerchantsFromApi(),
    ]);

    final userLocation = results[0] as LatLng;
    final merchants = results[1] as List<Map<String, dynamic>>;

    _allMerchants = merchants;

    emit(MapLoadedState(
      query: '',
      activeCategory: 'All',
      merchants: _allMerchants,
      selectedMerchant:
          _allMerchants.isNotEmpty ? _allMerchants.first : null,
      userLocation: userLocation,
    ));
  }

  Future<List<Map<String, dynamic>>> _loadMerchantsFromApi() async {
    try {
      final result = await _getPaginatedOffersUsecase.call(
        const GetPaginatedOffersParams(page: 1, limit: 50),
      );
      return await result.fold(
        (_) => List<Map<String, dynamic>>.from(_demoMerchants),
        (paginated) {
          if (paginated.offers.isEmpty) {
            return List<Map<String, dynamic>>.from(_demoMerchants);
          }
          return paginated.offers
              .asMap()
              .entries
              .map((e) => _offerToMapPin(e.value, e.key))
              .toList();
        },
      );
    } catch (_) {
      return List<Map<String, dynamic>>.from(_demoMerchants);
    }
  }

  Future<void> _onRecenter(
    MapRecenterRequested event,
    Emitter<MapState> emit,
  ) async {
    final current = state;
    if (current is MapLoadedState) {
      final userLocation = await _fetchUserLocation();
      emit(current.copyWith(userLocation: userLocation));
    }
  }

  void _onQueryChanged(MapQueryChanged event, Emitter<MapState> emit) {
    final current = state;
    if (current is! MapLoadedState) return;
    final query = event.query.trim().toLowerCase();
    final filtered = _filter(query, current.activeCategory);
    emit(current.copyWith(
      query: query,
      merchants: filtered,
      selectedMerchant: filtered.isNotEmpty ? filtered.first : null,
      clearSelected: filtered.isEmpty,
    ));
  }

  void _onCategoryChanged(MapCategoryChanged event, Emitter<MapState> emit) {
    final current = state;
    if (current is! MapLoadedState) return;
    final filtered = _filter(current.query, event.category);
    emit(current.copyWith(
      activeCategory: event.category,
      merchants: filtered,
      selectedMerchant: filtered.isNotEmpty ? filtered.first : null,
      clearSelected: filtered.isEmpty,
    ));
  }

  void _onMerchantSelected(
      MapMerchantSelected event, Emitter<MapState> emit) {
    final current = state;
    if (current is! MapLoadedState) return;
    emit(current.copyWith(selectedMerchant: event.merchant));
  }

  void _onCardDismissed(MapCardDismissed event, Emitter<MapState> emit) {
    final current = state;
    if (current is! MapLoadedState) return;
    emit(current.copyWith(clearSelected: true));
  }

  List<Map<String, dynamic>> _filter(String query, String category) {
    return _allMerchants.where((item) {
      final nameMatches =
          item['hotelName'].toString().toLowerCase().contains(query);
      final locationMatches =
          item['location'].toString().toLowerCase().contains(query);
      final tagMatches =
          item['highlightTag'].toString().toLowerCase().contains(query);
      final categoryMatches =
          category == 'All' || item['category'] == category;
      if (query.isEmpty) return categoryMatches;
      return (nameMatches || locationMatches || tagMatches) && categoryMatches;
    }).toList();
  }
}
