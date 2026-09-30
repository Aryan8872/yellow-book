import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteStoreItem {
  final String id;
  final String label;
  final String shortLogo;
  final Color bg;
  final Color fg;

  const FavoriteStoreItem({
    required this.id,
    required this.label,
    required this.shortLogo,
    required this.bg,
    required this.fg,
  });
}

class UserFavoritesSection extends StatelessWidget {
  final List<FavoriteStoreItem> favorites;
  final VoidCallback? onSeeMoreTap;
  final Function(FavoriteStoreItem)? onFavoriteTap;

  const UserFavoritesSection({
    super.key,
    required this.favorites,
    this.onSeeMoreTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Favorites',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              GestureDetector(
                onTap: onSeeMoreTap,
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF346EF6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final fav = favorites[index];
              return InkWell(
                onTap: () => onFavoriteTap?.call(fav),
                borderRadius: BorderRadius.circular(33),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: fav.bg,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0x14000000)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          fav.shortLogo,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: fav.fg,
                            fontSize: 11,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fav.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          height: 1.2,
                          color: const Color(0xFF3E3E3E),
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
