import 'package:flutter/material.dart';

/// A custom vector painter that draws an architectural styled cartographic map
/// with roads, arterial avenues, city blocks, parks, waterways, and live user beacon.
class InteractiveCityMapPainter extends CustomPainter {
  final double userOffsetX;
  final double userOffsetY;
  final double pulseAnimation;

  InteractiveCityMapPainter({
    required this.userOffsetX,
    required this.userOffsetY,
    required this.pulseAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Base Map Canvas (Light Pastel Slate)
    final bgPaint = Paint()..color = const Color(0xFFE2EAF8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Waterways / River (Elegant Pastel Cerulean)
    final riverPaint = Paint()
      ..color = const Color(0xFFB9D5FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(-20, size.height * 0.25)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.20,
        size.width * 0.55,
        size.height * 0.55,
        size.width + 40,
        size.height * 0.48,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 3. Parks & Green Reserves
    final parkPaint = Paint()
      ..color = const Color(0xFFD1F2D9).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    // Park 1 (North-west)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.08, size.width * 0.24, size.height * 0.16),
        const Radius.circular(16),
      ),
      parkPaint,
    );

    // Park 2 (South-east botanical reserve)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.62, size.width * 0.30, size.height * 0.20),
        const Radius.circular(20),
      ),
      parkPaint,
    );

    // 4. Secondary Residential & Commercial City Grid
    final gridRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (double y = 0.12; y <= 0.95; y += 0.08) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y),
        gridRoadPaint,
      );
    }

    for (double x = 0.12; x <= 0.95; x += 0.10) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * x, size.height),
        gridRoadPaint,
      );
    }

    // 5. Major Arterial Avenues & Highways
    final highwayPaint = Paint()
      ..color = const Color(0xFFFED7AA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final highwayBorder = Paint()
      ..color = const Color(0xFFFDBA74).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13;

    final h1 = Path()
      ..moveTo(0, size.height * 0.38)
      ..lineTo(size.width, size.height * 0.72);
    canvas.drawPath(h1, highwayBorder);
    canvas.drawPath(h1, highwayPaint);

    final h2 = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.52, size.height);
    canvas.drawPath(h2, highwayBorder);
    canvas.drawPath(h2, highwayPaint);

    // 6. User Current Location Pulse Radar
    final userX = size.width * userOffsetX;
    final userY = size.height * userOffsetY;

    // Expanding Pulse Wave
    final pulsePaint = Paint()
      ..color = const Color(0xFF346EF6).withValues(alpha: (1.0 - pulseAnimation).clamp(0.0, 0.4))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(userX, userY), 20 + (pulseAnimation * 26), pulsePaint);

    // Secondary Pulse Wave
    final secondPulse = (pulseAnimation + 0.5) % 1.0;
    final pulsePaint2 = Paint()
      ..color = const Color(0xFF346EF6).withValues(alpha: (1.0 - secondPulse).clamp(0.0, 0.25))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(userX, userY), 15 + (secondPulse * 30), pulsePaint2);

    // Solid Beacon Halo
    final beaconBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(userX, userY), 10, beaconBorder);

    final beaconCore = Paint()
      ..color = const Color(0xFF0053DB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(userX, userY), 7, beaconCore);

    // Subtle user beam indicator
    final beamPaint = Paint()
      ..color = const Color(0xFF346EF6).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final beamPath = Path()
      ..moveTo(userX, userY)
      ..lineTo(userX - 16, userY - 32)
      ..lineTo(userX + 16, userY - 32)
      ..close();
    canvas.drawPath(beamPath, beamPaint);
  }

  @override
  bool shouldRepaint(covariant InteractiveCityMapPainter oldDelegate) {
    return oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.userOffsetX != userOffsetX ||
        oldDelegate.userOffsetY != userOffsetY;
  }
}
