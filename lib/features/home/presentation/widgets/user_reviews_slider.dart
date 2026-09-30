import 'package:flutter/material.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import 'package:entertainer/core/widgets/section_heading.dart';

class UserReviewsSlider extends StatelessWidget {
  final List<Map<String, String>> reviews;

  const UserReviewsSlider({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeading(headingText: "Community Stories"),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.86),
            physics: const BouncingScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: GlassContainer(
                  borderRadius: 22,
                  blur: 14,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white.withValues(alpha: 0.72),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(review['userImage'] ?? ''),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['userName'] ?? 'Member',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  review['personalPick'] ?? 'Verified Diner',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.savings_outlined, size: 13, color: Color(0xFF059669)),
                                const SizedBox(width: 4),
                                Text(
                                  review['savedAmount'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          "\"${review['reviewText'] ?? ''}\"",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFFB800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
