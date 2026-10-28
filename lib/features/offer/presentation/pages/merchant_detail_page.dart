import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/skeleton_loader.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_state.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';
import 'package:entertainer/features/offer/presentation/pages/browse_merchant_offerdeal_page.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'package:entertainer/features/review/domain/entities/review_entity.dart';
import 'package:entertainer/features/review/presentation/bloc/review_bloc.dart';
import 'package:entertainer/features/review/presentation/bloc/review_event.dart';
import 'package:entertainer/features/review/presentation/bloc/review_state.dart';

class MerchantDetailPage extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  final String? logoUrl;
  final List<RedemptionBranchInfo> branches;
  final String cuisine;
  final double rating;
  final int reviewsCount;

  const MerchantDetailPage({
    super.key,
    required this.merchantId,
    required this.merchantName,
    this.logoUrl,
    this.branches = const [],
    this.cuisine = 'Continental • Asian Fusion • Garden Dining',
    this.rating = 4.8,
    this.reviewsCount = 482,
  });

  @override
  State<MerchantDetailPage> createState() => _MerchantDetailPageState();
}

class _MerchantDetailPageState extends State<MerchantDetailPage> {
  bool _isFavorite = false;
  int _activePhotoIndex = 0;

  final List<String> _showcasePhotos = [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<OffersBloc>()
            ..add(
              FetchOffersRequested(merchantId: widget.merchantId, limit: 10),
            ),
        ),
        BlocProvider(
          create: (_) => getIt<ReviewBloc>()
            ..add(
              FetchReviewsRequested(merchantId: widget.merchantId, limit: 10),
            ),
        ),
      ],
      child: Builder(
        builder: (scaffoldContext) {
          return Scaffold(
            backgroundColor: AppTheme.canvasBg,
            body: Stack(
              children: [
                // Scrollable Body matching merchant_detail_page.html
                RefreshIndicator(
                  color: AppTheme.crimsonPrimary,
                  onRefresh: () async {
                    scaffoldContext.read<OffersBloc>().add(
                      FetchOffersRequested(merchantId: widget.merchantId, limit: 10),
                    );
                    scaffoldContext.read<ReviewBloc>().add(
                      FetchReviewsRequested(merchantId: widget.merchantId, limit: 10),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Top Visual Showcase Carousel
                        _buildTopVisualShowcase(),

                        // 2. Merchant Identity & Highlights Section
                        _buildMerchantIdentity(scaffoldContext),

                        // 3. Promotional Banner Alert
                        _buildPromoBanner(),

                        // 4. Featured Deals List Section
                        _buildFeaturedDealsSection(scaffoldContext),

                        // 5. Story & Heritage Section
                        _buildAboutSection(),

                        // 6. Location & Operating Schedule Section
                        _buildLocationAndHoursSection(),

                        // 7. Verified Diner Reviews Section
                        _buildVerifiedReviewsSection(scaffoldContext),
                      ],
                    ),
                  ),
                ),

                // Floating Back & Share Header Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 6,
                      left: 12,
                      right: 12,
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sharing ${widget.merchantName}')),
                                );
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.share_outlined, color: AppTheme.textPrimary, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopVisualShowcase() {
    return Stack(
      children: [
        SizedBox(
          height: 270,
          child: PageView.builder(
            itemCount: _showcasePhotos.length,
            onPageChanged: (idx) => setState(() => _activePhotoIndex = idx),
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: _showcasePhotos[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppTheme.surfaceSubtle),
                errorWidget: (context, url, error) => Container(color: AppTheme.surfaceSubtle),
              );
            },
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Floating Top Badges
        Positioned(
          top: MediaQuery.of(context).padding.top + 50,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF68DBA9)),
                    const SizedBox(width: 5),
                    Text(
                      'Premier Partner',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isFavorite = !_isFavorite),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 19,
                    color: _isFavorite ? AppTheme.crimsonPrimary : AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Gallery Pill
        Positioned(
          bottom: 12,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.photo_library_outlined, size: 13, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${_activePhotoIndex + 1} / ${_showcasePhotos.length} Photos',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantIdentity(BuildContext scaffoldContext) {
    final branch = widget.branches.isNotEmpty ? widget.branches.first : null;
    final branchAddress = branch?.address ?? 'Lazimpat Rd, Kathmandu';

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.merchantName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded, size: 20, color: AppTheme.emeraldJade),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.cuisine,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          // Rating, Status & Price Tier Line
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDDB8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFF815100)),
                    const SizedBox(width: 3),
                    Text(
                      widget.rating.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2A1700),
                      ),
                    ),
                    Text(
                      ' (${widget.reviewsCount} reviews)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF653E00),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.emeraldJade,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Open Now • Closes 11:00 PM',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.emeraldJade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Address & Distance
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.crimsonPrimary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  branchAddress,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '1.2 km away',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.crimsonPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Quick Action Shortcut Buttons (Call, Directions, Share, Menu)
          Row(
            children: [
              _buildQuickActionBtn(
                icon: Icons.call_rounded,
                iconColor: AppTheme.crimsonPrimary,
                label: 'Call',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Merchant hotline: +977 1-4410200 / +977 9801234567'),
                      backgroundColor: AppTheme.surfaceDark,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildQuickActionBtn(
                icon: Icons.directions_rounded,
                iconColor: AppTheme.emeraldJade,
                label: 'Directions',
                onTap: () {
                  if (branch?.lat != null && branch?.lng != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapDiscoveryPage(
                          initialBranch: (
                            lat: branch!.lat!,
                            lng: branch.lng!,
                            title: branch.name,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildQuickActionBtn(
                icon: Icons.share_rounded,
                iconColor: AppTheme.textSecondary,
                label: 'Share',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing ${widget.merchantName}')),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildQuickActionBtn(
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFFD97706),
                label: 'Menu PDF',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening verified merchant digital menu...')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppTheme.emeraldJade,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instant QR Voucher Redemption',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF065F46),
                  ),
                ),
                Text(
                  'Show at bill payment • No pre-booking fee',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.emeraldJade,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'GUARANTEED',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedDealsSection(BuildContext scaffoldContext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Curated Exclusive Offers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BrowseMerchantOfferDealPage(
                        merchantId: widget.merchantId,
                        merchantName: widget.merchantName,
                        logoUrl: widget.logoUrl,
                        branches: widget.branches,
                        rating: widget.rating,
                        reviewsCount: widget.reviewsCount,
                        cuisine: widget.cuisine,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.crimsonPrimary,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.crimsonPrimary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BlocBuilder<OffersBloc, OffersState>(
            builder: (context, state) {
              if (state is OffersLoading) {
                return const Column(
                  children: [
                    SkeletonLoader(height: 100),
                    SizedBox(height: 10),
                    SkeletonLoader(height: 100),
                  ],
                );
              }
              if (state is OffersLoaded && state.offers.isNotEmpty) {
                return Column(
                  children: [
                    ...state.offers.take(3).map((offer) => _buildMerchantOfferCard(offer)),
                    const SizedBox(height: 8),
                    // "View All Offers" big button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.crimsonPrimary,
                          side: const BorderSide(color: AppTheme.crimsonPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BrowseMerchantOfferDealPage(
                                merchantId: widget.merchantId,
                                merchantName: widget.merchantName,
                                logoUrl: widget.logoUrl,
                                branches: widget.branches,
                                rating: widget.rating,
                                reviewsCount: widget.reviewsCount,
                                cuisine: widget.cuisine,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View All ${state.offers.length} Offers from ${widget.merchantName}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No offers currently available.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantOfferCard(OfferEntity offer) {
    final image = offer.images.isNotEmpty
        ? offer.images.first
        : offer.imageUrl ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80';

    final originalPrice = offer.originalPriceNpr ?? (offer.computedDiscountedPriceNpr + offer.computedSavingsNpr);
    final discountedPrice = offer.computedDiscountedPriceNpr > 0
        ? offer.computedDiscountedPriceNpr
        : (originalPrice > offer.computedSavingsNpr ? originalPrice - offer.computedSavingsNpr : originalPrice);
    final savingsNpr = offer.computedSavingsNpr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppTheme.surfaceSubtle),
                        errorWidget: (context, url, error) => Container(color: AppTheme.surfaceSubtle),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldJade,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${offer.discountPercentage}% OFF',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rs. ${discountedPrice.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                        if (originalPrice > discountedPrice) ...[
                          const SizedBox(width: 6),
                          Text(
                            'Rs. ${originalPrice.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                savingsNpr > 0
                    ? 'Save Rs. $savingsNpr instantly'
                    : 'Exclusive Member Privilege',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.emeraldJade,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfferDetailPage(offer: offer),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.crimsonLightBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'View Voucher',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.crimsonPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${widget.merchantName}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'A premier hospitality landmark in Kathmandu known for artisanal cuisines, tranquil garden courtyards, and exceptional dining experiences. Partnered with OfferNepal to deliver verified discounts on top dishes and multi-course sets.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Key Amenities & Comforts',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmenityChip(Icons.deck_rounded, 'Outdoor Garden Seating'),
              _buildAmenityChip(Icons.wifi_rounded, 'Free High-Speed Wi-Fi'),
              _buildAmenityChip(Icons.local_parking_rounded, 'Complimentary Valet'),
              _buildAmenityChip(Icons.music_note_rounded, 'Live Acoustic Sessions'),
              _buildAmenityChip(Icons.account_balance_wallet_rounded, 'eSewa & Khalti Accepted'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.crimsonPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndHoursSection() {
    final branch = widget.branches.isNotEmpty ? widget.branches.first : null;
    final address = branch?.address ?? 'Lazimpat, Kathmandu';

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Location & Hours',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Lazimpat, Ward 2',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Branch cards list
          if (widget.branches.isNotEmpty) ...[
            ...widget.branches.map((b) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, size: 20, color: AppTheme.crimsonPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          b.address ?? address,
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (b.lat != null && b.lng != null)
                    IconButton(
                      icon: const Icon(Icons.directions_rounded, color: AppTheme.emeraldJade),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapDiscoveryPage(
                              initialBranch: (lat: b.lat!, lng: b.lng!, title: b.name),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            )),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 18, color: AppTheme.crimsonPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Operating Schedule Accordion
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monday – Sunday',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    Text(
                      '11:00 AM – 11:00 PM',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kitchen Last Order',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    Text(
                      '10:15 PM',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedReviewsSection(BuildContext scaffoldContext) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verified Diner Reviews',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Real visits verified via OfferNepal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                    widget.rating.toStringAsFixed(1),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Aspect Ratings Pills
          Row(
            children: [
              _buildAspectRating('Food Taste', '4.9 / 5'),
              const SizedBox(width: 8),
              _buildAspectRating('Ambience', '5.0 / 5'),
              const SizedBox(width: 8),
              _buildAspectRating('Deal Value', '4.7 / 5'),
            ],
          ),
          const SizedBox(height: 16),
          // Reviews List from ReviewBloc
          BlocBuilder<ReviewBloc, ReviewState>(
            builder: (context, state) {
              if (state is ReviewLoading) {
                return const SkeletonLoader(height: 90);
              }
              if (state is ReviewsLoaded && state.reviews.isNotEmpty) {
                return Column(
                  children: state.reviews.take(3).map((r) => _buildMerchantReviewCard(r, scaffoldContext)).toList(),
                );
              }
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'No reviews for this merchant yet. Be the first to share your experience!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppTheme.textMuted),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // Write a Review Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.rate_review_rounded, size: 16),
              label: Text(
                'Write a Review for ${widget.merchantName}',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.crimsonPrimary,
                side: const BorderSide(color: AppTheme.crimsonPrimary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showWriteReviewModal(scaffoldContext),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectRating(String label, String score) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              score,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantReviewCard(ReviewEntity review, BuildContext scaffoldContext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.user?.name ?? 'Verified Diner',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: const Color(0xFFF59E0B),
                )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Helpful review?',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
              ),
              GestureDetector(
                onTap: () {
                  scaffoldContext.read<ReviewBloc>().add(MarkHelpfulRequested(review.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as helpful!'), duration: Duration(seconds: 1)),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${review.helpfulCount} Helpful',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
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

  void _showWriteReviewModal(BuildContext scaffoldContext) {
    int rating = 5;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write a Review for ${widget.merchantName}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 32,
                        ),
                        onPressed: () => setModalState(() => rating = starValue),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'Share your dining or visit experience...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.crimsonPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;

                        scaffoldContext.read<ReviewBloc>().add(
                          CreateReviewRequested(
                            merchantId: widget.merchantId,
                            rating: rating,
                            comment: text,
                          ),
                        );
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you! Your merchant review has been submitted.'),
                            backgroundColor: AppTheme.emeraldJade,
                          ),
                        );
                      },
                      child: const Text('Submit Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
