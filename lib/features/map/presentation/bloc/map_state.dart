import 'package:maplibre_gl/maplibre_gl.dart';

sealed class MapState {
  const MapState();
}

final class MapLoadingState extends MapState {
  const MapLoadingState();
}

final class MapErrorState extends MapState {
  final String message;
  final String? details;
  const MapErrorState(this.message, [this.details]);
}

final class MapLoadedState extends MapState {
  final String query;
  final String activeCategory;
  final List<Map<String, dynamic>> merchants;
  final Map<String, dynamic>? selectedMerchant;
  final LatLng? userLocation;
  final String? offersError;
  final String? locationError;
  final bool locationPermissionGranted;
  final bool locationServicesEnabled;
  final int locationRevision;
  final LatLng? browseLocation;
  final String? browseLocationLabel;
  final double radiusKm;
  final double minimumRating;
  final bool onlyOpenNow;
  final bool isLoadingOffers;

  const MapLoadedState({
    required this.query,
    required this.activeCategory,
    required this.merchants,
    this.selectedMerchant,
    this.userLocation,
    this.offersError,
    this.locationError,
    this.locationPermissionGranted = false,
    this.locationServicesEnabled = true,
    this.locationRevision = 0,
    this.browseLocation,
    this.browseLocationLabel,
    this.radiusKm = 20,
    this.minimumRating = 0,
    this.onlyOpenNow = false,
    this.isLoadingOffers = false,
  });

  MapLoadedState copyWith({
    String? query,
    String? activeCategory,
    List<Map<String, dynamic>>? merchants,
    Map<String, dynamic>? selectedMerchant,
    bool? clearSelected,
    LatLng? userLocation,
    bool clearUserLocation = false,
    String? offersError,
    bool clearOffersError = false,
    String? locationError,
    bool clearLocationError = false,
    bool? locationPermissionGranted,
    bool? locationServicesEnabled,
    int? locationRevision,
    LatLng? browseLocation,
    bool clearBrowseLocation = false,
    String? browseLocationLabel,
    bool clearBrowseLocationLabel = false,
    double? radiusKm,
    double? minimumRating,
    bool? onlyOpenNow,
    bool? isLoadingOffers,
  }) {
    return MapLoadedState(
      query: query ?? this.query,
      activeCategory: activeCategory ?? this.activeCategory,
      merchants: merchants ?? this.merchants,
      selectedMerchant: clearSelected == true
          ? null
          : (selectedMerchant ?? this.selectedMerchant),
      userLocation: clearUserLocation
          ? null
          : (userLocation ?? this.userLocation),
      offersError: clearOffersError ? null : (offersError ?? this.offersError),
      locationError: clearLocationError
          ? null
          : (locationError ?? this.locationError),
      locationPermissionGranted:
          locationPermissionGranted ?? this.locationPermissionGranted,
      locationServicesEnabled:
          locationServicesEnabled ?? this.locationServicesEnabled,
      locationRevision: locationRevision ?? this.locationRevision,
      browseLocation: clearBrowseLocation
          ? null
          : (browseLocation ?? this.browseLocation),
      browseLocationLabel: clearBrowseLocationLabel
          ? null
          : (browseLocationLabel ?? this.browseLocationLabel),
      radiusKm: radiusKm ?? this.radiusKm,
      minimumRating: minimumRating ?? this.minimumRating,
      onlyOpenNow: onlyOpenNow ?? this.onlyOpenNow,
      isLoadingOffers: isLoadingOffers ?? this.isLoadingOffers,
    );
  }
}
