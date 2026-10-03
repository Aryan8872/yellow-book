import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_event.dart';

class FeaturedOffersSlider extends StatelessWidget {
  final List<Map<String, String>> offers;

  const FeaturedOffersSlider({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    final List<List<Map<String, String>>> slides = [];
    for (int i = 0; i < offers.length; i += 4) {
      slides.add(offers.sublist(i, i + 4 > offers.length ? offers.length : i + 4));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Featured Collections",
            style: TextStyle(
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

  Widget _buildFeaturedCard(BuildContext context, Map<String, String> item) {
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
            context.read<HomeBloc>().add(TrendingOfferSelected(item));
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: item["image"]!,
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
                      child: const Icon(Icons.restaurant, color: AppTheme.textMuted, size: 22),
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
                        item["hotelName"]!,
                        style: const TextStyle(
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
                        item["location"]!,
                        style: const TextStyle(
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
                          item["highlightTag"] ?? 'Deal',
                          style: const TextStyle(
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
