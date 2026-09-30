import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreItem {
  final String id;
  final String name;
  final String logoText;
  final Color logoBg;
  final Color logoFg;
  final String category;
  final String distance;
  final String time;
  final String price;
  final bool sponsored;
  final bool verified;
  final bool freeDelivery;
  final String? freeFrom;

  const StoreItem({
    required this.id,
    required this.name,
    required this.logoText,
    required this.logoBg,
    required this.logoFg,
    required this.category,
    required this.distance,
    required this.time,
    required this.price,
    this.sponsored = false,
    this.verified = false,
    this.freeDelivery = false,
    this.freeFrom,
  });
}

class StoresNearYouSlider extends StatelessWidget {
  final List<StoreItem> stores;
  final Function(StoreItem)? onStoreTap;

  const StoresNearYouSlider({
    super.key,
    required this.stores,
    this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();

    // Group stores into slides of 3 items stacked vertically
    final List<List<StoreItem>> slides = [];
    for (int i = 0; i < stores.length; i += 3) {
      slides.add(stores.sublist(i, i + 3 > stores.length ? stores.length : i + 3));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Stores Near You',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F1F1F),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 375, // Increased height to prevent any vertical RenderFlex overflow
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.94),
            physics: const BouncingScrollPhysics(),
            itemCount: slides.length,
            itemBuilder: (context, slideIndex) {
              final slideStores = slides[slideIndex];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: slideStores.map((store) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => onStoreTap?.call(store),
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                // Circular Brand Logo Badge
                                Container(
                                  width: 52,
                                  height: 52,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: store.logoBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: store.logoBg.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    store.logoText,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: store.logoFg,
                                      fontSize: 8.5,
                                      height: 1.05,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Store Info Column (Responsive & Overflow Safe)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (store.sponsored)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 1),
                                          child: Text(
                                            'Sponsored',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF346EF6),
                                            ),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              store.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1F1F1F),
                                              ),
                                            ),
                                          ),
                                          if (store.verified) ...[
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 15,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF346EF6),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(Icons.star_rounded, size: 11, color: Colors.white),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF5A623)),
                                          const SizedBox(width: 2),
                                          Text(
                                            '4.7',
                                            style: GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFB8860B),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '  •  ${store.category}  •  ${store.distance}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF717171)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${store.time}  •  ${store.price}',
                                        style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF717171), fontWeight: FontWeight.w500),
                                      ),
                                      if (store.freeFrom != null) ...[
                                        const SizedBox(height: 3),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            store.freeFrom!,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: const Color(0xFF059669),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.favorite_border_rounded, size: 20, color: Color(0xFF9A9A9A)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
