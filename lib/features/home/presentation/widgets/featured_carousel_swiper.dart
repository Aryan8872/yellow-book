import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';

/// Clean, flat, production-grade hero carousel for Featured Offers.
/// Follows flat design principles (no tacky neon gradients, solid crisp tags,
/// smooth auto-sliding with pause on manual touch, and clear typography).
class FeaturedCarouselSwiper extends StatefulWidget {
  final List<OfferEntity> offers;

  const FeaturedCarouselSwiper({
    super.key,
    required this.offers,
  });

  @override
  State<FeaturedCarouselSwiper> createState() => _FeaturedCarouselSwiperState();
}

class _FeaturedCarouselSwiperState extends State<FeaturedCarouselSwiper> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startTimer();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _autoSlideTimer?.cancel();
    if (widget.offers.length <= 1) return;
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!_isInteracting && mounted && widget.offers.isNotEmpty) {
        final nextPage = (_currentPage + 1) % widget.offers.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _onUserInteractionStart() {
    _isInteracting = true;
    _autoSlideTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    _isInteracting = false;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 172,
          child: Listener(
            onPointerDown: (_) => _onUserInteractionStart(),
            onPointerUp: (_) => _onUserInteractionEnd(),
            onPointerCancel: (_) => _onUserInteractionEnd(),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.offers.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final offer = widget.offers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _FeaturedCarouselCard(offer: offer),
                );
              },
            ),
          ),
        ),
        if (widget.offers.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.offers.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 20 : 6,
                height: 5,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppTheme.crimsonPrimary
                      : AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeaturedCarouselCard extends StatelessWidget {
  final OfferEntity offer;

  const _FeaturedCarouselCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfferDetailPage(offer: offer),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Left Image Section
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: offer.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.surfaceSubtle,
                            child: const Icon(
                              Icons.local_offer_rounded,
                              size: 28,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.surfaceSubtle,
                          child: const Icon(
                            Icons.local_offer_rounded,
                            size: 28,
                            color: AppTheme.textMuted,
                          ),
                        ),
                  // Flat Featured Tag (Clean top-left pill)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'FEATURED',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Details Section
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Merchant Name
                        Text(
                          (offer.merchantName ?? offer.merchant?.name ?? 'OFFER NEPAL').toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        // Offer Title
                        Text(
                          offer.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Discount & Expiry Bottom Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.crimsonPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            offer.discountPercentage != null && offer.discountPercentage! > 0
                                ? '${offer.discountPercentage}% OFF'
                                : (offer.computedSavingsNpr > 0
                                    ? 'SAVE Rs. ${offer.computedSavingsNpr}'
                                    : 'FEATURED'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Claim now',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

