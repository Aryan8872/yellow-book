import 'package:entertainer/core/widgets/glass_container.dart';
import 'package:entertainer/core/widgets/section_gap_normal.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_state.dart';
import 'package:entertainer/features/home/presentation/pages/offer_detail_page.dart';
import 'package:entertainer/features/home/presentation/pages/category_offers_page.dart';
import 'package:entertainer/features/home/presentation/pages/search_results_page.dart';
import 'package:entertainer/features/home/presentation/widgets/trending_offers_card.dart';
import 'package:entertainer/features/home/presentation/widgets/category_card.dart';
import 'package:entertainer/features/home/presentation/widgets/hero_offer_slider.dart';
import 'package:entertainer/features/home/presentation/widgets/user_reviews_slider.dart';
import 'package:entertainer/features/home/presentation/widgets/featured_offers_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_event.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/pages/login_page.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: MultiBlocListener(
        listeners: [
          // Auth BLoC Listener for Logout
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
          // Home BLoC Listener for Redirection to Offer Details
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

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _homeSearchController = TextEditingController();

  void _navigateToResults(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(query: query),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String selectedSort = 'Distance';
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filter & Sort Offers',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Text('Sort By', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Distance', 'Rating', 'Popularity', 'Newest'].map((sort) {
                  final isSelected = selectedSort == sort;
                  return ChoiceChip(
                    label: Text(sort),
                    selected: isSelected,
                    selectedColor: const Color(0xFF346EF6),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    onSelected: (val) {
                      Navigator.pop(context);
                      _navigateToResults(sort);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToResults(_homeSearchController.text.isEmpty ? 'All' : _homeSearchController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF346EF6),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Apply Filters', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: const Color(0xFFD3E4FE),
      body: Stack(
        children: [
          // Ambient soft background glow blobs
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF346EF6).withValues(alpha: 0.15),
              ),
            ),
          ),

          // Main Scrollable Feed
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Frosted Glass Sticky App Bar
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                backgroundColor: const Color(0xFFD3E4FE).withValues(alpha: 0.85),
                expandedHeight: 80,
                collapsedHeight: 70,
                flexibleSpace: Container(
                  color: const Color(0xFFD3E4FE).withValues(alpha: 0.97),
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome back 👋",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            user.fullName.isNotEmpty ? user.fullName : "OfferNepal Club",
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Savings quick badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.savings_rounded, color: Color(0xFF10B981), size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "\$680",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Logout action in glass pill
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded, color: Colors.black87, size: 20),
                              onPressed: () {
                                context.read<AuthBloc>().add(const LogoutRequested());
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Content Sliver
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Interactive Working Search & Filter Glass Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassContainer(
                        borderRadius: 18,
                        blur: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: Colors.white.withValues(alpha: 0.75),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: Color(0xFF346EF6), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _homeSearchController,
                                onSubmitted: _navigateToResults,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Search restaurants, cafes, hotels...",
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: Colors.black.withValues(alpha: 0.4),
                                    fontWeight: FontWeight.normal,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            // Filter Button
                            GestureDetector(
                              onTap: () => _showFilterModal(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF346EF6).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune_rounded, color: Color(0xFF0053DB), size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 1. Hero Offer Slider (With pagination dots indicator)
                    const HeroOfferSlider(
                      images: [
                        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
                        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                        'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=800&q=80',
                        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
                        'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=800&q=80',
                      ],
                    ),
                    const SectionGapNormal(),

                    // 2. Curated Categories Section
                    CategoryCard(
                      category: {
                        "Nearby": {"image": "assets/category/nearby.png"},
                        "Dining": {"image": "assets/category/dining.png"},
                        "Activities": {"image": "assets/category/activities.png"},
                        "Offers": {"image": "assets/category/discounts.png"},
                        "Hotels": {"image": "assets/category/hotels.png"},
                      },
                    ),
                    const SectionGapNormal(),

                    // 3. Trending Offers Section (with BLoC Redirection Event)
                    const TrendingOffersCard(
                      offers: [
                        {
                          "hotelName": "Tribes",
                          "distanceFromUser": "1.2 km away",
                          "highlightTag": "BOGOF",
                          "location": "The Dubai Mall",
                          "image": "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Green Bowl",
                          "distanceFromUser": "2.5 km away",
                          "highlightTag": "Healthy",
                          "location": "Kathmandu",
                          "image": "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Spicy Hub",
                          "distanceFromUser": "3.1 km away",
                          "highlightTag": "Local",
                          "location": "Lalitpur",
                          "image": "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Urban Bites",
                          "distanceFromUser": "4.0 km away",
                          "highlightTag": "Street Food",
                          "location": "Bhaktapur",
                          "image": "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=600&q=80"
                        }
                      ],
                    ),
                    const SectionGapNormal(),

                    // 4. Featured Offers Section (2 cards per slide layout)
                    const FeaturedOffersSlider(
                      offers: [
                        {
                          "hotelName": "Paang Asian",
                          "distanceFromUser": "1.5 km",
                          "highlightTag": "BOGOF",
                          "location": "Thamel",
                          "image": "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Himalayan Java",
                          "distanceFromUser": "0.8 km",
                          "highlightTag": "Coffee",
                          "location": "Durbar Marg",
                          "image": "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Roadhouse Cafe",
                          "distanceFromUser": "2.1 km",
                          "highlightTag": "BOGOF",
                          "location": "Jhamsikhel",
                          "image": "https://images.unsplash.com/photo-1578474846511-04ba529f0b88?auto=format&fit=crop&w=600&q=80"
                        },
                        {
                          "hotelName": "Bhojan Griha",
                          "distanceFromUser": "3.4 km",
                          "highlightTag": "Cultural",
                          "location": "Dillibazar",
                          "image": "https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&q=80"
                        },
                      ],
                    ),
                    const SectionGapNormal(),

                    // 5. User Reviews Slider Section
                    const UserReviewsSlider(
                      reviews: [
                        {
                          "userName": "Aarav Sharma",
                          "userImage": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80",
                          "savedAmount": "Saved \$55 on BOGOF",
                          "reviewText": "Used the Buy 1 Get 1 Free main course at Tribes. The service was top notch and savings were incredible!",
                          "personalPick": "Tribes Restaurant"
                        },
                        {
                          "userName": "Priya Karki",
                          "userImage": "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80",
                          "savedAmount": "Saved \$30 on BOGOF",
                          "reviewText": "Green Bowl is my absolute favorite for healthy salads. The app made redemption so seamless.",
                          "personalPick": "Green Bowl"
                        },
                        {
                          "userName": "Rohan Shrestha",
                          "userImage": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80",
                          "savedAmount": "Saved \$120 on Hotel Stay",
                          "reviewText": "Booked our weekend staycation through OfferNepal. Amazing discounts and instant confirmation.",
                          "personalPick": "Himalayan Resort"
                        },
                      ],
                    ),
                    const SizedBox(height: 100), // clearance for floating navbar
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
