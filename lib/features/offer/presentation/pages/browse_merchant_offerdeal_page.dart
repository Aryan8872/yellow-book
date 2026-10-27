import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/skeleton_loader.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_state.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';

class BrowseMerchantOfferDealPage extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  final String? logoUrl;
  final List<RedemptionBranchInfo> branches;
  final double rating;
  final int reviewsCount;
  final String cuisine;

  const BrowseMerchantOfferDealPage({
    super.key,
    required this.merchantId,
    required this.merchantName,
    this.logoUrl,
    this.branches = const [],
    this.rating = 4.8,
    this.reviewsCount = 482,
    this.cuisine = 'Continental & Asian Fusion',
  });

  @override
  State<BrowseMerchantOfferDealPage> createState() => _BrowseMerchantOfferDealPageState();
}

class _BrowseMerchantOfferDealPageState extends State<BrowseMerchantOfferDealPage> {
  String _selectedCategory = 'All';
  String _currentSort = 'value'; // value, discount, price, popular
  final Set<String> _localFavorites = {};

  final Map<String, String> _sortLabels = {
    'value': 'Best Value (Savings)',
    'discount': 'Discount: High to Low',
    'price': 'Price: Low to High',
    'popular': 'Most Popular Claimed',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OffersBloc>()
        ..add(
          FetchOffersRequested(merchantId: widget.merchantId, limit: 50),
        ),
      child: Scaffold(
        backgroundColor: AppTheme.canvasBg,
        appBar: AppBar(
          backgroundColor: AppTheme.cardSurface,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.crimsonLightBg,
                ),
                child: const Center(
                  child: Icon(Icons.local_offer_rounded, size: 16, color: AppTheme.crimsonPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Merchant Deals',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppTheme.textSecondary, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sharing deals from ${widget.merchantName}')),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<OffersBloc, OffersState>(
          builder: (context, state) {
            final offers = state is OffersLoaded
                ? state.offers
                : (state is OffersInitial ? const <OfferEntity>[] : const <OfferEntity>[]);
            final isLoading = state is OffersLoading;

            // Extract dynamic categories from offers
            final categorySet = <String>{'All'};
            for (final o in offers) {
              if (o.category.name.isNotEmpty) {
                categorySet.add(o.category.name);
              }
            }

            // Filter offers by category
            var filtered = offers.where((o) {
              if (_selectedCategory == 'All') return true;
              return o.category.name.toLowerCase() == _selectedCategory.toLowerCase();
            }).toList();

            // Sort offers
            filtered.sort((a, b) {
              if (_currentSort == 'discount') {
                final discA = a.discountPercentage ?? 0;
                final discB = b.discountPercentage ?? 0;
                return discB.compareTo(discA);
              } else if (_currentSort == 'price') {
                final priceA = a.discountedPriceNpr ?? a.originalPriceNpr ?? 0;
                final priceB = b.discountedPriceNpr ?? b.originalPriceNpr ?? 0;
                return priceA.compareTo(priceB);
              } else if (_currentSort == 'popular') {
                return (b.reviewsCount).compareTo(a.reviewsCount);
              } else {
                // 'value' (savings)
                return b.estimatedSavingsNpr.compareTo(a.estimatedSavingsNpr);
              }
            });

            return RefreshIndicator(
              color: AppTheme.crimsonPrimary,
              onRefresh: () async {
                context.read<OffersBloc>().add(
                  FetchOffersRequested(merchantId: widget.merchantId, limit: 50),
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // 1. Merchant Sticky Context Summary Header Bar
                  SliverToBoxAdapter(
                    child: _buildMerchantStickyBar(),
                  ),

                  // 2. Interactive Category Filter Rail & Sort Selector Toolbar
                  SliverToBoxAdapter(
                    child: _buildFilterAndSortToolbar(categorySet.toList(), filtered.length),
                  ),

                  // 3. Deals List / Skeletons / Empty State
                  if (isLoading && offers.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: SkeletonLoader(height: 280),
                          ),
                          childCount: 3,
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: AppTheme.surfaceSubtle,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search_off_rounded, size: 28, color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No matching vouchers found',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try changing the category filter or check back soon.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildDealCard(filtered[index]),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMerchantStickyBar() {
    final branchAddress = widget.branches.isNotEmpty ? widget.branches.first.address ?? 'Kathmandu' : 'Kathmandu';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Merchant Logo / Thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.logoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _buildFallbackAvatar(),
                    ),
                  )
                : _buildFallbackAvatar(),
          ),
          const SizedBox(width: 12),
          // Merchant Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.merchantName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, size: 16, color: AppTheme.emeraldJade),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.cuisine} • $branchAddress',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 3),
                    Text(
                      widget.rating.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      ' (${widget.reviewsCount} reviews)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Premier Partner',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF047857),
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
    );
  }

  Widget _buildFallbackAvatar() {
    return Center(
      child: Text(
        widget.merchantName.isNotEmpty ? widget.merchantName[0].toUpperCase() : 'M',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppTheme.crimsonPrimary,
        ),
      ),
    );
  }

  Widget _buildFilterAndSortToolbar(List<String> categories, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Pills Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final isSelected = cat.toLowerCase() == _selectedCategory.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppTheme.surfaceDark,
                    backgroundColor: AppTheme.cardSurface,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.surfaceDark : AppTheme.borderLight,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Active Count & Sort Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing $count curated vouchers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              PopupMenuButton<String>(
                initialValue: _currentSort,
                onSelected: (val) => setState(() => _currentSort = val),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                itemBuilder: (context) => [
                  _buildSortMenuItem('value', 'Best Value (Savings)'),
                  _buildSortMenuItem('discount', 'Discount: High to Low'),
                  _buildSortMenuItem('price', 'Price: Low to High'),
                  _buildSortMenuItem('popular', 'Most Popular Claimed'),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_vert_rounded, size: 16, color: AppTheme.crimsonPrimary),
                      const SizedBox(width: 4),
                      Text(
                        _sortLabels[_currentSort] ?? 'Sort',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded, size: 16, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String title) {
    final isSelected = _currentSort == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppTheme.crimsonPrimary : AppTheme.textPrimary,
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_rounded, size: 16, color: AppTheme.crimsonPrimary),
        ],
      ),
    );
  }

  Widget _buildDealCard(OfferEntity offer) {
    final image = offer.images.isNotEmpty
        ? offer.images.first
        : offer.imageUrl ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80';

    final originalPrice = offer.originalPriceNpr ?? ((offer.discountedPriceNpr ?? 0) + offer.estimatedSavingsNpr);
    final discountedPrice = offer.discountedPriceNpr ?? (originalPrice > 0 ? originalPrice - offer.estimatedSavingsNpr : 0);
    final isFav = _localFavorites.contains(offer.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Header with Badges
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppTheme.surfaceSubtle),
                    errorWidget: (context, url, error) => Container(color: AppTheme.surfaceSubtle),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Top Left Badges: Discount & Claimed
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldJade,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${offer.discountPercentage}% OFF',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (offer.reviewsCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded, size: 12, color: Color(0xFFFFB3B6)),
                              const SizedBox(width: 3),
                              Text(
                                '${offer.reviewsCount} Reviews',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Top Right Favorite Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      final oid = offer.id;
                      if (oid != null) {
                        setState(() {
                          if (isFav) {
                            _localFavorites.remove(oid);
                          } else {
                            _localFavorites.add(oid);
                          }
                        });
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFav ? AppTheme.crimsonPrimary : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                // Bottom Labels: Valid terms & Guaranteed
                Positioned(
                  bottom: 8,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          offer.category.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Guaranteed Deal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF85F8C4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Card Content Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
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
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Validity & Terms Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.emeraldJade),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Valid All Days • Instant QR Voucher Claim',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price Cluster & Action CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Rs. ${discountedPrice.toInt()}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.crimsonPrimary,
                                ),
                              ),
                              if (originalPrice > discountedPrice) ...[
                                const SizedBox(width: 6),
                                Text(
                                  'Rs. ${originalPrice.toInt()}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'Save Rs. ${offer.estimatedSavingsNpr.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.emeraldJade,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.crimsonPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OfferDetailPage(offer: offer),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Claim Deal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
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
