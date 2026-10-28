import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/config/map_config.dart';
import 'package:entertainer/features/map/presentation/widgets/offer_map_drawer.dart';
import 'package:entertainer/features/map/presentation/widgets/map_search_overlay.dart';
import 'package:entertainer/features/offer/data/datasource/places_remote_datasource.dart';
import 'package:entertainer/features/map/presentation/widgets/category_map_marker_factory.dart';
import 'package:entertainer/features/map/presentation/widgets/offer_map_clusterer.dart';
import 'package:entertainer/features/map/presentation/widgets/map_filters_sheet.dart';

import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class MapDiscoveryPage extends StatelessWidget {
  final ({double lat, double lng, String? title})? initialBranch;
  final ({double lat, double lng, String label})? initialLocation;
  final bool locationPicker;

  const MapDiscoveryPage({
    super.key,
    this.initialBranch,
    this.initialLocation,
    this.locationPicker = false,
  });

  static LatLng initialCameraTarget(
    MapLoadedState state,
    ({double lat, double lng, String? title})? initialBranch,
  ) {
    if (initialBranch != null) {
      return LatLng(initialBranch.lat, initialBranch.lng);
    }
    return state.browseLocation ??
        state.userLocation ??
        const LatLng(MapConfig.defaultLatitude, MapConfig.defaultLongitude);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<MapBloc>();
        final browseLocation =
            initialLocation ??
            (initialBranch == null
                ? null
                : (
                    lat: initialBranch!.lat,
                    lng: initialBranch!.lng,
                    label: initialBranch!.title ?? 'Branch location',
                  ));
        bloc.add(
          MapInitialLoadRequested(
            latitude: browseLocation?.lat,
            longitude: browseLocation?.lng,
            locationLabel: browseLocation?.label,
          ),
        );
        return bloc;
      },
      child: _MapDiscoveryView(
        initialBranch: initialBranch,
        initialLocation: initialLocation,
        locationPicker: locationPicker,
      ),
    );
  }
}

class _MapDiscoveryView extends StatefulWidget {
  final ({double lat, double lng, String? title})? initialBranch;
  final ({double lat, double lng, String label})? initialLocation;
  final bool locationPicker;

  const _MapDiscoveryView({
    this.initialBranch,
    this.initialLocation,
    required this.locationPicker,
  });

  @override
  State<_MapDiscoveryView> createState() => _MapDiscoveryViewState();
}

class _MapDiscoveryViewState extends State<_MapDiscoveryView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  MapLibreMapController? _mapController;
  bool _styleLoaded = false;
  int _markerRenderId = 0;
  bool _pendingRecenter = false;
  String? _lastOffersError;
  String? _lastLocationError;
  int _lastLocationRevision = 0;
  bool _branchFocusInitialized = false;
  LatLng? _pickerTarget;

  // Offer drawer state (slide-in panel on pin tap)
  bool _isDrawerOpen = false;
  Map<String, dynamic>? _drawerMerchant;
  final Map<String, Map<String, dynamic>> _symbolPayloads = {};

  final List<String> _categories = [
    'All',
    'Dining',
    'Hotels',
    'Activities',
    'Offers',
  ];

  // Hamburger drawer
  bool _isMenuOpen = false;
  late AnimationController _menuAnimController;
  late Animation<Offset> _menuSlideAnimation;
  late Animation<double> _menuFadeAnimation;

  // Category data: name -> {icon, count, color}
  final List<Map<String, dynamic>> _categoryMenuItems = [
    {
      'name': 'All Venues',
      'icon': Icons.place_rounded,
      'count': 87,
      'color': const Color(0xFF1A1A2E),
    },
    {
      'name': 'Dining',
      'icon': Icons.restaurant_rounded,
      'count': 34,
      'color': const Color(0xFFEF4444),
    },
    {
      'name': 'Hotels',
      'icon': Icons.hotel_rounded,
      'count': 24,
      'color': AppTheme.accentPeriwinkleDark,
    },
    {
      'name': 'Activities',
      'icon': Icons.spa_rounded,
      'count': 12,
      'color': AppTheme.savingsGreen,
    },
    {
      'name': 'Offers',
      'icon': Icons.local_offer_rounded,
      'count': 17,
      'color': const Color(0xFFE5A93C),
    },
  ];

  @override
  void initState() {
    super.initState();
    _menuAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _menuSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _menuAnimController,
            curve: Curves.easeOutCubic,
          ),
        );
    _menuFadeAnimation = CurvedAnimation(
      parent: _menuAnimController,
      curve: Curves.easeOut,
    );
    _logMapInitialization();
  }

  void _logMapInitialization() {
    // Map initialization logged for debugging
  }

  @override
  void dispose() {
    _searchController.dispose();
    _menuAnimController.dispose();
    super.dispose();
  }

  void _openMenu() {
    setState(() => _isMenuOpen = true);
    _menuAnimController.forward();
  }

  void _closeMenu() {
    _menuAnimController.reverse().then((_) {
      if (mounted) setState(() => _isMenuOpen = false);
    });
  }

  Future<void> _confirmMapLocation(MapLoadedState state) async {
    // _pickerTarget is reliably updated on every camera idle event (pan/zoom end)
    // and on explicit map taps. Fall back to cameraPosition for edge cases where
    // the user opens the picker but never pans (camera stays at initial position).
    final coordinate =
        _pickerTarget ?? _mapController?.cameraPosition?.target ?? state.browseLocation;
    if (coordinate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a location on the map first.')),
      );
      return;
    }
    final reverse = await PlacesRemoteDataSource().reverse(
      lat: coordinate.latitude,
      lon: coordinate.longitude,
    );
    if (!mounted) return;
    final name = reverse.isNotEmpty
        ? reverse.first.name
        : '${coordinate.latitude.toStringAsFixed(5)}, ${coordinate.longitude.toStringAsFixed(5)}';
    Navigator.of(context).pop(
      PlaceSuggestion(
        formatted: name,
        name: name,
        lat: coordinate.latitude,
        lon: coordinate.longitude,
        confidence: 1,
      ),
    );
  }

  Future<void> _addMarkers(MapLoadedState state) async {
    final controller = _mapController;
    if (controller == null || !_styleLoaded) return;
    final renderId = ++_markerRenderId;
    final zoom = controller.cameraPosition?.zoom ?? MapConfig.defaultZoom;
    final clusters = OfferMapClusterer.cluster(state.merchants, zoom: zoom);

    await controller.clearSymbols();
    _symbolPayloads.clear();
    if (renderId != _markerRenderId) return;

    for (final cluster in clusters) {
      final merchant = cluster.offers.first;
      final isCluster = cluster.isCluster;
      final imageId = isCluster
          ? CategoryMapMarkerFactory.clusterImageId
          : CategoryMapMarkerFactory.imageIdFor(cluster.categorySlug);

      // Only primitive/serializable values in the MapLibre GeoJSON property map!
      // Any custom Dart objects (OfferEntity, MerchantBranchEntity) cause jsonEncode to crash.
      final symbol = await controller.addSymbol(
        SymbolOptions(
          geometry: LatLng(cluster.latitude, cluster.longitude),
          iconImage: imageId,
          iconSize: isCluster ? 0.55 : 0.45,
          iconAnchor: isCluster ? 'center' : 'bottom',
          textField: isCluster
              ? '${cluster.offers.length}'
              : merchant['hotelName'] as String? ?? '',
          textOffset: isCluster ? Offset.zero : const Offset(0, 1.5),
          textSize: isCluster ? 13 : 11,
          textColor: isCluster ? '#FFFFFF' : '#1A1A2E',
          textHaloColor: '#FFFFFF',
          textHaloWidth: isCluster ? 0 : 1.5,
        ),
        <String, dynamic>{
          'isCluster': isCluster,
          'clusterCount': cluster.offers.length,
          'lat': cluster.latitude,
          'lng': cluster.longitude,
          'hotelName': merchant['hotelName'] as String? ?? '',
          'categorySlug': cluster.categorySlug ?? '',
          'pinId': merchant['pinId'] as String? ?? merchant['id'] as String? ?? '',
        },
      );

      // Cache full rich in-memory metadata keyed by symbol ID and pinId
      _symbolPayloads[symbol.id] = {
        'isCluster': isCluster,
        'clusterCount': cluster.offers.length,
        'offers': cluster.offers,
        'merchant': isCluster ? null : merchant,
        'lat': cluster.latitude,
        'lng': cluster.longitude,
      };

      if (renderId != _markerRenderId) return;
    }

    final browseLocation = state.browseLocation;
    final userLocation = state.userLocation;
    final sameAsGps =
        browseLocation != null &&
        userLocation != null &&
        _distanceKm(browseLocation, userLocation) < 0.02;
    if (browseLocation != null && !sameAsGps) {
      await controller.addSymbol(
        SymbolOptions(
          geometry: browseLocation,
          iconImage: CategoryMapMarkerFactory.locationImageId,
          iconSize: 0.5,
          iconAnchor: 'bottom',
          textField: state.browseLocationLabel ?? 'Selected location',
          textOffset: const Offset(0, 1.5),
          textSize: 11,
          textColor: '#1A1A2E',
          textHaloColor: '#FFFFFF',
          textHaloWidth: 1.5,
        ),
        {'isBrowseLocation': true},
      );
    }
  }

  Future<void> _onStyleLoaded(MapLoadedState state) async {
    final controller = _mapController;
    if (controller == null) return;
    await CategoryMapMarkerFactory.registerImages(controller);
    _styleLoaded = true;
    await _addMarkers(state);
  }

  Future<void> _onSymbolTapped(Symbol symbol) async {
    final controller = _mapController;
    // Prefer rich in-memory payload cached by symbol id; fall back to symbol.data
    final data = _symbolPayloads[symbol.id] ?? symbol.data;
    if (controller == null || data == null) return;

    if (data['isCluster'] == true) {
      final latitude = (data['lat'] as num).toDouble();
      final longitude = (data['lng'] as num).toDouble();
      final zoom = controller.cameraPosition?.zoom ?? MapConfig.defaultZoom;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(latitude, longitude),
          OfferMapClusterer.zoomForCluster(zoom),
        ),
      );
      if (mounted) {
        setState(() {
          _isDrawerOpen = false;
          _drawerMerchant = null;
        });
        context.read<MapBloc>().add(const MapCardDismissed());
      }
      return;
    }

    final merchant = data['merchant'] as Map<String, dynamic>?;
    if (merchant == null) return;
    if (mounted) {
      setState(() {
        _isDrawerOpen = true;
        _drawerMerchant = merchant;
      });
      context.read<MapBloc>().add(MapMerchantSelected(merchant));
    }
  }

  void _closeDrawer() {
    if (mounted) setState(() => _isDrawerOpen = false);
    context.read<MapBloc>().add(const MapCardDismissed());
  }

  Future<void> _refreshOffersForVisibleRegion() async {
    if (widget.locationPicker) {
      final target = _mapController?.cameraPosition?.target;
      if (target != null && mounted) setState(() => _pickerTarget = target);
      return;
    }
    final state = context.read<MapBloc>().state;
    if (_styleLoaded && state is MapLoadedState) {
      await _addMarkers(state);
    }
  }

  double _distanceKm(LatLng start, LatLng end) {
    const earthRadiusKm = 6371.0;
    final latitudeDelta = (end.latitude - start.latitude) * math.pi / 180;
    final longitudeDelta = (end.longitude - start.longitude) * math.pi / 180;
    final startLatitude = start.latitude * math.pi / 180;
    final endLatitude = end.latitude * math.pi / 180;
    final haversine =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(startLatitude) *
            math.cos(endLatitude) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    return 2 *
        earthRadiusKm *
        math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
  }

  Future<void> _openFilters(MapLoadedState state) async {
    final selection = await showModalBottomSheet<MapFilterSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurface,
      builder: (_) => MapFiltersSheet(
        category: state.activeCategory,
        radiusKm: state.radiusKm,
        minimumRating: state.minimumRating,
        onlyOpenNow: state.onlyOpenNow,
      ),
    );
    if (selection == null || !mounted) return;
    final center =
        _mapController?.cameraPosition?.target ??
        state.browseLocation ??
        state.userLocation ??
        const LatLng(MapConfig.defaultLatitude, MapConfig.defaultLongitude);
    context.read<MapBloc>().add(
      MapFiltersApplied(
        lat: center.latitude,
        lng: center.longitude,
        radiusKm: selection.radiusKm,
        category: selection.category,
        minimumRating: selection.minimumRating,
        onlyOpenNow: selection.onlyOpenNow,
      ),
    );
  }

  void _selectOfferRecommendation(Map<String, dynamic> merchant) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    final lat = merchant['lat'] as double?;
    final lng = merchant['lng'] as double?;
    if (lat == null || lng == null) return;
    context.read<MapBloc>().add(const MapQueryChanged(''));
    context.read<MapBloc>().add(MapMerchantSelected(merchant));
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );
    setState(() {
      _isDrawerOpen = true;
      _drawerMerchant = merchant;
    });
  }

  void _selectMapPlace(PlaceSuggestion place) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    context.read<MapBloc>().add(const MapQueryChanged(''));
    context.read<MapBloc>().add(
      MapPlaceSelected(
        latitude: place.lat,
        longitude: place.lon,
        label: place.formatted,
      ),
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.lat, place.lon), 15),
    );
    _pickerTarget = LatLng(place.lat, place.lon);
    setState(() {
      _isDrawerOpen = false;
      _drawerMerchant = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapLoadedState) {
            if (widget.initialBranch != null && !_branchFocusInitialized) {
              _branchFocusInitialized = true;
              context.read<MapBloc>().add(
                MapFocusBranchRequested(
                  lat: widget.initialBranch!.lat,
                  lng: widget.initialBranch!.lng,
                  title: widget.initialBranch!.title,
                ),
              );
            }
            if (state.offersError != null &&
                state.offersError != _lastOffersError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.offersError!)));
            }
            _lastOffersError = state.offersError;
            if (state.locationError != null &&
                state.locationError != _lastLocationError) {
              _showLocationIssue(context, state);
            }
            _lastLocationError = state.locationError;
            if (_styleLoaded) {
              unawaited(_addMarkers(state));
            }
            if (_pendingRecenter &&
                state.locationRevision > _lastLocationRevision) {
              _pendingRecenter = false;
              final location = state.userLocation;
              final controller = _mapController;
              if (location != null && controller != null) {
                unawaited(
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(location, 15.0),
                  ),
                );
              }
            }
            _lastLocationRevision = state.locationRevision;
          }
        },
        builder: (context, state) {
          if (state is MapLoadingState) {
            return _buildLoadingScreen();
          }
          if (state is MapErrorState) {
            return _buildErrorScreen(state.message);
          }
          if (state is MapLoadedState) {
            return _buildMapScreen(context, state);
          }
          return _buildLoadingScreen();
        },
      ),
    );
  }

  void _showLocationIssue(BuildContext context, MapLoadedState state) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(state.locationError!),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () async {
            final opened = state.locationServicesEnabled
                ? await Geolocator.openAppSettings()
                : await Geolocator.openLocationSettings();
            if (!opened && mounted) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Could not open location settings.'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppTheme.canvasBg),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.darkPill,
                shape: BoxShape.circle,
                boxShadow: AppTheme.softCardShadow,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading map offers...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your location is optional',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.darkPill,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off_rounded,
            size: 48,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MapBloc>().add(const MapInitialLoadRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkPill,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMapKeyError(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 64,
                color: AppTheme.textMuted,
              ),
              const SizedBox(height: 24),
              Text(
                'Map Service Unavailable',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The map style key is not configured. Please build with the GEOAPIFY_MAP_KEY dart-define.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Build command: flutter build apk --debug --dart-define=GEOAPIFY_MAP_KEY=<your_key>',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapScreen(BuildContext context, MapLoadedState state) {
    final targetLatLng = MapDiscoveryPage.initialCameraTarget(
      state,
      widget.initialBranch,
    );
    final initialZoom = widget.initialBranch != null ? 16.0 : 14.0;

    // Check if map key is available
    if (!MapConfig.hasMapKey || MapConfig.styleUrl.isEmpty) {
      return _buildMapKeyError(context);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── MAP ──────────────────────────────────────────────────────────
        MapLibreMap(
          initialCameraPosition: CameraPosition(
            target: targetLatLng,
            zoom: initialZoom,
          ),
          styleString: MapConfig.styleUrl,
          minMaxZoomPreference: const MinMaxZoomPreference(3.0, 19.0),
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              // Nepal bounding box: SW 26.3°N 80.0°E  NE 30.5°N 88.2°E
              southwest: const LatLng(26.3, 80.0),
              northeast: const LatLng(30.5, 88.2),
            ),
          ),
          myLocationEnabled:
              state.locationPermissionGranted && state.userLocation != null,
          onMapCreated: (controller) {
            _mapController = controller;
            controller.onSymbolTapped.add(
              (symbol) => unawaited(_onSymbolTapped(symbol)),
            );
          },
          onStyleLoadedCallback: () {
            final bloc = context.read<MapBloc>();
            final s = bloc.state;
            if (s is MapLoadedState) _onStyleLoaded(s);
          },
          onCameraIdle: _refreshOffersForVisibleRegion,
          onMapClick: (_, coordinates) {
            if (widget.locationPicker) {
              _pickerTarget = coordinates;
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(coordinates),
              );
            } else {
              _closeDrawer();
            }
          },
        ),

        // ── TOP HEADER ROW: Hamburger | Search | Close ───────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // ── Hamburger Menu Button (top-left) ──────────────
                      _TopBarButton(
                        onTap: _openMenu,
                        child: const Icon(
                          Icons.menu_rounded,
                          color: AppTheme.textPrimary,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ── Search Bar (center) ───────────────────────────
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.borderLight),
                            boxShadow: AppTheme.softCardShadow,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (query) {
                                    context.read<MapBloc>().add(
                                      MapQueryChanged(query),
                                    );
                                    setState(() {});
                                  },
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search venues, areas, tags...',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    context.read<MapBloc>().add(
                                      const MapQueryChanged(''),
                                    );
                                    setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ── Close (X) Button (top-right) ──────────────────
                      if (!widget.locationPicker) ...[
                        _TopBarButton(
                          onTap: () => _openFilters(state),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppTheme.textPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      _TopBarButton(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textPrimary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Category Pills ────────────────────────────────────
                  if (!widget.locationPicker)
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = state.activeCategory == cat;

                          return GestureDetector(
                            onTap: () {
                              context.read<MapBloc>().add(
                                MapCategoryChanged(cat),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.darkPill
                                    : AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.darkPill
                                      : AppTheme.borderLight,
                                ),
                                boxShadow: isSelected
                                    ? AppTheme.softCardShadow
                                    : null,
                              ),
                              child: Text(
                                cat,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // ── Autocomplete search dropdown ─────────────────────────────────
        Positioned(
          top: 110,
          left: 16,
          right: 16,
          child: MapSearchOverlay(
            merchants: state.merchants,
            controller: _searchController,
            onQueryChanged: (q) {
              context.read<MapBloc>().add(MapQueryChanged(q));
              setState(() {});
            },
            onMerchantSelected: (merchant) {
              _selectOfferRecommendation(merchant);
            },
            onPlaceSelected: (place) {
              _selectMapPlace(place);
            },
            onClear: () {
              context.read<MapBloc>().add(const MapQueryChanged(''));
              setState(() {});
            },
            currentLat: _mapController?.cameraPosition?.target.latitude,
            currentLng: _mapController?.cameraPosition?.target.longitude,
          ),
        ),

        // ── Floating Action Buttons (Recenter / Zoom) ────────────────────
        Positioned(
          right: 16,
          bottom: 50,
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.my_location_rounded,
                    color: AppTheme.accentPeriwinkleDark,
                    size: 20,
                  ),
                  onPressed: () async {
                    if (!mounted) return;
                    _pendingRecenter = true;
                    context.read<MapBloc>().add(const MapRecenterRequested());
                  },
                  tooltip: 'Go to my location',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                      onPressed: () async {
                        if (_mapController != null) {
                          _mapController!.animateCamera(CameraUpdate.zoomIn());
                        }
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppTheme.borderLight,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_rounded,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                      onPressed: () async {
                        if (_mapController != null) {
                          _mapController!.animateCamera(CameraUpdate.zoomOut());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (widget.locationPicker) ...[
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 26),
                child: Icon(
                  Icons.location_pin,
                  color: Color(0xFF1D4ED8),
                  size: 48,
                  shadows: [Shadow(color: Colors.white, blurRadius: 8)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: FilledButton.icon(
              onPressed: () => _confirmMapLocation(state),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Use this location'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: AppTheme.darkPill,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],

        // ── Offer preview at the bottom, leaving the map visible ───────────
        OfferMapDrawer(
          merchant: _drawerMerchant,
          isOpen: _isDrawerOpen,
          onClose: _closeDrawer,
        ),

        // ── Hamburger Side Menu Overlay ──────────────────────────────────
        if (_isMenuOpen) ...[
          // Scrim
          FadeTransition(
            opacity: _menuFadeAnimation,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(color: Colors.black.withValues(alpha: 0.40)),
            ),
          ),

          // Slide-in drawer panel
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: SlideTransition(
              position: _menuSlideAnimation,
              child: _CategorySideMenu(
                items: _categoryMenuItems,
                activeCategory: state.activeCategory,
                onCategoryTap: (name) {
                  // Map menu item names back to filter category
                  final filterKey = name == 'All Venues' ? 'All' : name;
                  context.read<MapBloc>().add(MapCategoryChanged(filterKey));
                  _closeMenu();
                },
                onClose: _closeMenu,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Reusable Top-Bar Icon Button ─────────────────────────────────────────────
class _TopBarButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _TopBarButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Category Side Menu Panel ─────────────────────────────────────────────────
class _CategorySideMenu extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String activeCategory;
  final void Function(String name) onCategoryTap;
  final VoidCallback onClose;

  const _CategorySideMenu({
    required this.items,
    required this.activeCategory,
    required this.onCategoryTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        height: screenH,
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(8, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Filter by category',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    // Close Button
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Divider(color: AppTheme.borderLight, thickness: 0.8),

              const SizedBox(height: 6),

              // ── Category List ──────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final name = item['name'] as String;
                    final icon = item['icon'] as IconData;
                    final count = item['count'] as int;
                    final color = item['color'] as Color;
                    final filterKey = name == 'All Venues' ? 'All' : name;
                    final isActive = activeCategory == filterKey;

                    return _CategoryMenuItem(
                      name: name,
                      icon: icon,
                      count: count,
                      color: color,
                      isActive: isActive,
                      onTap: () => onCategoryTap(name),
                    );
                  },
                ),
              ),

              // ── Footer ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
                child: Text(
                  'OfferNepal · Map Discovery',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single Category Menu Item ────────────────────────────────────────────────
class _CategoryMenuItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final int count;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryMenuItem({
    required this.name,
    required this.icon,
    required this.count,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.30)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? color : AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Name
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? color : AppTheme.textPrimary,
                ),
              ),
            ),

            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.15)
                    : AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive ? color : AppTheme.textSecondary,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isActive ? color : AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
