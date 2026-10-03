import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/section_gap_normal.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/pages/login_page.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_state.dart';
import 'package:entertainer/features/home/presentation/widgets/category_card.dart';
import 'package:entertainer/features/home/presentation/widgets/user_reviews_slider.dart';
import 'package:entertainer/features/home/presentation/widgets/location_selection_modal.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';
import 'package:entertainer/features/offer/presentation/pages/category_offers_page.dart';
import 'package:entertainer/features/offer/presentation/widgets/featured_offers_slider.dart';
import 'package:entertainer/features/offer/presentation/widgets/trending_offers_card.dart';
import 'package:entertainer/features/search/presentation/pages/search_results_page.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthInitial) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
          BlocListener<HomeBloc, HomeState>(
            listener: (context, homeState) {
              if (homeState is NavigateToOfferDetail) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OfferDetailPage(offer: homeState.offer),
                  ),
                );
              } else if (homeState is NavigateToCategoryOffers) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryOffersPage(categoryName: homeState.categoryName),
                  ),
                );
              }
            },
          ),
        ],
        child: _HomeView(user: user),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  final User user;

  const _HomeView({required this.user});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> with SingleTickerProviderStateMixin {
  final TextEditingController _homeSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _currentLocation = 'Thamel, Kathmandu';
  bool _showMapFab = false;

  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // When user scrolls down more than 160 pixels, pop up map button with bounce
    if (offset > 160 && !_showMapFab) {
      setState(() {
        _showMapFab = true;
      });
      _fabAnimController.forward();
    } else if (offset <= 160 && _showMapFab) {
      setState(() {
        _showMapFab = false;
      });
      _fabAnimController.reverse();
    }
  }

  void _navigateToResults(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(query: query),
      ),
    );
  }

  Future<void> _openLocationSelector() async {
    final selected = await LocationSelectionModal.show(context, currentLocation: _currentLocation);
    if (selected != null && mounted) {
      setState(() {
        _currentLocation = selected;
      });
    }
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    _scrollController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  // Location offers mock mapping for Kathmandu, Chitwan, Jhapa
  List<Map<String, String>> _getLocationSpecificOffers() {
    final locLower = _currentLocation.toLowerCase();
    if (locLower.contains('chitwan') || locLower.contains('sauraha') || locLower.contains('bharatpur')) {
      return const [
        {
          "hotelName": "Barahi Jungle Lodge",
          "distanceFromUser": "1.5 km away",
          "highlightTag": "BOGOF",
          "location": "Meghauli, Chitwan",
          "image": "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80"
        },
        {
          "hotelName": "Rhino Cafe & Eatery",
          "distanceFromUser": "0.8 km away",
          "highlightTag": "Coffee 1+1",
          "location": "Sauraha, Chitwan",
          "image": "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80"
        },
        {
          "hotelName": "Narayani River Breeze",
          "distanceFromUser": "2.1 km away",
          "highlightTag": "Dinner BOGO",
          "location": "Narayangarh, Chitwan",
          "image": "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80"
        },
      ];
    } else if (locLower.contains('jhapa') || locLower.contains('birtamode') || locLower.contains('damak')) {
      return const [
        {
          "hotelName": "The Kingsbury Hotel",
          "distanceFromUser": "1.0 km away",
          "highlightTag": "BOGOF",
          "location": "Birtamode, Jhapa",
          "image": "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=600&q=80"
        },
        {
          "hotelName": "Red Mud Coffee Damak",
          "distanceFromUser": "0.6 km away",
          "highlightTag": "Coffee 1+1",
          "location": "Damak, Jhapa",
          "image": "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=600&q=80"
        },
        {
          "hotelName": "Eastern Delights Restro",
          "distanceFromUser": "1.8 km away",
          "highlightTag": "50% OFF",
          "location": "Bhadrapur Road, Jhapa",
          "image": "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=600&q=80"
        },
      ];
    } else {
      // Kathmandu / Default
      return const [
        {
          "hotelName": "Tribes Restaurant & Grill",
          "distanceFromUser": "0.8 km away",
          "highlightTag": "BOGOF",
          "location": "Thamel, Kathmandu",
          "image": "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80"
        },
        {
          "hotelName": "Roadhouse Pizzeria",
          "distanceFromUser": "1.2 km away",
          "highlightTag": "Pizza 1+1",
          "location": "Durbar Marg, Kathmandu",
          "image": "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80"
        },
        {
          "hotelName": "Green Bowl Healthy Foods",
          "distanceFromUser": "2.4 km away",
          "highlightTag": "Salad BOGO",
          "location": "Jhamsikhel, Lalitpur",
          "image": "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=600&q=80"
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. App Header with Location Dropdown Selector & Notification & Avatar
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                backgroundColor: AppTheme.canvasBg,
                expandedHeight: 84,
                collapsedHeight: 74,
                flexibleSpace: Container(
                  color: AppTheme.canvasBg,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location Dropdown Selector (Replaces "Hello Explorer")
                      InkWell(
                        onTap: _openLocationSelector,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.place_rounded,
                                    size: 15,
                                    color: AppTheme.accentPeriwinkleDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "CURRENT LOCATION",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textMuted,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 190),
                                    child: Text(
                                      _currentLocation,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: -0.4,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardSurface,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.borderLight, width: 0.8),
                                      boxShadow: AppTheme.softCardShadow,
                                    ),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Notification and Profile Avatar
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.softCardShadow,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary, size: 21),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppTheme.darkPill,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Main Page Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // 2.1 LATEST TRENDING OFFERS HERO (Replacing Total Savings in Home)
                    _buildLatestTrendingHero(context),

                    const SizedBox(height: 20),

                    // 2.2 Quick Action Buttons Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickActionButton(
                            icon: Icons.qr_code_scanner_rounded,
                            label: "Redeem",
                            onTap: () {},
                          ),
                          _buildQuickActionButton(
                            icon: Icons.check_circle_outline_rounded,
                            label: "Vouchers",
                            onTap: () {},
                          ),
                          _buildQuickActionButton(
                            icon: Icons.map_rounded,
                            label: "Nearby",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MapDiscoveryPage()),
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            icon: Icons.more_horiz_rounded,
                            label: "More",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // 2.3 Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _homeSearchController,
                                onSubmitted: _navigateToResults,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Search restaurants, cafes, salons...",
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2.4 TRENDING IN CURRENT LOCATION (Dynamic header & click to change location)
                    TrendingOffersCard(
                      title: "Trending in ${_currentLocation.split(',').first.trim()}",
                      actionLabel: "Change",
                      onActionTap: _openLocationSelector,
                      offers: _getLocationSpecificOffers(),
                    ),

                    const SectionGapNormal(),

                    // 2.5 Curated Categories
                    CategoryCard(
                      category: const {
                        "Dining": {"count": "34"},
                        "Wellness": {"count": "18"},
                        "Activities": {"count": "12"},
                        "Hotels": {"count": "24"},
                        "Nightlife": {"count": "15"},
                      },
                    ),

                    const SectionGapNormal(),

                    // 2.6 Popular Deals
                    const TrendingOffersCard(
                      title: "Popular Deals",
                      offers: [
                        {
                          "hotelName": "Tribes Restaurant",
                          "distanceFromUser": "1.2 km away",
                          "highlightTag": "BOGOF",
                          "location": "Thamel, Kathmandu",
                          "image": "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Green Bowl Healthy",
                          "distanceFromUser": "2.5 km away",
                          "highlightTag": "50% OFF",
                          "location": "Jhamsikhel, Lalitpur",
                          "image": "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Roadhouse Pizzeria",
                          "distanceFromUser": "3.1 km away",
                          "highlightTag": "BOGOF",
                          "location": "Durbar Marg, Kathmandu",
                          "image": "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80"
                        },
                      ],
                    ),

                    const SectionGapNormal(),

                    // 2.7 Featured Collections
                    const FeaturedOffersSlider(
                      offers: [
                        {
                          "hotelName": "Himalayan Java Coffee",
                          "distanceFromUser": "0.8 km",
                          "highlightTag": "Coffee 1+1",
                          "location": "Thamel",
                          "image": "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Trisara Garden",
                          "distanceFromUser": "2.2 km",
                          "highlightTag": "Main 1+1",
                          "location": "Lazimpat",
                          "image": "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Bhojan Griha Cultural",
                          "distanceFromUser": "3.4 km",
                          "highlightTag": "Dinner BOGO",
                          "location": "Dillibazar",
                          "image": "https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "The Chimney Restaurant",
                          "distanceFromUser": "4.1 km",
                          "highlightTag": "Luxury BOGO",
                          "location": "Yak & Yeti",
                          "image": "https://images.unsplash.com/photo-1578474846511-04ba529f0b88?auto=format&fit=crop&w=600&q=80"
                        },
                      ],
                    ),

                    const SectionGapNormal(),

                    // 2.8 User Reviews
                    const UserReviewsSlider(
                      reviews: [
                        {
                          "userName": "Aarav Sharma",
                          "userImage": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80",
                          "savedAmount": "Saved NPR 2,400 on BOGO",
                          "reviewText": "Used the Buy 1 Get 1 Free main course at Tribes. The service was top notch and savings were incredible!",
                          "personalPick": "Tribes Restaurant"
                        },
                        {
                          "userName": "Priya Karki",
                          "userImage": "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80",
                          "savedAmount": "Saved NPR 1,200 on Lunch",
                          "reviewText": "Green Bowl is my absolute favorite for healthy salads. The app made redemption so seamless.",
                          "personalPick": "Green Bowl"
                        },
                      ],
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),

          // 3. BOUNCING MAP POPUP BUTTON (Appears when scrolled down > 160px, disappears when scrolled up)
          Positioned(
            bottom: 30,
            right: 20,
            child: ScaleTransition(
              scale: _fabScaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkAnchor.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: AppTheme.darkPill,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapDiscoveryPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "View on Map",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Signature Hero Card displaying Latest Trending Offers
  Widget _buildLatestTrendingHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9F8EFC).withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Column(
            children: [
              // Top Ochre Plate
              Container(
                color: const Color(0xFFFFCC70),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.darkAnchor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "🔥 TRENDING",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Latest Verified Offers",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkAnchor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Updated Today",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkAnchor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Lavender Hero Plate
              Container(
                color: AppTheme.pastelPeriwinkle,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "BUY 1 GET 1 FREE EXCLUSIVE",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.darkAnchor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Tribes Fine Dining\n& Gourmet Grill",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.darkAnchor,
                                  letterSpacing: -0.6,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=300&q=80",
                            width: 82,
                            height: 82,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 82,
                              height: 82,
                              color: AppTheme.surfaceSubtle,
                              child: const Icon(Icons.restaurant, color: AppTheme.darkAnchor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.darkAnchor),
                            const SizedBox(width: 4),
                            Text(
                              "Thamel, Kathmandu • 0.8 km",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkAnchor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OfferDetailPage(offer: {
                                  'hotelName': 'Tribes Restaurant',
                                  'location': 'Thamel, Kathmandu',
                                  'distanceFromUser': '0.8 km away',
                                  'highlightTag': 'BOGOF',
                                  'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80'
                                }),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppTheme.darkAnchor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.darkAnchor.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Claim Deal",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softCardShadow,
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
