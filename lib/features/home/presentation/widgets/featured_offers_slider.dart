import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import 'package:entertainer/core/widgets/section_heading.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_event.dart';

class FeaturedOffersSlider extends StatelessWidget {
  final List<Map<String, String>> offers;

  const FeaturedOffersSlider({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    // Group offers into slides of 4 (2x2 grid per slide)
    final List<List<Map<String, String>>> slides = [];
    for (int i = 0; i < offers.length; i += 4) {
      slides.add(offers.sublist(i, i + 4 > offers.length ? offers.length : i + 4));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeading(headingText: "Featured Collections"),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
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
                    // Row 1
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
                    // Row 2
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
    return GlassContainer(
      borderRadius: 16,
      blur: 12,
      padding: const EdgeInsets.all(8),
      color: Colors.white.withValues(alpha: 0.72),
      onTap: () {
        context.read<HomeBloc>().add(TrendingOfferSelected(item));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:           CachedNetworkImage(
              imageUrl: item["image"]!,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 58,
                height: 58,
                color: const Color(0xFFD3E4FE),
                child: const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Color(0xFF346EF6),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 58,
                height: 58,
                color: const Color(0xFFD3E4FE),
                child: const Icon(Icons.restaurant, color: Color(0xFF346EF6), size: 20),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item["location"]!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF346EF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item["highlightTag"] ?? 'Deal',
                    style: const TextStyle(
                      color: Color(0xFF0053DB),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
