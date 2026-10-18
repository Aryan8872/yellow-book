import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

/// Google Maps-style slide-in left panel showing offer details when a map pin is tapped.
/// Matches the web BranchDetailDrawer design pattern.
class OfferMapDrawer extends StatelessWidget {
  final Map<String, dynamic>? merchant;
  final bool isOpen;
  final VoidCallback onClose;

  const OfferMapDrawer({
    super.key,
    required this.merchant,
    required this.isOpen,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      left: isOpen ? 0 : -320,
      top: 0,
      bottom: 0,
      width: 300,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
          child: _DrawerCard(merchant: merchant, onClose: onClose),
        ),
      ),
    );
  }
}

class _DrawerCard extends StatelessWidget {
  final Map<String, dynamic>? merchant;
  final VoidCallback onClose;

  const _DrawerCard({required this.merchant, required this.onClose});

  @override
  Widget build(BuildContext context) {
    if (merchant == null) return const SizedBox.shrink();

    final imageUrl = merchant!['image'] as String?;
    final name = merchant!['hotelName'] as String? ?? 'Offer';
    final category = merchant!['category'] as String? ?? '';
    final tag = merchant!['highlightTag'] as String? ?? '';
    final offerType = merchant!['offerType'] as String? ?? '';
    final location = merchant!['location'] as String? ?? '';
    final rating = merchant!['rating'] as String? ?? '4.8';
    final offer = merchant!['offer'] as OfferEntity?;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      color: AppTheme.cardSurface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image + Close Button ──────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _CategoryFallback(category: category),
                        )
                      : _CategoryFallback(category: category),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 70,
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
                // Close button
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                // Discount badge
                if (tag.isNotEmpty)
                  Positioned(
                    bottom: 10, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5A93C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Offer Info ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPeriwinkleDark.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppTheme.accentPeriwinkleDark, letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Merchant name
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Offer title
                    Text(
                      offerType,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Rating + Location
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFE5A93C), size: 15),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on_rounded, color: AppTheme.textMuted, size: 14),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── View Offer CTA ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: offer != null
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OfferDetailPage(offer: offer),
                            ),
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkPill,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'View Offer',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFallback extends StatelessWidget {
  final String category;
  const _CategoryFallback({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Dining': const Color(0xFFEF4444),
      'Hotels': AppTheme.accentPeriwinkleDark,
      'Activities': AppTheme.savingsGreen,
    };
    return Container(
      color: colors[category] ?? AppTheme.darkPill,
      child: const Center(
        child: Icon(Icons.local_offer_rounded, color: Colors.white54, size: 48),
      ),
    );
  }
}
