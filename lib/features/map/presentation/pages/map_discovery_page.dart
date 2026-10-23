import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/config/map_config.dart';
import 'package:entertainer/features/map/presentation/widgets/offer_map_drawer.dart';
import 'package:entertainer/features/map/presentation/widgets/map_search_overlay.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';

class MapDiscoveryPage extends StatelessWidget {
  final ({double lat, double lng, String? title})? initialBranch;

  const MapDiscoveryPage({super.key, this.initialBranch});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<MapBloc>();
        bloc.add(const MapInitialLoadRequested());
        if (initialBranch != null) {
          bloc.add(MapFocusBranchRequested(
            lat: initialBranch!.lat,
            lng: initialBranch!.lng,
            title: initialBranch!.title,
          ));
        }
        return bloc;
      },
      child: _MapDiscoveryView(initialBranch: initialBranch),
    );
  }
}


class _MapDiscoveryView extends StatefulWidget {
  final ({double lat, double lng, String? title})? initialBranch;

  const _MapDiscoveryView({this.initialBranch});

  @override
  State<_MapDiscoveryView> createState() => _MapDiscoveryViewState();
}

class _MapDiscoveryViewState extends State<_MapDiscoveryView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  MapLibreMapController? _mapController;

  // Offer drawer state (slide-in panel on pin tap)
  bool _isDrawerOpen = false;
  Map<String, dynamic>? _drawerMerchant;

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
    _menuSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _menuAnimController, curve: Curves.easeOutCubic),
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


  void _addMarkers(MapLoadedState state) {
    if (_mapController == null) return;
    _mapController!.clearSymbols();
    for (final merchant in state.merchants) {
      final lat = merchant['lat'] as double?;
      final lng = merchant['lng'] as double?;
      if (lat == null || lng == null) continue;
      _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(lat, lng),
          iconImage: 'map_pin', // registered after style load
          iconSize: 0.10,
          iconAnchor: 'bottom',
          textField: merchant['hotelName'] as String? ?? '',
          textOffset: const Offset(0, 1.5),
          textSize: 11,
          textColor: '#1A1A2E',
          textHaloColor: '#FFFFFF',
          textHaloWidth: 1.5,
        ),
        {'merchant': merchant},
      );
    }
  }

  Future<void> _onStyleLoaded(MapLoadedState state) async {
    if (_mapController == null) return;
    // Register the pin image
    final imageBytes = await _loadAssetBytes('assets/images/map_pin.png');
    if (imageBytes != null) {
      await _mapController!.addImage('map_pin', imageBytes);
    } else {
      // Failed to load map pin asset
    }
    _addMarkers(state);
    // Symbol tap handler
    _mapController!.onSymbolTapped.add((symbol) {
      final merchant = symbol.data?['merchant'] as Map<String, dynamic>?;
      if (merchant != null) {
        // Fly-to with slight north offset so drawer doesn't cover pin
        final lat = merchant['lat'] as double?;
        final lng = merchant['lng'] as double?;
        if (lat != null && lng != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat - 0.002, lng), 15.0),
          );
        }
        if (mounted) setState(() { _isDrawerOpen = true; _drawerMerchant = merchant; });
        context.read<MapBloc>().add(MapMerchantSelected(merchant));
      }
    });
  }

  Future<Uint8List?> _loadAssetBytes(String assetPath) async {
    try {
      final data = await DefaultAssetBundle.of(context).load(assetPath);
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  void _closeDrawer() {
    if (mounted) setState(() => _isDrawerOpen = false);
    context.read<MapBloc>().add(const MapCardDismissed());
  }

  List<Widget> _buildMarkerOverlays(MapLoadedState state, LatLng userLatLng) {
    final overlays = <Widget>[];

    // User location beacon - centered on screen for now
    // In a full implementation, this would be positioned using toScreenLocation
    overlays.add(
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: IgnorePointer(
          child: Center(
            child: _UserBeacon(),
          ),
        ),
      ),
    );

    // Note: Proper marker positioning with MapLibre requires using
    // the controller's toScreenLocation method in a callback after
    // the map is fully loaded. For now, we'll use Symbol annotations
    // directly on the map for better performance and positioning.
    // This is a simplified approach - the full implementation would
    // use MapLibre's SymbolLayer for marker rendering.

    return overlays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapLoadedState && state.userLocation != null && _mapController != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                try {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(state.userLocation!.latitude, state.userLocation!.longitude),
                      14.0,
                    ),
                  );
                } catch (_) {}
              }
            });
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
              'Finding your location...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acquiring GPS signal',
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
    // Use initialBranch coordinates if provided, otherwise user location or default
    LatLng targetLatLng;
    double initialZoom = 14.0;
    
    if (widget.initialBranch != null) {
      targetLatLng = LatLng(widget.initialBranch!.lat, widget.initialBranch!.lng);
      initialZoom = 16.0; // Branch focus zoom level
    } else {
      targetLatLng = state.userLocation != null
          ? LatLng(state.userLocation!.latitude, state.userLocation!.longitude)
          : const LatLng(MapConfig.defaultLatitude, MapConfig.defaultLongitude);
    }

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
          myLocationEnabled: true,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onStyleLoadedCallback: () {
            final bloc = context.read<MapBloc>();
            final s = bloc.state;
            if (s is MapLoadedState) _onStyleLoaded(s);
          },
          onMapClick: (_, __) => _closeDrawer(),
        ),

        // ── MARKERS OVERLAY ─────────────────────────────────────────────
        ..._buildMarkerOverlays(state, targetLatLng),

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
                                    context
                                        .read<MapBloc>()
                                        .add(MapQueryChanged(query));
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
                                    context
                                        .read<MapBloc>()
                                        .add(const MapQueryChanged(''));
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
                            context
                                .read<MapBloc>()
                                .add(MapCategoryChanged(cat));
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
              final lat = merchant['lat'] as double?;
              final lng = merchant['lng'] as double?;
              if (lat != null && lng != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.0),
                );
              }
              setState(() { _isDrawerOpen = true; _drawerMerchant = merchant; });
            },
            onPlaceSelected: (place) {
              if (_mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(LatLng(place.lat, place.lon), 15.0),
                );
              }
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
          bottom: state.selectedMerchant != null ? 230 : 50,
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
                    // Request location refresh from bloc first
                    if (!mounted) return;
                    context.read<MapBloc>().add(const MapRecenterRequested());
                    
                    // Wait for state update then animate camera
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted) return;
                    final blocState = context.read<MapBloc>().state;
                    if (blocState is MapLoadedState && blocState.userLocation != null && _mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(blocState.userLocation!.latitude, blocState.userLocation!.longitude),
                          15.0,
                        ),
                      );
                    }
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
                          _mapController!.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
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
                          _mapController!.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Bottom Selected Merchant Card ─────────────────────────────────
        if (state.selectedMerchant != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
              child: _MerchantBottomCard(
                key: ValueKey(state.selectedMerchant!['id']),
                merchant: state.selectedMerchant!,
                onDismiss: () {
                  context.read<MapBloc>().add(const MapCardDismissed());
                },
              ),
            ),
          ),

        // ── Offer Drawer (slide-in panel) ─────────────────────────────────
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
              child: Container(
                color: Colors.black.withValues(alpha: 0.40),
              ),
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
            color: isActive ? color.withValues(alpha: 0.30) : Colors.transparent,
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
                color: isActive ? color.withValues(alpha: 0.15) : AppTheme.surfaceSubtle,
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

// ── User Location Beacon ─────────────────────────────────────────────────────
class _UserBeacon extends StatefulWidget {
  @override
  State<_UserBeacon> createState() => _UserBeaconState();
}

class _UserBeaconState extends State<_UserBeacon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 50 * _pulse.value + 10,
              height: 50 * _pulse.value + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF346EF6).withValues(
                  alpha: (1 - _pulse.value) * 0.4,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x330053DB),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            Container(
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0053DB),
              ),
            ),
          ],
        );
      },
    );
  }
}


// ── Merchant Bottom Card ─────────────────────────────────────────────────────
class _MerchantBottomCard extends StatelessWidget {
  final Map<String, dynamic> merchant;
  final VoidCallback onDismiss;

  const _MerchantBottomCard({
    super.key,
    required this.merchant,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softCardShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  merchant['image'] as String,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, _) => Container(
                    width: 84,
                    height: 84,
                    color: AppTheme.surfaceSubtle,
                    child: const Icon(
                      Icons.restaurant,
                      color: AppTheme.accentPeriwinkle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.darkPill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            merchant['highlightTag'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              merchant['rating'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onDismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      merchant['hotelName'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      merchant['offerType'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.savingsGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: AppTheme.accentPeriwinkleDark,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            merchant['location'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          merchant['distanceFromUser'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfferDetailPage(
                    offer: OfferEntity(
                      title: 'BOGOF Offer',
                      description: 'Buy 1 Get 1 Free on selected items.',
                      terms: 'Valid for dine-in only. Cannot be combined with other offers.',
                      category: OfferCategory.fromString(merchant['category'] as String? ?? 'DINING'),
                      merchantName: merchant['hotelName'] as String?,
                      imageUrl: merchant['image'] as String?,
                      estimatedSavingsNpr: 500,
                      maxPerUser: 3,
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.visibility_rounded,
              size: 16,
              color: Colors.white,
            ),
            label: Text(
              'View BOGOF Offers',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkPill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }
}
