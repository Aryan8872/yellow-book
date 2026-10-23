import 'package:flutter/material.dart';
import 'package:entertainer/core/theme/app_theme.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.borderLight,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: _ShimmerAnimation(),
    );
  }
}

class _ShimmerAnimation extends StatefulWidget {
  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.borderLight,
                AppTheme.borderLight.withValues(alpha: 0.5),
                AppTheme.borderLight,
              ],
              stops: [_animation.value - 0.3, _animation.value, _animation.value + 0.3],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: const ColoredBox(color: Colors.white),
    );
  }
}

class OfferCardSkeleton extends StatelessWidget {
  const OfferCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            height: 160,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(
                  width: 120,
                  height: 20,
                ),
                const SizedBox(height: 8),
                const SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                ),
                const SizedBox(height: 8),
                const SkeletonLoader(
                  width: 200,
                  height: 16,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SkeletonLoader(
                      width: 60,
                      height: 24,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    const Spacer(),
                    const SkeletonLoader(
                      width: 80,
                      height: 32,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
