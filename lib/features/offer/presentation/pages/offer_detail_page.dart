import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_state.dart';
import 'package:entertainer/features/offer/presentation/widgets/merchant_pin_redemption_modal.dart';
import 'package:entertainer/features/offer/presentation/widgets/redemption_code_sheet.dart';
import 'package:entertainer/features/offer/presentation/widgets/club_paywall_sheet.dart';
import '../bloc/offer_detail_bloc.dart';
import 'package:entertainer/features/home/presentation/widgets/story_viewer_modal.dart';

// ── Category fallback images ──────────────────────────────────────────────────
const _categoryFallbacks = {
  'DINING':        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
  'WELLNESS':      'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=800&q=80',
  'ENTERTAINMENT': 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=800&q=80',
  'RETAIL':        'https://images.unsplash.com/photo-1472851294608-062f824d29cc?auto=format&fit=crop&w=800&q=80',
  'TRAVEL':        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
  'BEAUTY':        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80',
};

// ── Highlight fallback images ─────────────────────────────────────────────────
const _highlightFallbacks = [
  'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=300&q=80',
  'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=300&q=80',
  'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=300&q=80',
  'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=300&q=80',
  'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=300&q=80',
  'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=300&q=80',
];

// ─────────────────────────────────────────────────────────────────────────────

class OfferDetailPage extends StatelessWidget {
  final OfferEntity offer;

  const OfferDetailPage({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OfferDetailBloc>(create: (context) => OfferDetailBloc()),
        BlocProvider<RedemptionBloc>(create: (context) => getIt<RedemptionBloc>()),
      ],
      child: _OfferDetailView(offer: offer),
    );
  }
}

class _OfferDetailView extends StatefulWidget {
  final OfferEntity offer;

  const _OfferDetailView({required this.offer});

  @override
  State<_OfferDetailView> createState() => _OfferDetailViewState();
}

class _OfferDetailViewState extends State<_OfferDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _imageSliderController = PageController();

  // ── Derive slider images from real entity data ────────────────────────────
  late List<String> _sliderImages;

  // ── Derive highlights from real entity data ───────────────────────────────
  late List<Map<String, String>> _highlights;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Build image list: use api images[], fall back to imageUrl, then category
    final apiImages = widget.offer.images.isNotEmpty
        ? widget.offer.images
        : widget.offer.imageUrl != null
            ? [widget.offer.imageUrl!]
            : [
                _categoryFallbacks[widget.offer.category.name.toUpperCase()] ??
                    _categoryFallbacks['DINING']!
              ];
    _sliderImages = apiImages;

    // Build highlights: labels from API, images from slider images cyclically
    if (widget.offer.highlights.isNotEmpty) {
      _highlights = List.generate(widget.offer.highlights.length, (i) {
        return {
          'title': widget.offer.highlights[i],
          'image': _highlightFallbacks[i % _highlightFallbacks.length],
        };
      });
    } else {
      // Generic fallbacks when no highlights from API
      _highlights = [
        {'title': "Chef's Special", 'image': _highlightFallbacks[0]},
        {'title': 'Ambiance',       'image': _highlightFallbacks[1]},
        {'title': 'Cocktails',      'image': _highlightFallbacks[2]},
        {'title': 'Desserts',       'image': _highlightFallbacks[3]},
      ];
    }
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
    final merchantName = offer.merchantName ?? offer.merchant?.name ?? 'Merchant';
    final branch = offer.merchant?.branches.isNotEmpty == true
        ? offer.merchant!.branches.first
        : null;
    final location = branch != null
        ? '${branch.address}, ${branch.city}'
        : 'Nepal';
    final tag = offer.discountPercentage != null && offer.discountPercentage! > 0
        ? '${offer.discountPercentage}% OFF'
        : 'BOGOF';
    final savingsText = offer.estimatedSavingsNpr > 0
        ? 'Save NPR ${offer.estimatedSavingsNpr}'
        : 'Exclusive Deal';

    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<OfferDetailBloc, OfferDetailState>(
      listener: (context, state) {
        if (state is OfferDetailInitial &&
            state.isStoryActive &&
            state.activeVideoUrl != null) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.8),
            builder: (_) => StoryViewerModal(
              mediaUrl: state.activeVideoUrl!,
              title: merchantName,
              onClose: () {
                Navigator.of(context).pop();
                context.read<OfferDetailBloc>().add(const CloseStory());
              },
            ),
          );
        }
      },
      builder: (context, state) {
        final currentState =
            state is OfferDetailInitial ? state : const OfferDetailInitial();

        return Scaffold(
          backgroundColor: AppTheme.canvasBg,
          body: Stack(
            children: [
              // ── 1. Image Slider Banner ──────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: screenHeight * 0.55,
                child: Stack(
                  children: [
                    // PageView
                    PageView.builder(
                      controller: _imageSliderController,
                      physics: const PageScrollPhysics(),
                      itemCount: _sliderImages.length,
                      onPageChanged: (index) {
                        context
                            .read<OfferDetailBloc>()
                            .add(ImageChanged(index));
                      },
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: _sliderImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: AppTheme.surfaceSubtle,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.surfaceSubtle,
                            child: const Center(
                              child: Icon(
                                Icons.local_offer_rounded,
                                size: 50,
                                color: AppTheme.accentPeriwinkle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Vignette gradient
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.48),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.28),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Back / Favourite / Share buttons
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _GlassButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            Row(
                              children: [
                                _GlassButton(
                                  icon: Icons.favorite_border_rounded,
                                  iconColor: const Color(0xFFEF4444),
                                  onTap: () {},
                                ),
                                const SizedBox(width: 8),
                                _GlassButton(
                                  icon: Icons.share_outlined,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Slider dots
                    if (_sliderImages.length > 1)
                      Positioned(
                        bottom: screenHeight * 0.12,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  _sliderImages.length,
                                  (index) => AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    width: currentState.currentImageIndex ==
                                            index
                                        ? 22
                                        : 7,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: currentState
                                                  .currentImageIndex ==
                                              index
                                          ? Colors.white
                                          : Colors.white
                                              .withValues(alpha: 0.45),
                                      borderRadius:
                                          BorderRadius.circular(3),
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

              // ── 2. Draggable Bottom Sheet ───────────────────────────────
              DraggableScrollableSheet(
                initialChildSize: 0.56,
                minChildSize: 0.48,
                maxChildSize: 0.94,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.canvasBg,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.borderSubtle,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        const SizedBox(height: 12),
                        // Drag handle
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppTheme.borderLight,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Header: merchant name + tag + location ────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      merchantName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.darkPill,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tag,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Location + rating row
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      size: 15,
                                      color: AppTheme.accentPeriwinkle),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: GoogleFonts.plusJakartaSans(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.star_rounded,
                                      size: 14,
                                      color: AppTheme.accentAmberDark),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${offer.rating.toStringAsFixed(1)} (${offer.reviewsCount})',
                                    style: GoogleFonts.plusJakartaSans(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ── Highlights ──────────────────────────────
                              Text(
                                'Highlights & Ambiance',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary),
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
                                        context
                                            .read<OfferDetailBloc>()
                                            .add(OpenStory(
                                                highlight['image']!));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 14),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(2.5),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.darkPill,
                                              ),
                                              child: CircleAvatar(
                                                radius: 25,
                                                backgroundImage:
                                                    NetworkImage(
                                                        highlight['image']!),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              highlight['title']!,
                                              style: GoogleFonts
                                                  .plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppTheme
                                                          .textPrimary),
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
                        const SizedBox(height: 16),

                        // ── Tab Bar ─────────────────────────────────────────
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: AppTheme.borderLight, width: 1.0),
                              boxShadow: AppTheme.softCardShadow,
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: AppTheme.darkPill,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: AppTheme.textSecondary,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.1,
                              ),
                              unselectedLabelStyle:
                                  GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Offer'),
                                Tab(text: 'About'),
                                Tab(text: 'Reviews'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Tab Views ───────────────────────────────────────
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _OffersTab(offer: offer),
                              _AboutTab(offer: offer),
                              _ReviewsTab(
                                  rating: offer.rating,
                                  reviewsCount: offer.reviewsCount),
                            ],
                          ),
                        ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  );
                },
              ),

              // ── 3. Floating CTA ─────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: BlocConsumer<RedemptionBloc, RedemptionState>(
                      listener: (context, redemptionState) {
                        if (redemptionState is RedemptionSuccess) {
                          RedemptionCodeSheet.show(
                            context,
                            redemption: redemptionState.redemption,
                            onDone: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Redemption Active! $savingsText.'),
                                  backgroundColor: AppTheme.savingsGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        } else if (redemptionState is RedemptionError) {
                          if (redemptionState.message.toLowerCase().contains('limit reached') ||
                              redemptionState.message.toLowerCase().contains('op-in') ||
                              redemptionState.message.toLowerCase().contains('club')) {
                            ClubPaywallSheet.show(context, reason: redemptionState.message);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(redemptionState.message),
                                backgroundColor: AppTheme.errorRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      builder: (context, redemptionState) {
                        final isLoading = redemptionState is RedemptionLoading;

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: AppTheme.softCardShadow,
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (offer.id != null && offer.id!.isNotEmpty) {
                                      context.read<RedemptionBloc>().add(
                                            InitRedemptionRequested(offer.id!),
                                          );
                                    } else {
                                      // Fallback for mock or missing ID
                                      MerchantPinRedemptionModal.show(
                                        context,
                                        offerTitle: offer.title,
                                        merchantName: merchantName,
                                        estimatedSavings: savingsText,
                                        onRedemptionSuccess: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Redemption Successful! $savingsText.'),
                                              backgroundColor: AppTheme.savingsGreen,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.darkPill,
                              minimumSize: const Size(double.infinity, 58),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.verified_rounded,
                                          color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Redeem Offer Now',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
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

// ── Frosted glass icon button helper ─────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _GlassButton(
      {required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? AppTheme.textPrimary),
        onPressed: onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB VIEWS
// ─────────────────────────────────────────────────────────────────────────────

class _OffersTab extends StatelessWidget {
  final OfferEntity offer;

  const _OffersTab({required this.offer});

  @override
  Widget build(BuildContext context) {
    final tag = offer.discountPercentage != null && offer.discountPercentage! > 0
        ? '${offer.discountPercentage}% OFF'
        : 'BOGOF';
    final savings = offer.estimatedSavingsNpr > 0
        ? 'Save NPR ${offer.estimatedSavingsNpr}'
        : 'Exclusive Deal';
    final validUntil = offer.validUntil != null
        ? 'Valid until ${_formatDate(offer.validUntil!)}'
        : 'Valid 7 days a week';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Savings summary banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.savingsGreen.withValues(alpha: 0.14),
                AppTheme.accentPeriwinkle.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: AppTheme.savingsGreen.withValues(alpha: 0.3),
                width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.savings_rounded,
                  color: AppTheme.savingsGreen, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      savings,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppTheme.savingsGreen),
                    ),
                    if (offer.originalPriceNpr != null &&
                        offer.discountedPriceNpr != null)
                      Text(
                        'NPR ${offer.discountedPriceNpr} instead of NPR ${offer.originalPriceNpr}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Main offer card
        _buildOfferCard(
          context,
          title: offer.title,
          subtitle: offer.description,
          redemptionsLeft: '${offer.maxPerUser} per user',
          validity: validUntil,
          tag: tag,
        ),
        const SizedBox(height: 12),

        // Terms card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: AppTheme.borderSubtle, width: 1.0),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms & Conditions',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                offer.terms,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5),
              ),
            ],
          ),
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
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.savingsGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 14, color: AppTheme.savingsGreen),
                    const SizedBox(width: 4),
                    Text(
                      '$tag UNLOCKED',
                      style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.savingsGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.local_activity_rounded,
                      size: 14, color: AppTheme.accentPeriwinkle),
                  const SizedBox(width: 4),
                  Text(
                    redemptionsLeft,
                    style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.accentPeriwinkleDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppTheme.borderSubtle),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    validity,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.darkPill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open_rounded,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Redeem',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
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

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final OfferEntity offer;

  const _AboutTab({required this.offer});

  @override
  Widget build(BuildContext context) {
    final merchant = offer.merchant;
    final merchantName = offer.merchantName ?? merchant?.name ?? 'Merchant';
    final description = merchant?.description ??
        '$merchantName is one of the premier lifestyle destinations in Nepal. Known for exceptional service and quality.';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // About card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo
                  if (merchant?.logoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: merchant!.logoUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 48,
                          height: 48,
                          color: AppTheme.surfaceSubtle,
                          child: const Icon(Icons.storefront_rounded,
                              color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                  if (merchant?.logoUrl != null) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'About the Merchant',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: AppTheme.textSecondary,
                    height: 1.5),
              ),
              // Contact info
              if (merchant?.contactPhone != null ||
                  merchant?.websiteUrl != null) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: AppTheme.borderSubtle),
                const SizedBox(height: 10),
                if (merchant?.contactPhone != null)
                  _infoRow(Icons.phone_rounded, merchant!.contactPhone!),
                if (merchant?.contactEmail != null)
                  _infoRow(Icons.email_outlined, merchant!.contactEmail!),
                if (merchant?.websiteUrl != null)
                  _infoRow(Icons.language_rounded, merchant!.websiteUrl!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Location & Map card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location & Directions',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              // Branch list
              if (merchant?.branches.isNotEmpty == true)
                ...merchant!.branches.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPeriwinkle
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.place_rounded,
                                size: 18,
                                color: AppTheme.accentPeriwinkle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.name,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: AppTheme.textPrimary),
                                ),
                                Text(
                                  '${b.address}, ${b.city}',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary),
                                ),
                                Text(
                                  'Lat: ${b.lat.toStringAsFixed(4)}, Lng: ${b.lng.toStringAsFixed(4)}',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
              else
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Center(
                    child: Text(
                      'Location info unavailable',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Availability card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operating Hours & Rules',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              _availabilityText(offer.availabilityJson, offer.validFrom,
                  offer.validUntil),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityText(
      Map<String, dynamic>? av, DateTime? validFrom, DateTime? validUntil) {
    final buf = StringBuffer();
    if (av != null) {
      if (av['days'] is List) {
        buf.write('• Days: ${(av['days'] as List).join(', ')}\n');
      }
      if (av['hours'] is Map) {
        final h = av['hours'] as Map;
        buf.write('• Hours: ${h['start']} – ${h['end']}\n');
      }
    }
    if (validFrom != null) buf.write('• Valid from: ${_fmt(validFrom)}\n');
    if (validUntil != null) buf.write('• Valid until: ${_fmt(validUntil)}\n');
    if (buf.isEmpty) {
      buf.write(
          '• Valid 7 days a week\n• Valid for dine-in only\n• Advance reservation recommended');
    }
    return Text(
      buf.toString().trim(),
      style: GoogleFonts.plusJakartaSans(
          fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
    );
  }

  String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReviewsTab extends StatelessWidget {
  final double rating;
  final int reviewsCount;

  const _ReviewsTab({required this.rating, required this.reviewsCount});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Rating summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Row(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                        5,
                        (_) => const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB800), size: 16)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Based on $reviewsCount verified redemptions',
                    style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildReviewCard('Aarav Sharma',
            'Amazing experience! Used the offer and saved a lot. The merchant verified the PIN instantly. Highly recommended.'),
        const SizedBox(height: 10),
        _buildReviewCard('Priya Karki',
            'Great service and wonderful ambiance. The BOGOF deal was genuinely worth it — no hidden charges.'),
        const SizedBox(height: 10),
        _buildReviewCard('Rajan Thapa',
            'One of the best deals I\'ve found on OfferNepal. Smooth redemption experience!'),
      ],
    );
  }

  Widget _buildReviewCard(String name, String comment) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary)),
              Row(
                  children: List.generate(
                      5,
                      (_) => const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB800), size: 12))),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment,
              style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textSecondary,
                  fontSize: 12.5,
                  height: 1.3)),
        ],
      ),
    );
  }
}
