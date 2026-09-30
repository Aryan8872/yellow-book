import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import '../bloc/offer_detail_bloc.dart';
import '../widgets/story_viewer_modal.dart';

class OfferDetailPage extends StatelessWidget {
  final Map<String, String> offer;

  const OfferDetailPage({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OfferDetailBloc(),
      child: _OfferDetailView(offer: offer),
    );
  }
}

class _OfferDetailView extends StatefulWidget {
  final Map<String, String> offer;

  const _OfferDetailView({required this.offer});

  @override
  State<_OfferDetailView> createState() => _OfferDetailViewState();
}

class _OfferDetailViewState extends State<_OfferDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _imageSliderController = PageController();

  final List<String> _sliderImages = [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=800&q=80',
  ];

  final List<Map<String, String>> _highlights = [
    {
      "title": "Chef's Special",
      "image": "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=300&q=80"
    },
    {
      "title": "Ambiance",
      "image": "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=300&q=80"
    },
    {
      "title": "Cocktails",
      "image": "https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=300&q=80"
    },
    {
      "title": "Desserts",
      "image": "https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=300&q=80"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imageSliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final hotelName = offer['hotelName'] ?? 'Tribes Restaurant';
    final location = offer['location'] ?? 'The Dubai Mall';
    final distance = offer['distanceFromUser'] ?? '1.2 km away';
    final tag = offer['highlightTag'] ?? 'BOGOF';

    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<OfferDetailBloc, OfferDetailState>(
      listener: (context, state) {
        if (state is OfferDetailInitial && state.isStoryActive && state.activeVideoUrl != null) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.8),
            builder: (_) => StoryViewerModal(
              mediaUrl: state.activeVideoUrl!,
              title: hotelName,
              onClose: () {
                Navigator.of(context).pop();
                context.read<OfferDetailBloc>().add(const CloseStory());
              },
            ),
          );
        }
      },
      builder: (context, state) {
        final currentState = state is OfferDetailInitial ? state : const OfferDetailInitial();

        return Scaffold(
          backgroundColor: const Color(0xFFD3E4FE),
          body: Stack(
            children: [
              // 1. Background Image Slider Banner
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: screenHeight * 0.55,
                child: Stack(
                  children: [
                    // Interactive PageView Slider
                    PageView.builder(
                      controller: _imageSliderController,
                      physics: const PageScrollPhysics(),
                      itemCount: _sliderImages.length,
                      onPageChanged: (index) {
                        context.read<OfferDetailBloc>().add(ImageChanged(index));
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          _sliderImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFD3E4FE),
                            child: const Center(
                              child: Icon(Icons.restaurant, size: 50, color: Color(0xFF346EF6)),
                            ),
                          ),
                        );
                      },
                    ),

                    // Top and Bottom Soft Vignette Gradients (IgnorePointer so gestures hit PageView)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                                const Color(0xFF0053DB).withValues(alpha: 0.35),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Frosted Glass Action Buttons (Back, Favorite, Share)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GlassContainer(
                              borderRadius: 20,
                              blur: 16,
                              padding: EdgeInsets.zero,
                              color: Colors.white.withValues(alpha: 0.8),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            Row(
                              children: [
                                GlassContainer(
                                  borderRadius: 20,
                                  blur: 16,
                                  padding: EdgeInsets.zero,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  child: IconButton(
                                    icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFFEF4444)),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GlassContainer(
                                  borderRadius: 20,
                                  blur: 16,
                                  padding: EdgeInsets.zero,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  child: IconButton(
                                    icon: const Icon(Icons.share_outlined, color: Colors.black87),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Image Slider Dots (FLOAT DIRECTLY ON THE IMAGE SLIDER WITH FROSTED CAPSULE)
                    Positioned(
                      bottom: screenHeight * 0.12,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                _sliderImages.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: currentState.currentImageIndex == index ? 22 : 7,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: currentState.currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. DRAGGABLE FLAT + GLASS DETAIL SHEET
              DraggableScrollableSheet(
                initialChildSize: 0.56,
                minChildSize: 0.48,
                maxChildSize: 0.94,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF).withValues(alpha: 0.92),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0053DB).withValues(alpha: 0.12),
                          blurRadius: 28,
                          offset: const Offset(0, -6),
                        ),
                      ],
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          children: [
                            // Drag Handle
                            const SizedBox(height: 12),
                            Center(
                              child: Container(
                                width: 44,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title & Tags in Glass Card
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          hotelName,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF346EF6).withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Location & Distance
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFF346EF6)),
                                      const SizedBox(width: 4),
                                      Text(
                                        location,
                                        style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 14),
                                      const Icon(Icons.directions_walk_rounded, size: 15, color: Color(0xFF10B981)),
                                      const SizedBox(width: 4),
                                      Text(
                                        distance,
                                        style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),

                                  // Highlights Section (Instagram Story-like frosted rings)
                                  const Text(
                                    'Highlights & Ambiance',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 85,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _highlights.length,
                                      itemBuilder: (context, index) {
                                        final highlight = _highlights[index];
                                        return GestureDetector(
                                          onTap: () {
                                            context.read<OfferDetailBloc>().add(OpenStory(highlight['image']!));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 14),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(2.5),
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [Color(0xFF0053DB), Color(0xFF346EF6), Color(0xFF818CF8)],
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    backgroundImage: NetworkImage(highlight['image']!),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  highlight['title']!,
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Modern Frosted-Glass Capsule TabBar (Seamless blend like bottom navbar)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0053DB).withValues(alpha: 0.06),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.70),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.85),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: TabBar(
                                        controller: _tabController,
                                        indicator: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF346EF6).withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        labelColor: Colors.white,
                                        unselectedLabelColor: Colors.black54,
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0.2,
                                        ),
                                        unselectedLabelStyle: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                        dividerColor: Colors.transparent,
                                        tabs: const [
                                          Tab(text: 'Offers (3)'),
                                          Tab(text: 'About'),
                                          Tab(text: 'Reviews'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // TabBar Content Views
                            SizedBox(
                              height: 480,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _OffersTab(offer: offer),
                                  _AboutTab(offer: offer),
                                  const _ReviewsTab(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 90), // Bottom button clearance
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 3. Floating Bottom Action Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0053DB).withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Redemption triggered! Enter Merchant PIN to verify.'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0053DB),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Redeem BOGOF Offer (Dual PIN)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OffersTab extends StatelessWidget {
  final Map<String, String> offer;

  const _OffersTab({required this.offer});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildOfferCard(
          context,
          title: 'Buy 1 Get 1 Free Main Course',
          subtitle: 'Valid on all pastas, steaks, signature entrees & pizzas.',
          redemptionsLeft: '3 remaining',
          validity: 'Valid 7 days a week',
        ),
        const SizedBox(height: 12),
        _buildOfferCard(
          context,
          title: 'Buy 1 Get 1 Free Appetizer / Starter',
          subtitle: 'Valid on soups, salads, bruschetta, and tapas.',
          redemptionsLeft: '3 remaining',
          validity: 'Valid 7 days a week',
        ),
        const SizedBox(height: 12),
        _buildOfferCard(
          context,
          title: 'Buy 1 Get 1 Free House Beverage / Dessert',
          subtitle: 'Valid on all non-alcoholic mocktails and signature desserts.',
          redemptionsLeft: '3 remaining',
          validity: 'Valid Sunday to Thursday',
        ),
      ],
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String redemptionsLeft,
    required String validity,
  }) {
    return GlassContainer(
      borderRadius: 20,
      blur: 14,
      padding: const EdgeInsets.all(16),
      color: Colors.white.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text(
                      'BOGOF UNLOCKED',
                      style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.local_activity_rounded, size: 14, color: Color(0xFF0053DB)),
                  const SizedBox(width: 4),
                  Text(
                    redemptionsLeft,
                    style: const TextStyle(color: Color(0xFF0053DB), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.3),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFD3E4FE)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 13, color: Colors.black45),
                  const SizedBox(width: 4),
                  Text(
                    validity,
                    style: const TextStyle(fontSize: 11.5, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_open_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Redeem',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
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

class _AboutTab extends StatelessWidget {
  final Map<String, String> offer;

  const _AboutTab({required this.offer});

  @override
  Widget build(BuildContext context) {
    final hotelName = offer['hotelName'] ?? 'Merchant';
    final location = offer['location'] ?? 'City Center';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        GlassContainer(
          borderRadius: 18,
          blur: 14,
          padding: const EdgeInsets.all(16),
          color: Colors.white.withValues(alpha: 0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About the Merchant',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                '$hotelName is one of the premier lifestyle dining destinations located at $location. Known for its exceptional ambiance, world-class culinary expertise, and unmatched guest satisfaction.',
                style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Google Maps Location Preview Card
        GlassContainer(
          borderRadius: 18,
          blur: 14,
          padding: const EdgeInsets.all(16),
          color: Colors.white.withValues(alpha: 0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location & Directions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3E4FE).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_rounded, size: 36, color: Color(0xFF0053DB)),
                      const SizedBox(height: 4),
                      Text(
                        '$location, City District',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      const Text('Tap to view map coordinates', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassContainer(
          borderRadius: 18,
          blur: 14,
          padding: const EdgeInsets.all(16),
          color: Colors.white.withValues(alpha: 0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Operating Hours & Rules',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Sunday – Thursday: 10:00 AM – 11:00 PM\n• Friday – Saturday: 10:00 AM – 12:00 AM\n• Valid for dine-in only.\n• Advance table reservation is recommended.',
                style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        GlassContainer(
          borderRadius: 18,
          blur: 14,
          padding: const EdgeInsets.all(16),
          color: Colors.white.withValues(alpha: 0.8),
          child: Row(
            children: [
              const Text(
                '4.8',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (_) => const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16)),
                  ),
                  const SizedBox(height: 2),
                  const Text('Based on 124 verified redemptions', style: TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildReviewCard('Aarav Sharma', 'Amazing experience! Used the BOGOF main course offer and saved a lot. Highly recommended.'),
        const SizedBox(height: 10),
        _buildReviewCard('Priya Karki', 'Great food and wonderful ambiance. The merchant verified the PIN instantly without any hassle.'),
      ],
    );
  }

  Widget _buildReviewCard(String name, String comment) {
    return GlassContainer(
      borderRadius: 16,
      blur: 14,
      padding: const EdgeInsets.all(14),
      color: Colors.white.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              Row(children: List.generate(5, (_) => const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 12))),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: const TextStyle(color: Colors.black54, fontSize: 12.5, height: 1.3)),
        ],
      ),
    );
  }
}
