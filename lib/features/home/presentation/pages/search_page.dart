import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import '../bloc/search_bloc.dart';
import '../widgets/user_favorites_section.dart';
import '../widgets/stores_near_you_slider.dart';
import 'map_discovery_page.dart';
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
      backgroundColor: const Color(0xFFD3E4FE),
      body: Stack(
        children: [
          // Background ambient glow blobs
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            top: 280,
            right: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF346EF6).withValues(alpha: 0.15),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              children: [
                // 1. Search Bar with Map Toggle Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 20,
                          blur: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          color: Colors.white.withValues(alpha: 0.85),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF0053DB), size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onSubmitted: _navigateToResults,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search restaurants, stores, locations...',
                                    hintStyle: GoogleFonts.inter(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      fontSize: 13.5,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
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
                      const SizedBox(width: 10),
                      // Map Toggle Button
                      GlassContainer(
                        borderRadius: 20,
                        blur: 16,
                        padding: EdgeInsets.zero,
                        color: Colors.white.withValues(alpha: 0.85),
                        border: Border.all(
                          color: const Color(0xFF346EF6).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0053DB).withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.map_rounded, color: Colors.white, size: 24),
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
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Category Chips Below Search Bar
                SizedBox(
                  height: 38,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.inter(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Recent Searches Section
                if (_recentSearches.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Searches',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: const Color(0xFF0053DB),
                              fontWeight: FontWeight.w600,
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.history_rounded, size: 14, color: Colors.black54),
                                const SizedBox(width: 6),
                                Text(
                                  term,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
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

                // 4. Search By Location Area Header & Tags
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Search By Location Area',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF346EF6).withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF346EF6).withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF346EF6)),
                              const SizedBox(width: 5),
                              Text(
                                location,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0053DB),
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

                // 5. My Favorites Section (Positioned ABOVE Stores Near You)
                UserFavoritesSection(
                  favorites: _userFavorites,
                  onFavoriteTap: (item) => _navigateToResults(item.label.replaceAll('\n', ' ')),
                ),

                const SizedBox(height: 28),

                // 6. Stores Near You Section (3 cards per vertical slide in horizontal carousel)
                StoresNearYouSlider(
                  stores: _storesNearYou,
                  onStoreTap: (store) => _navigateToResults(store.name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
