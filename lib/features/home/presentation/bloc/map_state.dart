import 'package:latlong2/latlong.dart';

sealed class MapState {
  const MapState();
}

final class MapLoadingState extends MapState {
  const MapLoadingState();
}

final class MapErrorState extends MapState {
  final String message;
  const MapErrorState(this.message);
}

final class MapLoadedState extends MapState {
  final String query;
  final String activeCategory;
  final List<Map<String, dynamic>> merchants;
  final Map<String, dynamic>? selectedMerchant;
  final LatLng? userLocation;

  const MapLoadedState({
    required this.query,
    required this.activeCategory,
    required this.merchants,
    this.selectedMerchant,
    this.userLocation,
  });

  MapLoadedState copyWith({
    String? query,
    String? activeCategory,
    List<Map<String, dynamic>>? merchants,
    Map<String, dynamic>? selectedMerchant,
    bool clearSelected = false,
    LatLng? userLocation,
  }) {
    return MapLoadedState(
      query: query ?? this.query,
      activeCategory: activeCategory ?? this.activeCategory,
      merchants: merchants ?? this.merchants,
      selectedMerchant: clearSelected ? null : (selectedMerchant ?? this.selectedMerchant),
      userLocation: userLocation ?? this.userLocation,
    );
  }
}
