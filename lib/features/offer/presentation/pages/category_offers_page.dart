import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_state.dart';
import 'offer_detail_page.dart';

class CategoryOffersPage extends StatelessWidget {
  final String categoryName;

  const CategoryOffersPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Map display name → API enum value
    final categoryApiValue = categoryName.toUpperCase();

    return BlocProvider(
      create: (_) => getIt<OffersBloc>()
        ..add(FetchOffersRequested(
          category: categoryApiValue,
          page: 1,
          limit: 30,
          refresh: true,
        )),
      child: _CategoryOffersView(categoryName: categoryName),
    );
  }
}

class _CategoryOffersView extends StatefulWidget {
  final String categoryName;
  const _CategoryOffersView({required this.categoryName});

  @override
  State<_CategoryOffersView> createState() => _CategoryOffersViewState();
}

class _CategoryOffersViewState extends State<_CategoryOffersView> {
  String _selectedFilter = 'All Offers';
  final List<String> _filterLabels = [
    'All Offers',
    'Buy 1 Get 1 Free',
    'Top Rated 4.5+',
    'New Additions',
  ];

  List<OfferEntity> _applyFilter(List<OfferEntity> offers) {
    switch (_selectedFilter) {
      case 'Buy 1 Get 1 Free':
        return offers
            .where((o) =>
                o.highlights.any((h) => h.toLowerCase().contains('bogo')) ||
                (o.discountPercentage == null || o.discountPercentage == 0))
            .toList();
      case 'Top Rated 4.5+':
        return offers.where((o) => o.rating >= 4.5).toList();
      case 'New Additions':
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        return offers
            .where((o) => o.validFrom != null && o.validFrom!.isAfter(cutoff))
            .toList();
      default:
        return offers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: Stack(
        children: [
          SafeArea(
            child: BlocBuilder<OffersBloc, OffersState>(
              builder: (context, state) {
                final allOffers =
                    state is OffersLoaded ? state.offers : <OfferEntity>[];
                final filteredOffers = _applyFilter(allOffers);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: AppTheme.borderLight, width: 1.0),
                              boxShadow: AppTheme.softCardShadow,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: AppTheme.textPrimary),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.categoryName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  state is OffersLoading
                                      ? 'Loading offers...'
                                      : '${filteredOffers.length} verified offers',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Filter icon
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPeriwinkle
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.tune_rounded,
                                    size: 16,
                                    color: AppTheme.accentPeriwinkleDark),
                                const SizedBox(width: 4),
                                Text(
                                  'Filter',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentPeriwinkleDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Filter Pills ────────────────────────────────────────
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filterLabels.length,
                        itemBuilder: (_, index) {
                          final label = _filterLabels[index];
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFilter = label),
                            child: _FilterPill(
                                label: label,
                                isSelected: _selectedFilter == label),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Content ─────────────────────────────────────────────
                    Expanded(
                      child: _buildContent(context, state, filteredOffers),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, OffersState state, List<OfferEntity> offers) {
    if (state is OffersLoading) {
      return const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppTheme.accentPeriwinkle));
    }

    if (state is OffersError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(
              'Failed to load offers',
              style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.read<OffersBloc>().add(FetchOffersRequested(
                      category: widget.categoryName.toUpperCase(),
                      page: 1,
                      limit: 30,
                      refresh: true,
                    ));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer_rounded,
                size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(
              'No offers found in ${widget.categoryName}',
              style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textMuted, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      physics: const BouncingScrollPhysics(),
      itemCount: offers.length,
      itemBuilder: (context, index) =>
          _CategoryOfferCard(offer: offers[index]),
    );
  }
}

// ── Single offer card in the list ─────────────────────────────────────────────
class _CategoryOfferCard extends StatelessWidget {
  final OfferEntity offer;
  const _CategoryOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    const fallback =
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80';

    final imageUrl = offer.imageUrl ??
        (offer.images.isNotEmpty ? offer.images.first : null) ??
        fallback;

    final location = offer.merchant?.branches.isNotEmpty == true
        ? '${offer.merchant!.branches.first.address}, ${offer.merchant!.branches.first.city}'
        : 'Nepal';

    final tag = offer.discountPercentage != null && offer.discountPercentage! > 0
        ? '${offer.discountPercentage}% OFF'
        : 'BOGOF';

    final savingsLabel = offer.estimatedSavingsNpr > 0
        ? 'Save NPR ${offer.estimatedSavingsNpr}'
        : 'Exclusive Deal';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OfferDetailPage(offer: offer)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      height: 150,
                      color: AppTheme.surfaceSubtle,
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 150,
                      color: AppTheme.surfaceSubtle,
                      child: const Center(
                        child: Icon(Icons.local_offer_rounded,
                            size: 40, color: AppTheme.accentPeriwinkle),
                      ),
                    ),
                  ),
                ),
                // Tag badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.darkPill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFFFB800)),
                        const SizedBox(width: 3),
                        Text(
                          offer.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Card info ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          offer.merchantName ??
                              offer.merchant?.name ??
                              offer.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.5,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.savingsGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          savingsLabel,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.savingsGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppTheme.accentPeriwinkle),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter pill ────────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterPill({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.darkPill : AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
