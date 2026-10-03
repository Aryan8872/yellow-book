import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  static final List<Map<String, dynamic>> _allMerchants = [
    {
      "id": "m1",
      "hotelName": "Tribes Restaurant & Grill",
      "category": "Dining",
      "highlightTag": "BOGOF",
      "offerType": "Buy 1 Get 1 Main Course",
      "rating": "4.9",
      "location": "The Dubai Mall, Downtown",
      "distanceFromUser": "0.8 km",
      "image": "https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80",
      "latitude": 27.7172,
      "longitude": 85.3240,
    },
    {
      "id": "m2",
      "hotelName": "Green Bowl Organic Salads",
      "category": "Dining",
      "highlightTag": "Healthy",
      "offerType": "Buy 1 Get 1 Salad Bowl",
      "rating": "4.8",
      "location": "Kathmandu Central Hub",
      "distanceFromUser": "1.4 km",
      "image": "https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/01/12/12/healthy-avo-food.jpg",
      "latitude": 27.7125,
      "longitude": 85.3180,
    },
    {
      "id": "m3",
      "hotelName": "Grand Horizon Luxury Resort",
      "category": "Hotels",
      "highlightTag": "Staycation",
      "offerType": "Buy 1 Night Get 1 Free",
      "rating": "4.9",
      "location": "Hilltop Serenity Heights",
      "distanceFromUser": "3.8 km",
      "image": "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80",
      "latitude": 27.7280,
      "longitude": 85.3400,
    },
    {
      "id": "m4",
      "hotelName": "Himalayan Java Coffee",
      "category": "Offers",
      "highlightTag": "Coffee",
      "offerType": "Buy 1 Get 1 Espresso Drink",
      "rating": "4.9",
      "location": "Durbar Marg Boulevard",
      "distanceFromUser": "0.5 km",
      "image": "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=600&q=80",
      "latitude": 27.7100,
      "longitude": 85.3210,
    },
    {
      "id": "m5",
      "hotelName": "Serene Valley Spa & Wellness",
      "category": "Activities",
      "highlightTag": "Spa",
      "offerType": "Buy 1 Get 1 Full Body Massage",
      "rating": "4.8",
      "location": "Lakeside Relaxation Bay",
      "distanceFromUser": "2.2 km",
      "image": "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=600&q=80",
      "latitude": 27.7050,
      "longitude": 85.3350,
    },
  ];

  MapBloc() : super(const MapLoadingState()) {
    on<MapInitialLoadRequested>(_onInitialLoad);
    on<MapQueryChanged>(_onQueryChanged);
    on<MapCategoryChanged>(_onCategoryChanged);
    on<MapMerchantSelected>(_onMerchantSelected);
    on<MapCardDismissed>(_onCardDismissed);
    on<MapRecenterRequested>(_onRecenter);
  }

  Future<LatLng> _fetchUserLocation() async {
    const defaultLocation = LatLng(27.7172, 85.3240);

    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return defaultLocation;
      }

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

  Future<void> _onInitialLoad(
    MapInitialLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoadingState());
    final userLocation = await _fetchUserLocation();
    emit(MapLoadedState(
      query: '',
      activeCategory: 'All',
      merchants: _allMerchants,
      selectedMerchant: _allMerchants.first,
      userLocation: userLocation,
    ));
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

  List<Map<String, dynamic>> _filter(String query, String category) {
    return _allMerchants.where((item) {
      final nameMatches = item["hotelName"].toString().toLowerCase().contains(query);
      final locationMatches = item["location"].toString().toLowerCase().contains(query);
      final tagMatches = item["highlightTag"].toString().toLowerCase().contains(query);
      final categoryMatches = category == 'All' || item["category"] == category;
      if (query.isEmpty) return categoryMatches;
      return (nameMatches || locationMatches || tagMatches) && categoryMatches;
    }).toList();
  }
}
