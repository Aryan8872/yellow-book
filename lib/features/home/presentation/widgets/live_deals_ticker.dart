import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/presentation/pages/scratch_win_page.dart';
import 'package:entertainer/features/search/presentation/pages/search_page.dart';

class TickerItem {
  final String iconEmoji;
  final String title;
  final String badgeText;
  final VoidCallback onTap;

  const TickerItem({
    required this.iconEmoji,
    required this.title,
    required this.badgeText,
    required this.onTap,
  });
}

/// Continuous smoothly moving linear marquee ticker in one direction.
/// Modeled after high-end landing pages (GSAP linear infinite loop):
/// - Scrolls horizontally at a steady, uninterrupted velocity
/// - Pauses on user touch down, resumes on release
/// - Never jarringly resets; duplicates list for seamless infinite loop
class LiveDealsTicker extends StatefulWidget {
  const LiveDealsTicker({super.key});

  @override
  State<LiveDealsTicker> createState() => _LiveDealsTickerState();
}

class _LiveDealsTickerState extends State<LiveDealsTicker> {
  late final ScrollController _scrollController;
  Timer? _scrollTimer;
  bool _isInteracting = false;

  late final List<TickerItem> _items;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _items = [
      TickerItem(
        iconEmoji: '🔥',
        title: 'Weekend Flash: Flat 30% off on all Pokhara Lakeside Resorts',
        badgeText: 'FLASH',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SearchPage(initialQuery: 'Resort'),
            ),
          );
        },
      ),
      TickerItem(
        iconEmoji: '☕',
        title: '100+ new cafe & bakery vouchers added this week across KTM',
        badgeText: 'NEW',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SearchPage(initialQuery: 'Cafe'),
            ),
          );
        },
      ),
      TickerItem(
        iconEmoji: '🎟️',
        title: 'Scratch & Win: Rs. 50,000 in monthly prizes up for grabs today!',
        badgeText: 'JACKPOT',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScratchWinPage()),
          );
        },
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startContinuousScroll();
    });
  }

  void _startContinuousScroll() {
    _scrollTimer?.cancel();
    // 60fps continuous increment (every 16ms, shift by 0.65 pixel)
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _isInteracting || !_scrollController.hasClients) return;

      final current = _scrollController.offset;
      final max = _scrollController.position.maxScrollExtent;

      if (max > 0) {
        if (current >= max / 2) {
          // Halfway jump for seamless wrap
          _scrollController.jumpTo(current - (max / 2));
        } else {
          _scrollController.jumpTo(current + 0.65);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4 repetitions to ensure ample scroll width for smooth continuous translation
    final fullList = [
      ..._items,
      ..._items,
      ..._items,
      ..._items,
    ];

    return Listener(
      onPointerDown: (_) => setState(() => _isInteracting = true),
      onPointerUp: (_) => setState(() => _isInteracting = false),
      onPointerCancel: (_) => setState(() => _isInteracting = false),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          border: const Border.symmetric(
            horizontal: BorderSide(color: AppTheme.borderLight, width: 0.8),
          ),
        ),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(), // Managed purely by continuous timer
          itemCount: fullList.length,
          itemBuilder: (context, index) {
            final item = fullList[index];
            return GestureDetector(
              onTap: item.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.iconEmoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.crimsonPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.crimsonPrimary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppTheme.borderLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
