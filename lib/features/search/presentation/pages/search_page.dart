import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/category_pill_row.dart';
import 'package:entertainer/core/widgets/skeleton_loader.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'package:entertainer/features/offer/data/datasource/branch_remote_datasource.dart';
import 'package:entertainer/features/offer/data/datasource/places_remote_datasource.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/search/presentation/pages/search_results_page.dart';
import 'package:entertainer/features/search/presentation/bloc/search_bloc.dart';
import 'package:entertainer/features/home/presentation/widgets/stores_near_you_slider.dart';
import 'package:entertainer/features/home/presentation/widgets/user_favorites_section.dart';
import 'package:entertainer/features/home/data/datasources/category_remote_datasource.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final BranchRemoteDataSource _branchDataSource = getIt<BranchRemoteDataSource>();
  final CategoryRemoteDataSource _categoryDataSource = getIt<CategoryRemoteDataSource>();
  final PlacesRemoteDataSource _placesDataSource = PlacesRemoteDataSource();

  List<CategoryModel> _categories = [];
  bool _categoriesLoading = true;
  bool _categoriesError = false;
  String? _selectedCategory;

  List<NearbyPlace> _nearbyPlaces = [];
  bool _nearbyPlacesLoading = true;
  bool _nearbyPlacesError = false;

  List<String> _recentSearches = [];
  final List<OfferEntity> _userFavorites = [];
  List<StoreItem> _storesNearYou = [];

  // Default Kathmandu coordinates (fallback)
  final double _currentLat = 27.7172;
  final double _currentLng = 85.3240;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadNearbyPlaces();
    _loadStoresNearYou();
    _loadRecentSearches();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = false;
    });

    try {
      final categories = await _categoryDataSource.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _categoriesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesLoading = false;
          _categoriesError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn\'t load categories'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() {
      _nearbyPlacesLoading = true;
      _nearbyPlacesError = false;
    });

    try {
      final places = await _placesDataSource.reverse(
        lat: _currentLat,
        lon: _currentLng,
      );
      if (mounted) {
        setState(() {
          _nearbyPlaces = places;
          _nearbyPlacesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nearbyPlacesLoading = false;
          _nearbyPlacesError = true;
        });
      }
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _loadCategories(),
      _loadNearbyPlaces(),
      _loadStoresNearYou(),
    ]);
  }

  Future<void> _loadRecentSearches() async {
    // TODO: Load from local storage
    setState(() {
      _recentSearches = [];
    });
  }

  Future<void> _loadStoresNearYou() async {
    // Default Kathmandu coordinates
    final branches = await _branchDataSource.getBranchesNear(
      lat: 27.7172,
      lng: 85.3240,
      radiusKm: 10,
      limit: 20,
    );

    if (mounted) {
      setState(() {
        _storesNearYou = branches.map((branch) {
          final merchant = branch['merchant'] as Map<String, dynamic>?;
          final distance = (branch['distance'] as num?)?.toStringAsFixed(1) ?? '0.0';
          return StoreItem(
            id: branch['id'] as String,
            name: merchant?['name'] as String? ?? branch['name'] as String? ?? 'Unknown',
            logoText: (merchant?['name'] as String? ?? 'Unknown').substring(0, 8).toUpperCase(),
            logoBg: const Color(0xFF1E6B3A),
            logoFg: Colors.white,
            category: 'General',
            distance: '$distance km',
            time: 'Open now',
            price: 'Offers available',
          );
        }).toList();
      });
    }
  }

  void _navigateToResults(String query, {String? category, double? lat, double? lng, String? placeLabel}) {
    // Allow navigation if there's a query OR a category OR location params
    if (query.trim().isEmpty && category == null && lat == null && placeLabel == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          query: query,
          initialCategory: category,
          lat: lat,
          lng: lng,
          radiusKm: 10,
          placeLabel: placeLabel,
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
          onRefresh: _onRefresh,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 100),
            children: [
            // Search Input Row + Map Floating Button (Screenshot 3 Style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.softCardShadow,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppTheme.textPrimary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _navigateToResults,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search restaurants, stores, locations...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textMuted,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textSecondary),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.darkAnchor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkAnchor.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.map_outlined, color: Colors.white, size: 22),
                      tooltip: 'Open Interactive Map',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MapDiscoveryPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Horizontal Category Pills
            CategoryPillRow(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelected: (category) {
                setState(() => _selectedCategory = category);
                _navigateToResults(_searchController.text, category: category);
              },
              isLoading: _categoriesLoading,
              hasError: _categoriesError,
            ),

            const SizedBox(height: 22),

            // Recent Searches Section
            if (_recentSearches.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _recentSearches.clear();
                        });
                      },
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: AppTheme.accentPeriwinkleDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentSearches.map((term) {
                    return InkWell(
                      onTap: () => _navigateToResults(term),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.softCardShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history_rounded, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              term,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Nearby Places (or Popular Places fallback)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _nearbyPlacesError ? 'Popular places' : 'Nearby places',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_nearbyPlacesLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    SkeletonLoader(height: 40),
                    SizedBox(height: 8),
                    SkeletonLoader(height: 40),
                    SizedBox(height: 8),
                    SkeletonLoader(height: 40),
                  ],
                ),
              )
            else if (_nearbyPlaces.isEmpty && !_nearbyPlacesError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No nearby places found. Try searching manually.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _nearbyPlaces.map((place) {
                    final distance = _calculateDistance(
                      _currentLat,
                      _currentLng,
                      place.lat,
                      place.lon,
                    );
                    return InkWell(
                      onTap: () => _navigateToResults(
                        _searchController.text,
                        lat: place.lat,
                        lng: place.lon,
                        placeLabel: place.name,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.pastelPeriwinkle.withValues(alpha: 0.35)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.pastelPeriwinkle.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.pastelPeriwinkle),
                            const SizedBox(width: 5),
                            Text(
                              '${place.name} · ${distance.toStringAsFixed(1)} km',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentPeriwinkleDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 28),

            UserFavoritesSection(
              favorites: _userFavorites.map((offer) => FavoriteStoreItem(
                id: offer.id ?? '',
                label: offer.title,
                shortLogo: (offer.merchant?.name ?? 'Unknown').substring(0, 2).toUpperCase(),
                bg: const Color(0xFF1E6B3A),
                fg: Colors.white,
              )).toList(),
              onFavoriteTap: (item) => _navigateToResults(item.label.replaceAll('\n', ' ')),
            ),

            const SizedBox(height: 28),

            StoresNearYouSlider(
              stores: _storesNearYou,
              onStoreTap: (store) => _navigateToResults(store.name),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
