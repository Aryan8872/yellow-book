import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class CategoryMapMarkerFactory {
  static const categorySlugs = [
    'DINING',
    'WELLNESS',
    'ENTERTAINMENT',
    'RETAIL',
    'TRAVEL',
    'BEAUTY',
  ];

  static String imageIdFor(String? categorySlug) {
    final slug = categorySlug?.toUpperCase();
    return categorySlugs.contains(slug)
        ? 'offer-pin-${slug!.toLowerCase()}'
        : 'offer-pin-default';
  }

  static String get clusterImageId => 'offer-pin-cluster';
  static String get locationImageId => 'offer-pin-location';

  static Future<void> registerImages(MapLibreMapController controller) async {
    for (final category in categorySlugs) {
      await controller.addImage(
        imageIdFor(category),
        await _renderCategoryMarker(category),
      );
    }
    // Register the fallback default pin used when an offer has an unknown/empty category
    await controller.addImage(
      'offer-pin-default',
      await _renderCategoryMarker('DEFAULT'),
    );
    await controller.addImage(clusterImageId, await _renderClusterMarker());
    await controller.addImage(locationImageId, await _renderLocationMarker());
  }

  static Future<Uint8List> _renderLocationMarker() async {
    const size = Size(72, 88);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final path = Path()
      ..moveTo(36, 4)
      ..cubicTo(18, 4, 6, 17, 6, 33)
      ..cubicTo(6, 52, 36, 84, 36, 84)
      ..cubicTo(36, 84, 66, 52, 66, 33)
      ..cubicTo(66, 17, 54, 4, 36, 4)
      ..close();
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()..color = const Color(0x44000000),
    );
    canvas.drawPath(path, Paint()..color = const Color(0xFF1D4ED8));
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(const Offset(36, 32), 10, Paint()..color = Colors.white);
    return _encode(recorder, size);
  }

  static Future<Uint8List> renderCategoryMarker(String categorySlug) =>
      _renderCategoryMarker(categorySlug.toUpperCase());

  static Future<Uint8List> _renderCategoryMarker(String category) async {
    const size = Size(72, 88);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final color = _colorFor(category);
    final path = _pathFor(category);

    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()..color = const Color(0x44000000),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    return _encode(recorder, size);
  }

  static Future<Uint8List> _renderClusterMarker() async {
    const size = Size(72, 72);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final bounds = const Rect.fromLTWH(5, 5, 62, 62);
    canvas.drawCircle(
      bounds.center.translate(0, 2),
      31,
      Paint()..color = const Color(0x44000000),
    );
    canvas.drawCircle(
      bounds.center,
      31,
      Paint()..color = const Color(0xFF1A1A2E),
    );
    canvas.drawCircle(
      bounds.center,
      27,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    return _encode(recorder, size);
  }

  static Future<Uint8List> _encode(
    ui.PictureRecorder recorder,
    Size size,
  ) async {
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    picture.dispose();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) {
      throw StateError('Could not encode map marker image');
    }
    return data.buffer.asUint8List();
  }

  static Path _pathFor(String category) {
    switch (category) {
      case 'DINING':
        return Path()
          ..addOval(const Rect.fromLTWH(10, 5, 52, 52))
          ..moveTo(21, 47)
          ..lineTo(36, 82)
          ..lineTo(51, 47)
          ..close();
      case 'WELLNESS':
        return Path()
          ..moveTo(36, 4)
          ..lineTo(67, 34)
          ..lineTo(36, 64)
          ..lineTo(5, 34)
          ..close()
          ..moveTo(27, 54)
          ..lineTo(36, 84)
          ..lineTo(45, 54)
          ..close();
      case 'ENTERTAINMENT':
        return _starPath();
      case 'RETAIL':
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(10, 5, 52, 52),
              const Radius.circular(5),
            ),
          )
          ..moveTo(22, 48)
          ..lineTo(36, 82)
          ..lineTo(50, 48)
          ..close();
      case 'TRAVEL':
        return Path()
          ..moveTo(36, 4)
          ..cubicTo(18, 4, 6, 17, 6, 33)
          ..cubicTo(6, 52, 36, 84, 36, 84)
          ..cubicTo(36, 84, 66, 52, 66, 33)
          ..cubicTo(66, 17, 54, 4, 36, 4)
          ..close();
      case 'BEAUTY':
        return Path()
          ..moveTo(36, 80)
          ..cubicTo(30, 73, 6, 52, 6, 29)
          ..cubicTo(6, 8, 31, 2, 36, 23)
          ..cubicTo(41, 2, 66, 8, 66, 29)
          ..cubicTo(66, 52, 42, 73, 36, 80)
          ..close();
      default:
        return Path()
          ..addOval(const Rect.fromLTWH(10, 5, 52, 52))
          ..moveTo(21, 47)
          ..lineTo(36, 82)
          ..lineTo(51, 47)
          ..close();
    }
  }

  static Path _starPath() {
    const center = Offset(36, 34);
    const outerRadius = 31.0;
    const innerRadius = 14.0;
    final path = Path();
    for (var index = 0; index < 10; index++) {
      final radius = index.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + index * math.pi / 5;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path
      ..close()
      ..moveTo(27, 54)
      ..lineTo(36, 84)
      ..lineTo(45, 54)
      ..close();
    return path;
  }

  static Color _colorFor(String category) {
    switch (category) {
      case 'DINING':
        return const Color(0xFFEF4444);
      case 'WELLNESS':
        return const Color(0xFF10B981);
      case 'ENTERTAINMENT':
        return const Color(0xFF8B5CF6);
      case 'RETAIL':
        return const Color(0xFFE5A93C);
      case 'TRAVEL':
        return const Color(0xFF3B82F6);
      case 'BEAUTY':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF1A1A2E);
    }
  }
}
