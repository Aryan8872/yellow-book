import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:entertainer/core/config/map_config.dart';
import 'package:entertainer/features/map/presentation/bloc/map_bloc.dart';
import 'package:entertainer/features/map/presentation/bloc/map_event.dart';
import 'package:entertainer/features/map/presentation/bloc/map_state.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'package:entertainer/features/map/presentation/widgets/category_map_marker_factory.dart';
import 'package:entertainer/features/map/presentation/widgets/offer_map_clusterer.dart';
import 'package:entertainer/features/map/presentation/widgets/offer_map_drawer.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_usecase.dart';

class _MockGetPaginatedOffersUsecase extends Mock
    implements GetPaginatedOffersUsecase {}

class _FakeGetPaginatedOffersParams extends Fake
    implements GetPaginatedOffersParams {}

class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  bool servicesEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission requestedPermission = LocationPermission.whileInUse;
  Position? position = _position(27.72, 85.33);
  Object? positionError;
  int currentPositionCalls = 0;
  int lastKnownPositionCalls = 0;
  int permissionRequestCalls = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => servicesEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    permissionRequestCalls++;
    return requestedPermission;
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async {
    lastKnownPositionCalls++;
    return position;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    currentPositionCalls++;
    if (positionError != null) throw positionError!;
    return position!;
  }
}

void main() {
  late _FakeGeolocatorPlatform locationPlatform;
  late _MockGetPaginatedOffersUsecase usecase;
  late GeolocatorPlatform originalPlatform;

  setUpAll(() {
    registerFallbackValue(_FakeGetPaginatedOffersParams());
  });

  setUp(() {
    originalPlatform = GeolocatorPlatform.instance;
    locationPlatform = _FakeGeolocatorPlatform();
    GeolocatorPlatform.instance = locationPlatform;
    usecase = _MockGetPaginatedOffersUsecase();
    when(() => usecase.call(any())).thenAnswer(
      (_) async => Right(
        PaginatedOfferEntity(
          offers: [_offer()],
          count: 1,
          total: 1,
        ),
      ),
    );
  });

  tearDown(() {
    GeolocatorPlatform.instance = originalPlatform;
  });

  test('generates six distinct category marker images in memory', () async {
    final images = await Future.wait(
      CategoryMapMarkerFactory.categorySlugs.map(
        CategoryMapMarkerFactory.renderCategoryMarker,
      ),
    );

    expect(CategoryMapMarkerFactory.categorySlugs, hasLength(6));
    expect(
      CategoryMapMarkerFactory.categorySlugs
          .map(CategoryMapMarkerFactory.imageIdFor)
          .toList(),
      [
        'offer-pin-dining',
        'offer-pin-wellness',
        'offer-pin-entertainment',
        'offer-pin-retail',
        'offer-pin-travel',
        'offer-pin-beauty',
      ],
    );
    expect(images.every((image) => image.length > 8), isTrue);
    expect(images.map(base64Encode).toSet(), hasLength(6));
  });

  test('clusters nearby offers at lower zoom and separates them when zoomed in', () {
    final pins = [
      _pin('a', 27.7200, 85.3300),
      _pin('b', 27.7210, 85.3300),
      _pin('c', 27.7200, 85.3500),
    ];

    final zoomedOut = OfferMapClusterer.cluster(pins, zoom: 12);
    final zoomedIn = OfferMapClusterer.cluster(pins, zoom: 16);

    expect(zoomedOut.where((cluster) => cluster.isCluster), hasLength(1));
    expect(
      zoomedOut.firstWhere((cluster) => cluster.isCluster).offers,
      hasLength(2),
    );
    expect(zoomedIn, hasLength(3));
    expect(OfferMapClusterer.zoomForCluster(12), 14);
  });

  test('keeps a single offer geographically anchored at its exact coordinates', () {
    final cluster = OfferMapClusterer.cluster(
      [_pin('single', 27.72, 85.33)],
      zoom: 14,
    ).single;

    expect(cluster.isCluster, isFalse);
    expect(cluster.latitude, closeTo(27.72, 1e-6));
    expect(cluster.longitude, closeTo(85.33, 1e-6));
    expect(cluster.offers.single['id'], 'single');
  });

  test('initial camera uses a fresh fix or falls back to the Nepal overview', () {
    const noLocation = MapLoadedState(
      query: '',
      activeCategory: 'All',
      merchants: [],
    );
    const freshLocation = MapLoadedState(
      query: '',
      activeCategory: 'All',
      merchants: [],
      userLocation: LatLng(28.2, 83.9),
    );

    final fallback = MapDiscoveryPage.initialCameraTarget(noLocation, null);
    final located = MapDiscoveryPage.initialCameraTarget(freshLocation, null);
    final branch = MapDiscoveryPage.initialCameraTarget(
      freshLocation,
      (lat: 27.5, lng: 85.2, title: 'Branch'),
    );

    expect(fallback.latitude, closeTo(MapConfig.defaultLatitude, 1e-6));
    expect(fallback.longitude, closeTo(MapConfig.defaultLongitude, 1e-6));
    expect(located.latitude, closeTo(28.2, 1e-6));
    expect(located.longitude, closeTo(83.9, 1e-6));
    expect(branch.latitude, closeTo(27.5, 1e-6));
    expect(branch.longitude, closeTo(85.2, 1e-6));
  });

  test('uses a fresh GPS fix and never asks for a cached position', () async {
    locationPlatform.position = _position(28.2, 83.9);
    final state = await _loadMap(usecase);

    expect(state.userLocation?.latitude, 28.2);
    expect(state.userLocation?.longitude, closeTo(83.9, 1e-6));
    expect(state.locationPermissionGranted, isTrue);
    expect(locationPlatform.currentPositionCalls, 1);
    expect(locationPlatform.lastKnownPositionCalls, 0);
  });

  test('keeps offers browseable with denied permission and Nepal camera fallback', () async {
    locationPlatform.permission = LocationPermission.deniedForever;
    final state = await _loadMap(usecase);
    final target = MapDiscoveryPage.initialCameraTarget(state, null);

    expect(state.userLocation, isNull);
    expect(state.locationError, contains('Settings'));
    expect(state.merchants, hasLength(1));
    expect(state.locationPermissionGranted, isFalse);
    expect(target.latitude, MapConfig.defaultLatitude);
    expect(locationPlatform.currentPositionCalls, 0);
    expect(locationPlatform.lastKnownPositionCalls, 0);
  });

  test('keeps offers browseable when the permission prompt is denied', () async {
    locationPlatform.permission = LocationPermission.denied;
    locationPlatform.requestedPermission = LocationPermission.denied;
    final state = await _loadMap(usecase);

    expect(state.userLocation, isNull);
    expect(state.locationPermissionGranted, isFalse);
    expect(state.locationError, contains('permission'));
    expect(state.merchants, hasLength(1));
    expect(locationPlatform.permissionRequestCalls, 1);
    expect(locationPlatform.currentPositionCalls, 0);
  });

  test('keeps browsing active when services are disabled or a fresh fix times out', () async {
    locationPlatform.servicesEnabled = false;
    final disabled = await _loadMap(usecase);
    expect(disabled.userLocation, isNull);
    expect(disabled.merchants, hasLength(1));
    expect(disabled.locationServicesEnabled, isFalse);
    expect(locationPlatform.currentPositionCalls, 0);

    locationPlatform.servicesEnabled = true;
    locationPlatform.positionError = TimeoutException('no fresh fix');
    final noFix = await _loadMap(usecase);
    expect(noFix.userLocation, isNull);
    expect(noFix.locationError, contains('fresh location'));
    expect(noFix.merchants, hasLength(1));
    expect(locationPlatform.lastKnownPositionCalls, 0);
  });

  testWidgets('offer preview only enables View Offer for a real offer', (
    tester,
  ) async {
    final pin = MapBloc.offerToMapPin(_offer())!;
    pin['image'] = null;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              OfferMapDrawer(
                merchant: pin,
                isOpen: true,
                onClose: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
    expect(find.text('View Offer'), findsOneWidget);
  });
}

Future<MapLoadedState> _loadMap(
  GetPaginatedOffersUsecase usecase,
) async {
  final bloc = MapBloc(usecase);
  final loaded = bloc.stream.firstWhere((state) => state is MapLoadedState);
  bloc.add(const MapInitialLoadRequested());
  final state = await loaded as MapLoadedState;
  await bloc.close();
  return state;
}

OfferEntity _offer() => OfferEntity(
  id: 'offer-1',
  title: 'Pizza deal',
  description: 'Pizza',
  terms: 'Terms',
  category: OfferCategory.dining,
  categoryId: 'category-dining',
  merchantName: 'Pizza Place',
  merchant: MerchantDetailEntity(
    id: 'merchant-1',
    name: 'Pizza Place',
    branches: [
      MerchantBranchEntity(
        id: 'branch-1',
        name: 'Main branch',
        address: 'Thamel',
        city: 'Kathmandu',
        lat: 27.72,
        lng: 85.33,
      ),
    ],
  ),
);

Position _position(double latitude, double longitude) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime.utc(2026, 10, 24),
  accuracy: 4,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

Map<String, dynamic> _pin(String id, double latitude, double longitude) => {
  'id': id,
  'lat': latitude,
  'lng': longitude,
  'categorySlug': 'DINING',
};
