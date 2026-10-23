import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_event.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

// ─── Fallback images by category so cards never show broken icons ──────────────
const _categoryFallbacks = {
  'DINING':        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=300&q=80',
  'WELLNESS':      'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=300&q=80',
  'ENTERTAINMENT': 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=300&q=80',
  'RETAIL':        'https://images.unsplash.com/photo-1472851294608-062f824d29cc?auto=format&fit=crop&w=300&q=80',
  'TRAVEL':        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=300&q=80',
  'BEAUTY':        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=300&q=80',
};

class FeaturedOffersSlider extends StatelessWidget {
  final List<OfferEntity> offers;

  const FeaturedOffersSlider({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final List<List<OfferEntity>> slides = [];
    for (int i = 0; i < offers.length; i += 4) {
      slides.add(offers.sublist(i, i + 4 > offers.length ? offers.length : i + 4));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Featured Collections',
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
          height: 190,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.92),
            physics: const BouncingScrollPhysics(),
            itemCount: slides.length,
            itemBuilder: (context, slideIndex) {
              final slideItems = slides[slideIndex];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (slideItems.isNotEmpty)
                            Expanded(child: _buildFeaturedCard(context, slideItems[0])),
                          const SizedBox(width: 8),
                          if (slideItems.length > 1)
                            Expanded(child: _buildFeaturedCard(context, slideItems[1]))
                          else
                            const Spacer(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          if (slideItems.length > 2)
                            Expanded(child: _buildFeaturedCard(context, slideItems[2]))
                          else
                            const Spacer(),
                          const SizedBox(width: 8),
                          if (slideItems.length > 3)
                            Expanded(child: _buildFeaturedCard(context, slideItems[3]))
                          else
                            const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, OfferEntity offer) {
    final imageUrl = offer.imageUrl ??
        (offer.images.isNotEmpty ? offer.images.first : null) ??
        _categoryFallbacks[offer.category.name.toUpperCase()] ??
        _categoryFallbacks['DINING']!;

    final location = offer.merchant?.branches.isNotEmpty == true
        ? offer.merchant!.branches.first.city
        : (offer.merchantName ?? 'Nepal');

    final tag = offer.discountPercentage != null && offer.discountPercentage! > 0
        ? '${offer.discountPercentage}% OFF'
        : 'BOGOF';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 1),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.read<HomeBloc>().add(OfferCardSelected(offer));
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.surfaceSubtle,
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: AppTheme.darkPill,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.surfaceSubtle,
                      child: const Icon(Icons.local_offer_rounded, color: AppTheme.textMuted, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        offer.merchantName ?? offer.merchant?.name ?? offer.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        location,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.canvasBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textPrimary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
