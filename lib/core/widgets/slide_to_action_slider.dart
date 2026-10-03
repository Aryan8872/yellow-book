import 'package:flutter/material.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// Smooth, physical "Slide to Action" slider matching the "Slide to Cashout >>>" pattern in the reference UI.
/// Delivers high tactile feedback, prevents accidental activations, and avoids generic button fatigue.
class SlideToActionSlider extends StatefulWidget {
  final String label;
  final VoidCallback onActionCompleted;
  final bool isCompleted;

  const SlideToActionSlider({
    super.key,
    required this.label,
    required this.onActionCompleted,
    this.isCompleted = false,
  });

  @override
  State<SlideToActionSlider> createState() => _SlideToActionSliderState();
}

class _SlideToActionSliderState extends State<SlideToActionSlider> with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  static const double _knobSize = 52.0;
  static const double _trackHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - _knobSize - 8;

        return Container(
          height: _trackHeight,
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppTheme.borderLight, width: 1.2),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // 1. Centered Track Text
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),

              // 2. Interactive Sliding Knob
              Positioned(
                left: _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition >= maxDrag * 0.85) {
                      // Action confirmed! Complete slide
                      setState(() {
                        _dragPosition = maxDrag;
                      });
                      widget.onActionCompleted();
                    } else {
                      // Snap back smoothly
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: _knobSize,
                    height: _knobSize,
                    decoration: BoxDecoration(
                      color: AppTheme.darkPill,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkPill.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
