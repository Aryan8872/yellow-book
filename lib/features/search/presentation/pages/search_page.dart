import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/features/home/data/datasources/category_remote_datasource.dart';
import 'package:entertainer/features/home/presentation/widgets/location_selection_modal.dart';
import 'package:entertainer/features/offer/data/datasource/places_remote_datasource.dart';
import 'package:entertainer/features/search/presentation/pages/search_results_page.dart';
import 'package:entertainer/features/search/presentation/widgets/offer_filter_bottom_sheet.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';

class SearchPage extends StatefulWidget {
  final String? initialLocation;

  const SearchPage({super.key, this.initialLocation});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final CategoryRemoteDataSource _categoryDataSource = getIt<CategoryRemoteDataSource>();

  late String _activeLocationScope;
  PlaceSuggestion? _selectedPlace;
  double? _activeLat;
  double? _activeLng;
  OfferFilterCriteria _activeCriteria = const OfferFilterCriteria();

  List<CategoryModel> _backendCategories = [];
  bool _isLoadingCategories = true;

  final List<({String title, String subtitle, String tag, String image, Color tagColor})> _curatedCollections = const [
    (
      title: 'Under Rs. 999 Steals',
      subtitle: '42 Pocket-friendly spots',
      tag: 'Hot Budget',
      image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
      tagColor: AppTheme.crimsonPrimary,
    ),
    (
      title: 'Rooftop Dining in Patan',
      subtitle: '19 High-altitude venues',
      tag: 'Scenic Vibe',
      image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80',
      tagColor: AppTheme.emeraldJade,
    ),
    (
      title: 'Couples Wellness Packages',
      subtitle: '15 Premium spas',
      tag: 'Relaxation',
      image: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=600&q=80',
      tagColor: AppTheme.amberFlame,
    ),
  ];

  final List<({String label, IconData icon, double lat, double lng})> _lifestyleHubs = const [
    (label: 'Near Me (<2km)', icon: Icons.my_location_rounded, lat: 27.7172, lng: 85.3240),
    (label: 'Jhamsikhel Food Strip', icon: Icons.restaurant_rounded, lat: 27.6788, lng: 85.3123),
    (label: 'Thamel Nightlife', icon: Icons.nightlife_rounded, lat: 27.7154, lng: 85.3123),
    (label: 'Durbar Marg Luxury', icon: Icons.diamond_rounded, lat: 27.7107, lng: 85.3188),
    (label: 'Pokhara Lakeside', icon: Icons.kayaking_rounded, lat: 28.2096, lng: 83.9595),
  ];

  @override
  void initState() {
    super.initState();
    _activeLocationScope = widget.initialLocation ?? 'Kathmandu Valley';
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final cats = await _categoryDataSource.getCategories();
      if (mounted) {
        setState(() {
          _backendCategories = cats;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _openLocationSelector() async {
    final selected = await LocationSelectionModal.show(
      context,
      currentLocation: _activeLocationScope,
    );
    if (selected != null && mounted) {
      setState(() {
        _selectedPlace = selected;
        _activeLocationScope = selected.formatted;
        _activeLat = selected.lat;
        _activeLng = selected.lon;
      });
    }
  }

  Future<void> _openFilterDialog() async {
    final updated = await OfferFilterBottomSheet.show(
      context,
      initialCriteria: _activeCriteria,
    );

    if (updated != null && mounted) {
      setState(() {
        _activeCriteria = updated;
      });
      // Navigate to search results with these filters applied
      _navigateToResults(
        _searchController.text.trim(),
        criteria: updated,
      );
    }
  }

  void _navigateToResults(
    String query, {
    String? category,
    double? lat,
    double? lng,
    String? placeLabel,
    OfferFilterCriteria? criteria,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          query: query,
          initialCategory: category,
          lat: lat ?? _activeLat,
          lng: lng ?? _activeLng,
          placeLabel: placeLabel ?? _selectedPlace?.district ?? _activeLocationScope,
          initialCriteria: criteria ?? _activeCriteria,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialData,
          color: AppTheme.crimsonPrimary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Explore Sticky Header Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // City Location selector button
                      GestureDetector(
                        onTap: _openLocationSelector,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF131B2E).withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.crimsonPrimary),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 130),
                                child: Text(
                                  _activeLocationScope,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.expand_more_rounded, size: 16, color: AppTheme.textMuted),
                            ],
                          ),
                        ),
                      ),

                      // Interactive Map Trigger
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapDiscoveryPage()),
                          );
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF131B2E).withValues(alpha: 0.04),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.map_rounded, size: 18, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Search & Locality Scope Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: Column(
                    children: [
                      // Search Pill Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF131B2E).withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    _navigateToResults(val.trim());
                                  }
                                },
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search momo, spa, getaway, discounts...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    color: AppTheme.textMuted,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            // Filter Tune Button: Opens Filter Dialog!
                            GestureDetector(
                              onTap: _openFilterDialog,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _activeCriteria.activeCount > 0
                                      ? AppTheme.surfaceDark
                                      : AppTheme.canvasBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: 17,
                                  color: _activeCriteria.activeCount > 0
                                      ? Colors.white
                                      : AppTheme.crimsonPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Active Neighborhood Breadcrumb Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _openLocationSelector,
                            child: Row(
                              children: [
                                const Icon(Icons.near_me_rounded, size: 14, color: AppTheme.crimsonPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  'Filtering around: ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 130),
                                  child: Text(
                                    _activeLocationScope,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.crimsonPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppTheme.crimsonPrimary),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldJade.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Verified Deals',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.emeraldJade,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Quick Hub Discovery Rails
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _lifestyleHubs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final hub = _lifestyleHubs[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeLocationScope = hub.label;
                            _activeLat = hub.lat;
                            _activeLng = hub.lng;
                          });
                          _navigateToResults(
                            '',
                            lat: hub.lat,
                            lng: hub.lng,
                            placeLabel: hub.label,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF131B2E).withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(hub.icon, size: 14, color: AppTheme.crimsonPrimary),
                              const SizedBox(width: 6),
                              Text(
                                hub.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 4. Visual Category Bento Grid (Populated from Backend)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categories to Explore',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Verified discounts tailored for urban lifestyle',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _navigateToResults(''),
                        child: Text(
                          'View All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _isLoadingCategories
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(color: AppTheme.crimsonPrimary),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.45,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (_backendCategories.isEmpty) {
                              return const SizedBox();
                            }
                            final cat = _backendCategories[index % _backendCategories.length];
                            return _buildCategoryBentoCard(
                              name: cat.name,
                              offerCount: cat.offerCount,
                              iconUrl: cat.iconUrl,
                              onTap: () {
                                _navigateToResults('', category: cat.name);
                              },
                            );
                          },
                          childCount: _backendCategories.isEmpty ? 0 : _backendCategories.length,
                        ),
                      ),
              ),

              // 5. Curated Lifestyle Collections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Curated Collections',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Handcrafted for you',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _curatedCollections.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = _curatedCollections[index];
                      return GestureDetector(
                        onTap: () => _navigateToResults(item.title),
                        child: Container(
                          width: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: AppTheme.cardSurface,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF131B2E).withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.image,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => Container(color: AppTheme.surfaceDark),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: item.tagColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item.tag,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.subtitle,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBentoCard({
    required String name,
    required int offerCount,
    String? iconUrl,
    required VoidCallback onTap,
  }) {
    IconData defaultIcon = Icons.category_rounded;
    final lower = name.toLowerCase();
    if (lower.contains('din') || lower.contains('food')) defaultIcon = Icons.restaurant_rounded;
    if (lower.contains('well') || lower.contains('spa')) defaultIcon = Icons.spa_rounded;
    if (lower.contains('activ') || lower.contains('sport')) defaultIcon = Icons.sports_esports_rounded;
    if (lower.contains('shop') || lower.contains('retail')) defaultIcon = Icons.shopping_bag_rounded;
    if (lower.contains('get') || lower.contains('travel')) defaultIcon = Icons.landscape_rounded;
    if (lower.contains('salon') || lower.contains('beauty')) defaultIcon = Icons.content_cut_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF131B2E).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.crimsonPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(defaultIcon, size: 20, color: AppTheme.crimsonPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldJade.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    offerCount > 0 ? '$offerCount Deals' : 'Active',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.emeraldJade,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  offerCount > 0 ? '$offerCount offers available' : 'Explore deals',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
