import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// Data model representing a physical voucher card in the wallet deck
class WalletVoucherItem {
  final String id;
  final String category;
  final String brandName;
  final String discountValue;
  final Color cardColor;
  final IconData icon;
  final String voucherCode;
  final String description;
  final String terms;
  final int savingsNpr;

  const WalletVoucherItem({
    required this.id,
    required this.category,
    required this.brandName,
    required this.discountValue,
    required this.cardColor,
    required this.icon,
    required this.voucherCode,
    required this.description,
    required this.terms,
    required this.savingsNpr,
  });
}

/// Interactive Stacked Wallet Deck Widget
/// Replicates the tactile overlapping physical card stack from Screenshot 1:
/// - Cards peek out from behind each other with a 65px vertical offset
/// - Smooth interactive tap expansion / selection
/// - Soft multi-layer dropshadows separating each card
class TactileWalletDeck extends StatefulWidget {
  final List<WalletVoucherItem> vouchers;
  final ValueChanged<WalletVoucherItem> onCardTap;

  const TactileWalletDeck({
    super.key,
    required this.vouchers,
    required this.onCardTap,
  });

  @override
  State<TactileWalletDeck> createState() => _TactileWalletDeckState();
}

class _TactileWalletDeckState extends State<TactileWalletDeck> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 160.0;
    const double peekOffset = 76.0;
    final int count = widget.vouchers.length;
    final double totalHeight = cardHeight + (count - 1) * peekOffset + 20;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(count, (index) {
          final item = widget.vouchers[index];
          final top = index * peekOffset;
          final isHovered = _hoveredIndex == index;

          return Positioned(
            top: top,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              offset: isHovered ? const Offset(0, -0.06) : Offset.zero,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _hoveredIndex = index),
                onTapUp: (_) {
                  setState(() => _hoveredIndex = null);
                  widget.onCardTap(item);
                },
                onTapCancel: () => setState(() => _hoveredIndex = null),
                child: Container(
                  height: cardHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  decoration: BoxDecoration(
                    color: item.cardColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular Minimalist Brand Logo Anchor
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: AppTheme.darkAnchor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Brand & Category Hierarchy
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkAnchor.withValues(alpha: 0.65),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.brandName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.darkAnchor,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Huge Value / Discount Tag
                      Text(
                        item.discountValue,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.darkAnchor,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
