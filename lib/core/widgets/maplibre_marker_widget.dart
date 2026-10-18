import 'package:flutter/material.dart';

/// Merchant marker widget for MapLibre map
class MapLibreMarkerWidget extends StatelessWidget {
  final String category;
  final bool isSelected;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const MapLibreMarkerWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = isSelected ? 56.0 : 44.0;
    final height = isSelected ? 72.0 : 58.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: isSelected ? 40.0 : 32.0,
              height: isSelected ? 40.0 : 32.0,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isSelected ? 20.0 : 16.0,
              ),
            ),
            // Selection indicator
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// User location beacon widget
class MapLibreUserBeacon extends StatelessWidget {
  const MapLibreUserBeacon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.my_location_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
