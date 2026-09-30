import 'package:entertainer/core/widgets/glass_container.dart';
import 'package:entertainer/core/widgets/section_gap_normal.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_state.dart';
import 'package:entertainer/features/home/presentation/pages/offer_detail_page.dart';
import 'package:entertainer/features/home/presentation/pages/category_offers_page.dart';
import 'package:entertainer/features/home/presentation/widgets/trending_offers_card.dart';
import 'package:entertainer/features/home/presentation/widgets/category_card.dart';
import 'package:entertainer/features/home/presentation/widgets/hero_offer_slider.dart';
import 'package:entertainer/features/home/presentation/widgets/user_reviews_slider.dart';
import 'package:entertainer/features/home/presentation/widgets/featured_offers_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _HomeView extends StatelessWidget {
  final User user;

  const _HomeView({required this.user});

  @override
  Widget build(BuildContext context) {
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

                    // Search & Filter Glass Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassContainer(
                        borderRadius: 18,
                        blur: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: Colors.white.withValues(alpha: 0.7),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: Color(0xFF346EF6), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Search restaurants, cafes, hotels...",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF346EF6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.tune_rounded, color: Color(0xFF0053DB), size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 1. Hero Offer Slider
                    const HeroOfferSlider(
                      images: [
                        'https://img.magnific.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
                        'https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/01/12/12/healthy-avo-food.jpg',
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-GyDbcO4oFC8rngIjIlp4oHrvISS-xUkIpj5TUFqB9PYhco-8q06vFkAy&s=10',
                        'https://img.etimg.com/thumb/width-1200,height-1200,imgsize-1566631,resizemode-75,msid-128680152/news/new-updates/street-food-without-the-guilt-famous-cardiologist-shares-5-tasty-picks-that-are-healthy-and-easy-on-your-pocket.jpg',
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUtskxtcRQKgsVrqfUKwTwVBdzh6RnQfL2nRsFLOgBg67v0_AL5SoPfnh6&s=10',
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
                          "image": "https://img.magnific.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80"
                        },
                        {
                          "hotelName": "Green Bowl",
                          "distanceFromUser": "2.5 km away",
                          "highlightTag": "Healthy",
                          "location": "Kathmandu",
                          "image": "https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/01/12/12/healthy-avo-food.jpg"
                        },
                        {
                          "hotelName": "Spicy Hub",
                          "distanceFromUser": "3.1 km away",
                          "highlightTag": "Local",
                          "location": "Lalitpur",
                          "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-GyDbcO4oFC8rngIjIlp4oHrvISS-xUkIpj5TUFqB9PYhco-8q06vFkAy&s=10"
                        },
                        {
                          "hotelName": "Urban Bites",
                          "distanceFromUser": "4.0 km away",
                          "highlightTag": "Street Food",
                          "location": "Bhaktapur",
                          "image": "https://img.etimg.com/thumb/width-1200,height-1200,imgsize-1566631,resizemode-75,msid-128680152/news/new-updates/street-food-without-the-guilt-famous-cardiologist-shares-5-tasty-picks-that-are-healthy-and-easy-on-your-pocket.jpg"
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
                          "image": "https://img.magnific.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80"
                        },
                        {
                          "hotelName": "Himalayan Java",
                          "distanceFromUser": "0.8 km",
                          "highlightTag": "Coffee",
                          "location": "Durbar Marg",
                          "image": "https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/01/12/12/healthy-avo-food.jpg"
                        },
                        {
                          "hotelName": "Roadhouse Cafe",
                          "distanceFromUser": "2.1 km",
                          "highlightTag": "BOGOF",
                          "location": "Jhamsikhel",
                          "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-GyDbcO4oFC8rngIjIlp4oHrvISS-xUkIpj5TUFqB9PYhco-8q06vFkAy&s=10"
                        },
                        {
                          "hotelName": "Bhojan Griha",
                          "distanceFromUser": "3.4 km",
                          "highlightTag": "Cultural",
                          "location": "Dillibazar",
                          "image": "https://img.etimg.com/thumb/width-1200,height-1200,imgsize-1566631,resizemode-75,msid-128680152/news/new-updates/street-food-without-the-guilt-famous-cardiologist-shares-5-tasty-picks-that-are-healthy-and-easy-on-your-pocket.jpg"
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
