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
import 'package:entertainer/features/offer/presentation/bloc/favourites_bloc.dart';
import 'package:entertainer/features/offer/presentation/pages/redemption_detail_page.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';

import 'dart:async';
import 'package:entertainer/core/widgets/skeleton_loader.dart';
import 'package:entertainer/features/review/presentation/bloc/review_bloc.dart';
import 'package:entertainer/features/review/presentation/bloc/review_event.dart';
import 'package:entertainer/features/review/presentation/bloc/review_state.dart';
import 'package:entertainer/features/review/domain/entities/review_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_state.dart';
import 'package:entertainer/features/search/presentation/pages/search_results_page.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';

class OfferDetailPage extends StatelessWidget {
  final OfferEntity offer;

  const OfferDetailPage({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RedemptionBloc>(
          create: (context) => getIt<RedemptionBloc>(),
        ),
        BlocProvider<FavouritesBloc>(
          create: (context) =>
              getIt<FavouritesBloc>()..add(const FavouritesLoadRequested()),
        ),
        BlocProvider<ReviewBloc>(
          create: (context) => getIt<ReviewBloc>()
            ..add(FetchReviewsRequested(offerId: offer.id, limit: 10)),
        ),
        BlocProvider<OffersBloc>(
          create: (context) => getIt<OffersBloc>()
            ..add(FetchOffersRequested(
              category: offer.category.name,
              limit: 10,
              radiusKm: 50,
            )),
        ),
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

class _OfferDetailViewState extends State<_OfferDetailView> {
  final PageController _imageController = PageController();
  int _activeImageIndex = 0;
  String? _selectedBranchId;
  bool _isFavorited = false;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  late List<String> _displayImages;

  @override
  void initState() {
    super.initState();
    _initCountdown();
    final apiImages = widget.offer.images.isNotEmpty
        ? widget.offer.images
        : widget.offer.imageUrl != null
            ? [widget.offer.imageUrl!]
            : ['https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80'];
    _displayImages = apiImages;

    // Default select first branch if available
    final branches = widget.offer.branches.isNotEmpty
        ? widget.offer.branches
        : widget.offer.merchant?.branches ?? [];
    if (branches.isNotEmpty) {
      _selectedBranchId = branches.first.id;
    }
  }

  void _onRedeemPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Processing redemption voucher...',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.crimsonPrimary,
        duration: const Duration(seconds: 1),
      ),
    );

    context.read<RedemptionBloc>().add(
      InitRedemptionRequested(
        widget.offer.id ?? '',
        branchId: _selectedBranchId,
      ),
    );
  }

  void _initCountdown() {
    final validUntil = widget.offer.validUntil;
    if (validUntil != null) {
      final diff = validUntil.difference(DateTime.now());
      if (diff.isNegative) {
        _remainingTime = Duration.zero;
      } else {
        _remainingTime = diff;
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          final newDiff = validUntil.difference(DateTime.now());
          if (newDiff.isNegative) {
            setState(() => _remainingTime = Duration.zero);
            timer.cancel();
          } else {
            setState(() => _remainingTime = newDiff);
          }
        });
      }
    } else {
      // Default sample countdown
      _remainingTime = const Duration(hours: 6, minutes: 24, seconds: 19);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_remainingTime.inSeconds > 0) {
          setState(() {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          });
        }
      });
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _showWriteReviewDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Write a Review',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rate your experience with ${widget.offer.merchantName ?? "this offer"}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        iconSize: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () {
                          setModalState(() => selectedRating = starValue);
                        },
                        icon: Icon(
                          starValue <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.canvasBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      controller: commentController,
                      maxLines: 4,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Share details of your experience...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final comment = commentController.text.trim();
                        if (comment.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a review comment.')),
                          );
                          return;
                        }
                        this.context.read<ReviewBloc>().add(
                          CreateReviewRequested(
                            offerId: widget.offer.id,
                            merchantId: widget.offer.merchantId,
                            rating: selectedRating,
                            comment: comment,
                          ),
                        );
                        Navigator.pop(bottomSheetContext);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thank you! Your review has been submitted.',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppTheme.emeraldJade,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.crimsonPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Submit Review',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
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

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final branches = offer.branches.isNotEmpty
        ? offer.branches
        : offer.merchant?.branches ?? [];

    final originalPrice = offer.originalPriceNpr ?? (offer.discountedPriceNpr ?? 0) + offer.estimatedSavingsNpr;
    final discountedPrice = offer.discountedPriceNpr ?? (originalPrice > 0 ? originalPrice - offer.estimatedSavingsNpr : 0);

    return MultiBlocListener(
      listeners: [
        BlocListener<RedemptionBloc, RedemptionState>(
          listener: (context, state) {
            if (state is RedemptionSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => RedemptionDetailPage(redemption: state.redemption),
                ),
              );
            } else if (state is RedemptionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
        ),
        BlocListener<ReviewBloc, ReviewState>(
          listener: (context, state) {
            if (state is ReviewCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review posted successfully!'),
                  backgroundColor: AppTheme.emeraldJade,
                ),
              );
              // Immediately refresh reviews from backend
              context.read<ReviewBloc>().add(
                FetchReviewsRequested(offerId: widget.offer.id, limit: 10),
              );
            } else if (state is ReviewDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review deleted successfully.'),
                  backgroundColor: AppTheme.crimsonPrimary,
                ),
              );
              context.read<ReviewBloc>().add(
                FetchReviewsRequested(offerId: widget.offer.id, limit: 10),
              );
            } else if (state is ReviewUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review updated successfully!'),
                  backgroundColor: AppTheme.emeraldJade,
                ),
              );
              context.read<ReviewBloc>().add(
                FetchReviewsRequested(offerId: widget.offer.id, limit: 10),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Scrollable Body with Pull-to-Refresh ───────────────────────
            RefreshIndicator(
              color: AppTheme.crimsonPrimary,
              onRefresh: () async {
                context.read<ReviewBloc>().add(
                  FetchReviewsRequested(offerId: widget.offer.id, limit: 10),
                );
                context.read<OffersBloc>().add(
                  FetchOffersRequested(
                    category: widget.offer.category.name,
                    limit: 10,
                    radiusKm: 50,
                  ),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 84), // App bar clearance

                  // 1. Hero Media Gallery
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: PageView.builder(
                          controller: _imageController,
                          itemCount: _displayImages.length,
                          onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: _displayImages[index],
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(color: AppTheme.surfaceDark),
                            );
                          },
                        ),
                      ),
                      // Top Overlay Pill: Most Gifted Experience
                      Positioned(
                        bottom: 12,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.card_giftcard_rounded, size: 14, color: AppTheme.crimsonPrimary),
                              const SizedBox(width: 5),
                              Text(
                                'Most Gifted Experience',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Pagination Pill
                      if (_displayImages.length > 1)
                        Positioned(
                          bottom: 12,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_activeImageIndex + 1} / ${_displayImages.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // 2. Deal Overview Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Urgency & Discount Callout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFFE4E6)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.bolt_rounded, size: 14, color: AppTheme.crimsonPrimary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PRICE DROP • ACT FAST!',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.crimsonPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (offer.discountPercentage != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFD1FAE5)),
                                ),
                                child: Text(
                                  'Up to ${offer.discountPercentage}% OFF',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF047857),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          offer.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Rating & Reviews row
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              offer.rating.toStringAsFixed(1),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${offer.reviewsCount}+ verified reviews)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          offer.description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: const Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppTheme.borderLight),

                  // 3. Limited-Time Promo Countdown Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFEF3C7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Color(0xFFB45309), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _remainingTime.inHours < 24
                              ? 'Flash Promo Ends in: ${_formatDuration(_remainingTime)}'
                              : 'Ends on ${_formatExpiryDate(offer.validUntil)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Where to Redeem & Branch Selection
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Where to Redeem',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${branches.length} locations available',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (branches.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderLight),
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
                                        offer.merchantName ?? 'Main Branch',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Kathmandu Valley',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...branches.map((branch) {
                            final isSelected = _selectedBranchId == branch.id;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedBranchId = branch.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.crimsonPrimary.withValues(alpha: 0.04)
                                      : AppTheme.cardSurface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.crimsonPrimary : AppTheme.borderLight,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      size: 20,
                                      color: isSelected ? AppTheme.crimsonPrimary : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            branch.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '${branch.address}, ${branch.city}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Explicit View on Map Button
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MapDiscoveryPage(
                                              initialBranch: (
                                                lat: branch.lat,
                                                lng: branch.lng,
                                                title: branch.name,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.map_rounded, size: 14, color: AppTheme.crimsonPrimary),
                                      label: Text(
                                        'View on Map',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.crimsonPrimary,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  // 5. Terms & Conditions Accordion
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          'Terms & Conditions',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.canvasBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              offer.terms.isNotEmpty
                                  ? offer.terms
                                  : '• Present voucher before ordering.\n• Valid for dine-in only.\n• Cannot be combined with other promotions.\n• 1 voucher per table/bill.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: const Color(0xFF475569),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: AppTheme.borderLight),

                  // 6. Customer Reviews Section
                  _buildCustomerReviewsSection(),

                  const Divider(height: 1, color: AppTheme.borderLight),

                  // 7. Explore More Categories
                  _buildExploreMoreCategories(offer),

                  const Divider(height: 1, color: AppTheme.borderLight),

                  // 8. Similar Deals Carousel
                  _buildSimilarDealsSection(),
                ],
              ),
            ),
          ),

            // ── Floating Sticky Top Bar matching offer_detail.html ───────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 6, 16, 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  border: const Border(bottom: BorderSide(color: AppTheme.borderLight)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF0F172A)),
                      ),
                    ),
                    // Title Mark
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.crimsonPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'OFFERNEPAL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    // Actions: Share & Heart
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF334155)),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _isFavorited = !_isFavorited),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18,
                              color: _isFavorited ? AppTheme.crimsonPrimary : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Floating Bottom Bar matching offer_detail.html ───────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price Stack
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (originalPrice > 0)
                          Text(
                            'Rs. $originalPrice',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          'Rs. $discountedPrice',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ],
                    ),
                    // Redeem Now Button
                    ElevatedButton(
                      onPressed: _onRedeemPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.crimsonPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Redeem Now',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                        ],
                      ),
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

  String _formatExpiryDate(DateTime? date) {
    if (date == null) return 'No expiry date';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCustomerReviewsSection() {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        final reviews = state is ReviewsLoaded ? state.reviews : <ReviewEntity>[];
        final avgRating = reviews.isNotEmpty
            ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length
            : widget.offer.rating;
        final reviewCount = reviews.isNotEmpty ? reviews.length : widget.offer.reviewsCount;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer Reviews',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          '${avgRating.toStringAsFixed(1)} ($reviewCount)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Review cards
              if (state is ReviewLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SkeletonLoader(height: 80),
                ))
              else if (reviews.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.canvasBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'No reviews yet. Be the first to review!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...reviews.take(3).map((review) => _buildReviewCard(review)),

              const SizedBox(height: 14),

              // Write a Review Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showWriteReviewDialog,
                  icon: const Icon(Icons.rate_review_rounded, size: 18),
                  label: Text(
                    'Write a Review',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.crimsonPrimary,
                    side: const BorderSide(color: AppTheme.crimsonPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _buildReviewCard(ReviewEntity review) {
    final initials = (review.user?.name ?? 'A').isNotEmpty
        ? (review.user?.name ?? 'A').substring(0, 1).toUpperCase()
        : '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.canvasBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.crimsonPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.crimsonPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.user?.name ?? 'Anonymous',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Verified',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatExpiryDate(review.createdAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Star rating
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: const Color(0xFFF59E0B),
                )),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          // Action Row: Helpful button & Author Edit/Delete
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final currentUserId = authState is AuthAuthenticated ? authState.user.id : null;
              final isAuthor = currentUserId != null && currentUserId == review.userId;

              return Row(
                children: [
                  // Mark as Helpful Button
                  GestureDetector(
                    onTap: () {
                      context.read<ReviewBloc>().add(MarkHelpfulRequested(review.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Marked as helpful!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 13, color: AppTheme.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            'Helpful (${review.helpfulCount})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isAuthor) ...[
                    // Edit Review
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textSecondary),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showEditReviewDialog(review),
                    ),
                    // Delete Review
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.crimsonPrimary),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmDeleteReview(review.id),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReview(String reviewId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Review',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete your review?',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.crimsonPrimary),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReviewBloc>().add(DeleteReviewRequested(reviewId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditReviewDialog(ReviewEntity review) {
    int updatedRating = review.rating;
    final controller = TextEditingController(text: review.comment);

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
                    'Edit Review',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= updatedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 30,
                        ),
                        onPressed: () => setModalState(() => updatedRating = starValue),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'Update your review...',
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
                        this.context.read<ReviewBloc>().add(
                          UpdateReviewRequested(
                            id: review.id,
                            rating: updatedRating,
                            comment: text,
                          ),
                        );
                        Navigator.pop(modalCtx);
                      },
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildExploreMoreCategories(OfferEntity offer) {
    // Generate intelligent search query terms based on offer category, title, and popular keywords
    final searchTerms = <String>{
      offer.category.name,
      if (offer.category.name.toLowerCase().contains('dining') || offer.category.name.toLowerCase().contains('food')) ...[
        'Buffet Deals',
        'Momo & Snacks',
        'Fine Dining',
        'Rooftop Lounge',
      ] else if (offer.category.name.toLowerCase().contains('spa') || offer.category.name.toLowerCase().contains('wellness')) ...[
        'Full Body Massage',
        'Ayurvedic Therapy',
        'Sauna & Steam',
        'Salon & Hair',
      ] else ...[
        'Weekend Getaway',
        'Family Deals',
        'Best Discounts',
        'New Drops',
      ],
      'Trending Today',
      'Near You',
    }.toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.saved_search_rounded, size: 20, color: AppTheme.crimsonPrimary),
              const SizedBox(width: 6),
              Text(
                'Explore Related Deals & Search',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any term to instantly browse matching offers & discounts',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searchTerms.map((term) {
              final isPrimary = term == offer.category.name;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchResultsPage(
                        query: term,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPrimary ? AppTheme.crimsonPrimary : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPrimary ? AppTheme.crimsonPrimary : AppTheme.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPrimary ? Icons.local_offer_rounded : Icons.search_rounded,
                        size: 13,
                        color: isPrimary ? Colors.white : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        term,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPrimary ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarDealsSection() {
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        List<OfferEntity> similarOffers = [];
        if (state is OffersLoaded) {
          similarOffers = state.offers
              .where((o) => o.id != widget.offer.id)
              .take(6)
              .toList();
        }

        if (similarOffers.isEmpty && state is! OffersLoading) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Similar Deals',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (state is OffersLoading)
                const SizedBox(
                  height: 160,
                  child: Center(child: SkeletonLoader(height: 150)),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: similarOffers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final deal = similarOffers[index];
                      return _SimilarDealCard(
                        offer: deal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OfferDetailPage(offer: deal),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SimilarDealCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onTap;

  const _SimilarDealCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = offer.imageUrl ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 100,
                width: 160,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  height: 100,
                  color: AppTheme.surfaceSubtle,
                  child: const Icon(Icons.image_rounded, color: AppTheme.textMuted),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        offer.rating.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (offer.discountPercentage != null)
                        Text(
                          '${offer.discountPercentage}% OFF',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF047857),
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
    );
  }
}
