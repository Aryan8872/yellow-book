import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable Flat + Glassmorphic container designed to unify the
/// signature pastel blue theme with frosted glass aesthetics.
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
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white.withValues(alpha: 0.65);
    final effectiveBorder = border ??
        Border.all(
          color: Colors.white.withValues(alpha: 0.8),
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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: effectiveBorder,
            ),
            child: child,
          ),
        ),
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
}
