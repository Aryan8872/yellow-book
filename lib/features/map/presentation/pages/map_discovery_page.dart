import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';

class MapDiscoveryPage extends StatelessWidget {
  const MapDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc()..add(const MapInitialLoadRequested()),
      child: const _MapDiscoveryView(),
    );
  }
}

class _MapDiscoveryView extends StatefulWidget {
  const _MapDiscoveryView();

  @override
  State<_MapDiscoveryView> createState() => _MapDiscoveryViewState();
}

class _MapDiscoveryViewState extends State<_MapDiscoveryView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Dining':
        return Icons.restaurant_rounded;
      case 'Hotels':
        return Icons.hotel_rounded;
      case 'Activities':
        return Icons.spa_rounded;
      case 'Offers':
        return Icons.local_offer_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Dining':
        return const Color(0xFFEF4444);
      case 'Hotels':
        return AppTheme.accentPeriwinkleDark;
      case 'Activities':
        return AppTheme.savingsGreen;
      case 'Offers':
        return const Color(0xFFE5A93C);
      default:
        return AppTheme.darkPill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapLoadedState && state.userLocation != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                try {
                  _mapController.move(state.userLocation!, 14.0);
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

  Widget _buildMapScreen(BuildContext context, MapLoadedState state) {
    final userLatLng = state.userLocation ?? const LatLng(27.7172, 85.3240);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── MAP ──────────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLatLng,
            initialZoom: 14.0,
            minZoom: 3.0,
            maxZoom: 19.0,
            onTap: (tapPos, _) {
              context.read<MapBloc>().add(const MapCardDismissed());
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.entertainer.yellowbook.app',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: userLatLng,
                  width: 60,
                  height: 60,
                  child: _UserBeacon(),
                ),
                ...state.merchants.map((merchant) {
                  final isSelected =
                      state.selectedMerchant?['id'] == merchant['id'];
                  return Marker(
                    point: LatLng(
                      merchant['latitude'] as double,
                      merchant['longitude'] as double,
                    ),
                    width: isSelected ? 56 : 44,
                    height: isSelected ? 72 : 58,
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<MapBloc>()
                            .add(MapMerchantSelected(merchant));
                        _mapController.move(
                          LatLng(
                            merchant['latitude'] as double,
                            merchant['longitude'] as double,
                          ),
                          15.5,
                        );
                      },
                      child: _MerchantPin(
                        category: merchant['category'] as String,
                        isSelected: isSelected,
                        icon: _getCategoryIcon(merchant['category'] as String),
                        color: _getCategoryColor(merchant['category'] as String),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
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
                    context
                        .read<MapBloc>()
                        .add(const MapRecenterRequested());
                    if (state.userLocation != null) {
                      _mapController.move(state.userLocation!, 15.0);
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
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
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
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
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

// ── Merchant Map Pin ─────────────────────────────────────────────────────────
class _MerchantPin extends StatelessWidget {
  final String category;
  final bool isSelected;
  final IconData icon;
  final Color color;

  const _MerchantPin({
    required this.category,
    required this.isSelected,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          width: isSelected ? 48 : 36,
          height: isSelected ? 48 : 36,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isSelected ? 0.5 : 0.2),
                blurRadius: isSelected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : color,
            size: isSelected ? 24 : 18,
          ),
        ),
        CustomPaint(
          size: Size(isSelected ? 12 : 8, isSelected ? 8 : 6),
          painter: _PinNeedle(
            color: isSelected ? color : Colors.white,
            borderColor: color,
          ),
        ),
      ],
    );
  }
}

class _PinNeedle extends CustomPainter {
  final Color color;
  final Color borderColor;
  _PinNeedle({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPath = ui.Path()
      ..moveTo(-1, 0)
      ..lineTo(size.width / 2, size.height + 2)
      ..lineTo(size.width + 1, 0)
      ..close();
    canvas.drawPath(borderPath, borderPaint);

    final fillPath = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _PinNeedle old) =>
      old.color != color || old.borderColor != borderColor;
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
                    offer: {
                      'hotelName': merchant['hotelName'],
                      'location': merchant['location'],
                      'distanceFromUser': merchant['distanceFromUser'],
                      'highlightTag': merchant['highlightTag'],
                      'image': merchant['image'],
                    },
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
