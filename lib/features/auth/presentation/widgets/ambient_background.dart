import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:entertainer/core/theme/app_theme.dart';

class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Clean Lavender Milk Canvas
        Container(
          color: AppTheme.canvasBg,
        ),
        // Soft, Subtle Pastel Glow Accents
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = _controller.value;
            final offset = math.sin(value * math.pi * 2) * 25;

            return Stack(
              children: [
                // Top Left Periwinkle Tint
                Positioned(
                  top: -80 + offset,
                  left: -60 + offset,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentPeriwinkle.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Right Mint Tint
                Positioned(
                  bottom: -60 - offset,
                  right: -50 - offset,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentMint.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        // Foreground Content
        widget.child,
      ],
    );
  }
}
