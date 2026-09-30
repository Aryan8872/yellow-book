import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import 'offer_detail_page.dart';

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

class _MapDiscoveryViewState extends State<_MapDiscoveryView> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  final List<String> _categories = ['All', 'Dining', 'Hotels', 'Activities', 'Offers'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        return const Color(0xFF8B5CF6);
      case 'Activities':
        return const Color(0xFF10B981);
      case 'Offers':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF0053DB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2EAF8),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          // When location loads, smoothly move to location once widget is mounted
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

  // ─── Loading Screen ────────────────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Faint map background
        Container(color: const Color(0xFFE2EAF8)),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0053DB).withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'Finding your location...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0053DB),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Getting GPS signal',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF346EF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Error Screen ─────────────────────────────────────────────────────────
  Widget _buildErrorScreen(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MapBloc>().add(const MapInitialLoadRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─── Main Map Screen ──────────────────────────────────────────────────────
  Widget _buildMapScreen(BuildContext context, MapLoadedState state) {
    final userLatLng = state.userLocation ?? const LatLng(27.7172, 85.3240);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. Real OpenStreetMap Tiles ──────────────────────────────────
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
            // OpenStreetMap tile layer (free, no API key)
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.entertainer.yellowbook.app',
              maxZoom: 19,
            ),

            // ── Merchant Pins ─────────────────────────────────────────
            MarkerLayer(
              markers: [
                // User location beacon
                Marker(
                  point: userLatLng,
                  width: 60,
                  height: 60,
                  child: _UserBeacon(),
                ),
                // Merchant markers
                ...state.merchants.map((merchant) {
                  final isSelected = state.selectedMerchant?['id'] == merchant['id'];
                  return Marker(
                    point: LatLng(
                      merchant['latitude'] as double,
                      merchant['longitude'] as double,
                    ),
                    width: isSelected ? 56 : 44,
                    height: isSelected ? 72 : 58,
                    child: GestureDetector(
                      onTap: () {
                        context.read<MapBloc>().add(MapMerchantSelected(merchant));
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

        // ── 2. Floating Top Header (Back + Search + Category Tabs) ────────
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
                  // Back button + Search bar row
                  Row(
                    children: [
                      GlassContainer(
                        borderRadius: 18,
                        blur: 16,
                        padding: EdgeInsets.zero,
                        color: Colors.white.withValues(alpha: 0.92),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 20,
                          blur: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          color: Colors.white.withValues(alpha: 0.92),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF0053DB), size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (query) {
                                    context.read<MapBloc>().add(MapQueryChanged(query));
                                  },
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search venues, areas, tags...',
                                    hintStyle: TextStyle(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    context.read<MapBloc>().add(const MapQueryChanged(''));
                                  },
                                  child: const Icon(Icons.close_rounded, size: 18, color: Colors.black54),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Category Filter Tabs
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = state.activeCategory == cat;

                        return GestureDetector(
                          onTap: () {
                            context.read<MapBloc>().add(MapCategoryChanged(cat));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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

        // ── 3. Right-side FABs (Recenter + Zoom in/out) ──────────────────
        Positioned(
          right: 16,
          bottom: state.selectedMerchant != null ? 230 : 50,
          child: Column(
            children: [
              // Recenter to real GPS
              GlassContainer(
                borderRadius: 16,
                blur: 14,
                padding: EdgeInsets.zero,
                color: Colors.white.withValues(alpha: 0.92),
                child: IconButton(
                  icon: const Icon(Icons.my_location_rounded, color: Color(0xFF0053DB), size: 22),
                  onPressed: () async {
                    context.read<MapBloc>().add(const MapRecenterRequested());
                    if (state.userLocation != null) {
                      _mapController.move(state.userLocation!, 15.0);
                    }
                  },
                  tooltip: 'Go to my location',
                ),
              ),
              const SizedBox(height: 10),
              // Zoom in
              GlassContainer(
                borderRadius: 16,
                blur: 14,
                padding: EdgeInsets.zero,
                color: Colors.white.withValues(alpha: 0.92),
                child: IconButton(
                  icon: const Icon(Icons.add_rounded, color: Color(0xFF346EF6), size: 22),
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              // Zoom out
              GlassContainer(
                borderRadius: 16,
                blur: 14,
                padding: EdgeInsets.zero,
                color: Colors.white.withValues(alpha: 0.92),
                child: IconButton(
                  icon: const Icon(Icons.remove_rounded, color: Color(0xFF346EF6), size: 22),
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── 4. Selected Merchant Bottom Card ─────────────────────────────
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
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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
      ],
    );
  }
}

// ─── Animated User Beacon ─────────────────────────────────────────────────────
class _UserBeacon extends StatefulWidget {
  @override
  State<_UserBeacon> createState() => _UserBeaconState();
}

class _UserBeaconState extends State<_UserBeacon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
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
            // Outer pulse ring
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
            // Inner white halo
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
            // Blue core dot
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

// ─── Merchant Map Pin ─────────────────────────────────────────────────────────
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
        // Pin needle
        CustomPaint(
          size: Size(isSelected ? 12 : 8, isSelected ? 8 : 6),
          painter: _PinNeedle(color: isSelected ? color : Colors.white, borderColor: color),
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
    final borderPaint = Paint()..color = borderColor..style = PaintingStyle.fill;
    final fillPaint = Paint()..color = color..style = PaintingStyle.fill;

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

// ─── Merchant Bottom Card ─────────────────────────────────────────────────────
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
    return GlassContainer(
      borderRadius: 24,
      blur: 20,
      padding: const EdgeInsets.all(14),
      color: Colors.white.withValues(alpha: 0.95),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Thumbnail
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
                    color: const Color(0xFFD3E4FE),
                    child: const Icon(Icons.restaurant, color: Color(0xFF346EF6)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            merchant['highlightTag'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                            const SizedBox(width: 2),
                            Text(
                              merchant['rating'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onDismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      merchant['hotelName'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      merchant['offerType'] as String,
                      style: const TextStyle(
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF346EF6)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            merchant['location'] as String,
                            style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          merchant['distanceFromUser'] as String,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
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
                  builder: (_) => OfferDetailPage(offer: {
                    'hotelName': merchant['hotelName'],
                    'location': merchant['location'],
                    'distanceFromUser': merchant['distanceFromUser'],
                    'highlightTag': merchant['highlightTag'],
                    'image': merchant['image'],
                  }),
                ),
              );
            },
            icon: const Icon(Icons.visibility_rounded, size: 16, color: Colors.white),
            label: const Text(
              'View BOGOF Offers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0053DB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }
}
