import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// Tactile Slide-To-Confirm Slider Widget
/// Replicates the smooth "Slide to Cashout / Redeem >>>" from Screenshot 2:
/// - Circular black slider knob with white arrow
/// - Smooth drag physics with spring snap-back if incomplete
/// - Trigger callback on 100% swipe with haptic feedback
class SlideToConfirmButton extends StatefulWidget {
  final String text;
  final VoidCallback onConfirmed;
  final bool isCompleted;

  const SlideToConfirmButton({
    super.key,
    this.text = 'Slide to Redeem',
    required this.onConfirmed,
    this.isCompleted = false,
  });

  @override
  State<SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (widget.isCompleted) return;
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxDrag) {
    if (widget.isCompleted) return;
    if (_dragPosition >= maxDrag * 0.85) {
      // Confirmed!
      HapticFeedback.heavyImpact();
      setState(() => _dragPosition = maxDrag);
      widget.onConfirmed();
    } else {
      // Spring reset
      _resetAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack),
      )..addListener(() {
          setState(() => _dragPosition = _resetAnimation.value);
        });
      _resetController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double height = 64.0;
    const double knobSize = 52.0;
    const double padding = 6.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - knobSize - (padding * 2);

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: AppTheme.borderLight, width: 1.2),
            boxShadow: AppTheme.softCardShadow,
          ),
          padding: const EdgeInsets.all(padding),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Center Label & Arrow Indicators
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
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

              // Draggable Circular Black Knob
              Positioned(
                left: _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onHorizontalDragUpdate(details, maxDrag),
                  onHorizontalDragEnd: (details) =>
                      _onHorizontalDragEnd(details, maxDrag),
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: AppTheme.darkAnchor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkAnchor.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 22,
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
