import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/search/presentation/bloc/search_bloc.dart';
import 'package:entertainer/features/home/presentation/widgets/user_favorites_section.dart';
import 'package:entertainer/features/home/presentation/widgets/stores_near_you_slider.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'search_results_page.dart';

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

  final List<String> _categories = [
    'Restaurants',
    'Grocery',
    'Drinks',
    'Dining',
    'Hotels',
    'Activities',
  ];

  final List<String> _recentSearches = [
    'Burgers',
    'Tribes',
    'Pizza',
    'Coffee',
    'Thamel',
  ];

  final List<String> _locationAreas = [
    'Downtown',
    'Durbar Marg',
    'Thamel',
    'Jhamsikhel',
    'Bela Vista',
    'Kathmandu Center',
    'Lalitpur',
  ];

  final List<FavoriteStoreItem> _userFavorites = const [
    FavoriteStoreItem(
      id: '1',
      label: 'Usina Pasta\nHouse',
      shortLogo: 'USINA',
      bg: Color(0xFFF7D417),
      fg: Color(0xFF222222),
    ),
    FavoriteStoreItem(
      id: '2',
      label: 'Quiero Café\n& Bistro',
      shortLogo: 'Q',
      bg: Color(0xFF1C1C1C),
      fg: Colors.white,
    ),
    FavoriteStoreItem(
      id: '3',
      label: 'Saúde Organic\nJuices',
      shortLogo: 'Saúde',
      bg: Color(0xFF6B2068),
      fg: Colors.white,
    ),
    FavoriteStoreItem(
      id: '4',
      label: 'Japesca\nSushi Bar',
      shortLogo: 'Japesca',
      bg: Color(0xFFF08A24),
      fg: Colors.white,
    ),
    FavoriteStoreItem(
      id: '5',
      label: 'Oak Artisan\nBurritos',
      shortLogo: 'Oak',
      bg: Color(0xFFE8202A),
      fg: Colors.white,
    ),
  ];

  final List<StoreItem> _storesNearYou = const [
    StoreItem(
      id: '1',
      name: 'Galeto Mamma Mia - Bela Vista',
      logoText: 'GALETO\nMAMMA MIA',
      logoBg: Color(0xFF1E6B3A),
      logoFg: Colors.white,
      category: 'Italian',
      distance: '0.5 km',
      time: '30-40 min',
      price: '\$13.50',
      sponsored: true,
    ),
    StoreItem(
      id: '2',
      name: 'Canto do Sabor Kitchen & Grill',
      logoText: 'CANTO\nSABOR',
      logoBg: Color(0xFF111111),
      logoFg: Colors.white,
      category: 'Home Cooking',
      distance: '1.1 km',
      time: '40-50 min',
      price: 'Free',
      sponsored: true,
      freeDelivery: true,
      freeFrom: 'Free delivery on orders over \$25',
    ),
    StoreItem(
      id: '3',
      name: 'Jeronimo Burger & Fries',
      logoText: 'JERONIMO',
      logoBg: Color(0xFFF7C325),
      logoFg: Color(0xFF222222),
      category: 'Fast Food',
      distance: '0.4 km',
      time: '25-35 min',
      price: '\$9.90',
      verified: true,
    ),
    StoreItem(
      id: '4',
      name: 'Tribes Restaurant - Downtown',
      logoText: 'TRIBES',
      logoBg: Color(0xFF0053DB),
      logoFg: Colors.white,
      category: 'Dining',
      distance: '1.2 km',
      time: '20-30 min',
      price: '\$15.00',
      sponsored: true,
    ),
    StoreItem(
      id: '5',
      name: 'Green Bowl Healthy Salads',
      logoText: 'GREEN',
      logoBg: Color(0xFF10B981),
      logoFg: Colors.white,
      category: 'Healthy',
      distance: '2.5 km',
      time: '15-25 min',
      price: '\$12.00',
      freeDelivery: true,
      freeFrom: 'Free Delivery',
    ),
    StoreItem(
      id: '6',
      name: 'Himalayan Java Coffee',
      logoText: 'JAVA',
      logoBg: Color(0xFF8B5CF6),
      logoFg: Colors.white,
      category: 'Coffee',
      distance: '0.8 km',
      time: '10-20 min',
      price: '\$8.50',
      verified: true,
    ),
  ];

  void _navigateToResults(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(query: query),
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
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return GestureDetector(
                    onTap: () => _navigateToResults(category),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.softCardShadow,
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
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

            // Location Areas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Search By Location Area',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _locationAreas.map((location) {
                  return InkWell(
                    onTap: () => _navigateToResults(location),
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
                            location,
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
              favorites: _userFavorites,
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
    );
  }
}
