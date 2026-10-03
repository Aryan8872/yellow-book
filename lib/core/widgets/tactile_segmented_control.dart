import 'package:flutter/material.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// Interactive tactile segmented pill control matching the Income/Expense & Denomination selectors.
/// Features a high-contrast dark fill for active state and soft surface for inactive.
class TactileSegmentedControl extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onSegmentSelected;

  const TactileSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.borderLight, width: 1),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(segments.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSegmentSelected(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.darkPill : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                segments[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
