import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// Interactive Scratch Card with true finger-gesture canvas erasing physics.
/// Requires deliberate multi-stroke scrubbing to reach reward threshold.
/// Clean, flat UI without gaudy AI gradients.
class ScratchCardWidget extends StatefulWidget {
  final Widget child;
  final double thresholdPercent;
  final VoidCallback onThresholdReached;

  const ScratchCardWidget({
    super.key,
    required this.child,
    this.thresholdPercent = 0.65,
    required this.onThresholdReached,
  });

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  final List<Offset> _points = [];
  final Set<int> _coveredBuckets = {};
  bool _revealed = false;
  Size? _cardSize;

  static const int _gridCols = 8;
  static const int _gridRows = 8;
  static const int _totalBuckets = _gridCols * _gridRows; // 64 sectors

  void _addPoint(Offset localPosition) {
    if (_revealed) return;
    setState(() {
      _points.add(localPosition);
    });

    _recordBucketCoverage(localPosition);
  }

  void _recordBucketCoverage(Offset localPosition) {
    if (_cardSize == null || _cardSize!.width <= 0 || _cardSize!.height <= 0) return;

    final cellW = _cardSize!.width / _gridCols;
    final cellH = _cardSize!.height / _gridRows;

    final col = (localPosition.dx / cellW).floor().clamp(0, _gridCols - 1);
    final row = (localPosition.dy / cellH).floor().clamp(0, _gridRows - 1);
    final bucketIndex = row * _gridCols + col;

    _coveredBuckets.add(bucketIndex);

    // Calculate actual 2D surface coverage ratio
    final coverageRatio = _coveredBuckets.length / _totalBuckets.toDouble();

    // User must scratch across at least 65% of the sectors AND have at least 120 gesture samples
    if (coverageRatio >= widget.thresholdPercent && _points.length >= 120 && !_revealed) {
      _revealed = true;
      HapticFeedback.mediumImpact();
      widget.onThresholdReached();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _cardSize = Size(constraints.maxWidth, constraints.maxHeight);

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Underneath: Prize content
              widget.child,

              // On top: Scratch Foil Mask
              if (!_revealed)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) => _addPoint(details.localPosition),
                  onPanUpdate: (details) => _addPoint(details.localPosition),
                  onPanEnd: (_) {
                    if (_revealed) return;
                    // Check if threshold was met at pan lift
                    final coverageRatio = _coveredBuckets.length / _totalBuckets.toDouble();
                    if (coverageRatio >= widget.thresholdPercent && _points.length >= 100) {
                      _revealed = true;
                      HapticFeedback.mediumImpact();
                      widget.onThresholdReached();
                      setState(() {});
                    }
                  },
                  child: CustomPaint(
                    painter: _ScratchFoilPainter(points: List.from(_points)),
                    child: Center(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _points.length > 30 ? 0.0 : 1.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceDark.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'SCRATCH HERE WITH FINGER',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _ScratchFoilPainter extends CustomPainter {
  final List<Offset> points;

  const _ScratchFoilPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 1. Draw flat silver/slate foil surface
    final foilPaint = Paint()
      ..color = const Color(0xFF1E293B) // Premium dark slate foil
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), foilPaint);

    // Subtle pattern lines to resemble real scratch card security pattern
    final patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    for (double i = -size.height; i < size.width; i += 18) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        patternPaint,
      );
    }

    // 2. Erase user scratches with BlendMode.clear
    final eraserPaint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 42.0;

    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points.getRange(0, i + 1).last.dx, points.getRange(0, i + 1).last.dy);
      }
      canvas.drawPath(path, eraserPaint);

      // Also draw circular dab at each point for smooth scrubbing response
      for (final pt in points) {
        canvas.drawCircle(pt, 21.0, eraserPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchFoilPainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}
