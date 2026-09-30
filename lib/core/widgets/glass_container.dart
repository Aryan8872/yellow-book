import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable Flat + Glassmorphic container designed to unify the
/// signature pastel blue theme with frosted glass aesthetics.
///
/// Performance note: [BackdropFilter] (blur) is now opt-in via [enableBlur].
/// It is disabled by default because it forces a full off-screen compositing
/// pass on every frame, causing severe jank on mid-range Android devices.
/// The default frosted look is achieved via high-opacity color + border instead.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  /// Set to true ONLY for hero elements that truly need the frosted-glass
  /// blur effect and are NOT inside a scrolling list. Defaults to false.
  final bool enableBlur;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.blur = 16.0,
    this.color,
    this.border,
    this.shadows,
    this.onTap,
    this.enableBlur = false, // OFF by default for performance
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white.withValues(alpha: 0.88);
    final effectiveBorder = border ??
        Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.5,
        );

    final effectiveShadows = shadows ??
        [
          BoxShadow(
            color: const Color(0xFF0053DB).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ];

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: enableBlur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: _buildInnerBox(effectiveColor, effectiveBorder),
              )
            : _buildInnerBox(effectiveColor, effectiveBorder),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildInnerBox(Color effectiveColor, Border effectiveBorder) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        // Subtle gradient overlay gives the frosted look without blur
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: child,
    );
  }
}
