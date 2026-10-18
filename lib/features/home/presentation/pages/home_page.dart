import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/section_gap_normal.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/pages/login_page.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_event.dart';
import 'package:entertainer/features/home/presentation/bloc/home_state.dart';
import 'package:entertainer/features/home/presentation/widgets/category_card.dart';
// CategoryCardFromApi is exported from the same file
import 'package:entertainer/features/home/presentation/widgets/user_reviews_slider.dart';
import 'package:entertainer/features/home/presentation/widgets/location_selection_modal.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_state.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
        ),
        BlocProvider(
          create: (_) => getIt<OffersBloc>()
            ..add(const FetchOffersRequested(
              page: 1,
              limit: 20,
              refresh: true,
            )),
        ),
      ],
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
                    builder: (_) =>
                        CategoryOffersPage(categoryName: homeState.categoryName),
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

class _HomeViewState extends State<_HomeView>
    with SingleTickerProviderStateMixin {
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
    if (offset > 160 && !_showMapFab) {
      setState(() => _showMapFab = true);
      _fabAnimController.forward();
    } else if (offset <= 160 && _showMapFab) {
      setState(() => _showMapFab = false);
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
    final selected = await LocationSelectionModal.show(context,
        currentLocation: _currentLocation);
    if (selected != null && mounted) {
      setState(() => _currentLocation = selected);
      // Re-fetch offers filtered by the newly selected location
      context.read<OffersBloc>().add(FetchOffersRequested(
        location: selected,
        page: 1,
        limit: 20,
        refresh: true,
      ));
    }
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    _scrollController.dispose();
    _fabAnimController.dispose();
    super.dispose();
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
              // ── 1. Sticky App Header ───────────────────────────────────
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                backgroundColor: AppTheme.canvasBg,
                expandedHeight: 84,
                collapsedHeight: 74,
                flexibleSpace: Container(
                  color: AppTheme.canvasBg,
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location selector
                      InkWell(
                        onTap: _openLocationSelector,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.place_rounded,
                                      size: 15,
                                      color: AppTheme.accentPeriwinkleDark),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CURRENT LOCATION',
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
                                    constraints:
                                        const BoxConstraints(maxWidth: 190),
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
                                      border: Border.all(
                                          color: AppTheme.borderLight,
                                          width: 0.8),
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

                      // Notification + Avatar
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
                              icon: const Icon(Icons.notifications_none_rounded,
                                  color: AppTheme.textPrimary, size: 21),
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
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'U',
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

              // ── 2. Page Content ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // 2.1 Hero card — driven by live BlocBuilder
                    _HeroOfferCard(location: _currentLocation),

                    const SizedBox(height: 20),

                    // 2.2 Quick actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickActionButton(
                              icon: Icons.qr_code_scanner_rounded,
                              label: 'Redeem',
                              onTap: () {}),
                          _buildQuickActionButton(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Vouchers',
                              onTap: () {}),
                          _buildQuickActionButton(
                            icon: Icons.map_rounded,
                            label: 'Nearby',
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const MapDiscoveryPage()));
                            },
                          ),
                          _buildQuickActionButton(
                              icon: Icons.more_horiz_rounded,
                              label: 'More',
                              onTap: () {}),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // 2.3 Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppTheme.softCardShadow,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: AppTheme.textPrimary, size: 22),
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
                                  hintText:
                                      'Search restaurants, cafes, salons...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2.4 Trending — from OffersBloc (real API data)
                    BlocBuilder<OffersBloc, OffersState>(
                      builder: (context, state) {
                        if (state is OffersLoaded && state.offers.isNotEmpty) {
                          return TrendingOffersCard(
                            title:
                                'Trending in ${_currentLocation.split(',').first.trim()}',
                            actionLabel: 'Change',
                            onActionTap: _openLocationSelector,
                            offers: state.offers.take(6).toList(),
                          );
                        }
                        if (state is OffersLoading) {
                          return _LoadingSection(
                              title:
                                  'Trending in ${_currentLocation.split(',').first.trim()}',
                              height: 275);
                        }
                        // Error or empty: graceful fallback
                        return const SizedBox.shrink();
                      },
                    ),

                    const SectionGapNormal(),

                    // 2.5 Category cards — real data from HomeBloc
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, homeState) {
                        if (homeState is HomeLoaded &&
                            homeState.feedData.categories.isNotEmpty) {
                          final categories = homeState.feedData.categories;
                          return CategoryCardFromApi(
                            categories: categories,
                            onCategoryTap: (categoryName) {
                              context.read<OffersBloc>().add(
                                    FetchOffersRequested(
                                      category: categoryName,
                                      location: _currentLocation,
                                      page: 1,
                                      limit: 20,
                                      refresh: true,
                                    ),
                                  );
                            },
                          );
                        }
                        // Fallback: static categories while loading
                        return CategoryCard(
                          category: const {
                            'Dining': {'count': '34'},
                            'Wellness': {'count': '18'},
                            'Activities': {'count': '12'},
                            'Hotels': {'count': '24'},
                            'Nightlife': {'count': '15'},
                          },
                        );
                      },
                    ),

                    const SectionGapNormal(),

                    // 2.6 Popular Deals — from OffersBloc (featured offers)
                    BlocBuilder<OffersBloc, OffersState>(
                      builder: (context, state) {
                        if (state is OffersLoaded && state.offers.isNotEmpty) {
                          final featured = state.offers
                              .where((o) => o.isFeatured)
                              .toList();
                          final showOffers = featured.isNotEmpty
                              ? featured
                              : state.offers.skip(3).take(5).toList();
                          if (showOffers.isEmpty) return const SizedBox.shrink();
                          return TrendingOffersCard(
                            title: 'Popular Deals',
                            offers: showOffers,
                          );
                        }
                        if (state is OffersLoading) {
                          return _LoadingSection(
                              title: 'Popular Deals', height: 275);
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SectionGapNormal(),

                    // 2.7 Featured Collections — from OffersBloc
                    BlocBuilder<OffersBloc, OffersState>(
                      builder: (context, state) {
                        if (state is OffersLoaded && state.offers.isNotEmpty) {
                          return FeaturedOffersSlider(
                              offers: state.offers.toList());
                        }
                        if (state is OffersLoading) {
                          return _LoadingSection(
                              title: 'Featured Collections', height: 190);
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SectionGapNormal(),

                    // 2.8 User Reviews — static (no API yet)
                    const UserReviewsSlider(
                      reviews: [
                        {
                          'userName': 'Aarav Sharma',
                          'userImage':
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                          'savedAmount': 'Saved NPR 2,400 on BOGO',
                          'reviewText':
                              'Used the Buy 1 Get 1 Free main course offer. The service was top notch and savings were incredible!',
                          'personalPick': 'Burger House',
                        },
                        {
                          'userName': 'Priya Karki',
                          'userImage':
                              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
                          'savedAmount': 'Saved NPR 1,200 on Lunch',
                          'reviewText':
                              'Great healthy salads. The app made redemption seamless. Highly recommend OfferNepal!',
                          'personalPick': 'Spa Wellness',
                        },
                      ],
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),

          // ── 3. Map FAB ────────────────────────────────────────────────
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
                          MaterialPageRoute(
                              builder: (_) => const MapDiscoveryPage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'View on Map',
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

// ── Hero card: shows the top featured offer from the API ─────────────────────
class _HeroOfferCard extends StatelessWidget {
  final String location;
  const _HeroOfferCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        OfferEntity? hero;
        if (state is OffersLoaded && state.offers.isNotEmpty) {
          hero = state.offers
              .firstWhere((o) => o.isFeatured, orElse: () => state.offers.first);
        }

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
                  // Top ochre banner
                  Container(
                    color: const Color(0xFFFFCC70),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.darkAnchor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '🔥 TRENDING',
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
                              'Latest Verified Offers',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.darkAnchor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Updated Today',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkAnchor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom lavender plate
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      hero != null &&
                                              hero.discountPercentage != null
                                          ? '${hero.discountPercentage}% OFF EXCLUSIVE'
                                          : 'BUY 1 GET 1 FREE EXCLUSIVE',
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
                                    hero?.merchantName ??
                                        hero?.merchant?.name ??
                                        'OfferNepal Premium',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.darkAnchor,
                                      letterSpacing: -0.6,
                                      height: 1.15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Offer image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: hero != null
                                  ? CachedNetworkImage(
                                      imageUrl: hero.imageUrl ??
                                          (hero.images.isNotEmpty
                                              ? hero.images.first
                                              : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=300&q=80'),
                                      width: 82,
                                      height: 82,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        width: 82,
                                        height: 82,
                                        color: AppTheme.surfaceSubtle,
                                        child: const Icon(Icons.restaurant,
                                            color: AppTheme.darkAnchor),
                                      ),
                                    )
                                  : Container(
                                      width: 82,
                                      height: 82,
                                      color: AppTheme.surfaceSubtle,
                                      child: const Center(
                                          child: CircularProgressIndicator()),
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
                                const Icon(Icons.location_on_rounded,
                                    size: 14, color: AppTheme.darkAnchor),
                                const SizedBox(width: 4),
                                Text(
                                  hero?.merchant?.branches.isNotEmpty == true
                                      ? '${hero!.merchant!.branches.first.city}'
                                      : location.split(',').first.trim(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.darkAnchor
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            if (hero != null)
                              InkWell(
                                onTap: () {
                                  context
                                      .read<HomeBloc>()
                                      .add(OfferCardSelected(hero!));
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkAnchor,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.darkAnchor
                                            .withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Claim Deal',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 14),
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
      },
    );
  }
}

// ── Skeleton loading placeholder for offer sections ───────────────────────────
class _LoadingSection extends StatelessWidget {
  final String title;
  final double height;
  const _LoadingSection({required this.title, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (_, __) => Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderLight, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
