import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Smooth Bezier Sparkline mini-chart matching the Novbank "Overview" card rows.
class SparklineChart extends StatelessWidget {
  final List<double> points;
  final Color color;
  final double width;
  final double height;
  final double strokeWidth;

  const SparklineChart({
    super.key,
    required this.points,
    required this.color,
    this.width = 72,
    this.height = 32,
    this.strokeWidth = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          points: points,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final double strokeWidth;

  _SparklinePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minVal = points.reduce(math.min);
    final maxVal = points.reduce(math.max);
    final range = (maxVal - minVal).abs() < 0.001 ? 1.0 : (maxVal - minVal);

    final offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final dx = (i / (points.length - 1)) * size.width;
      final normalized = (points[i] - minVal) / range;
      final dy = size.height - (normalized * (size.height - 6)) - 3;
      offsets.add(Offset(dx, dy));
    }

    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 0; i < offsets.length - 1; i++) {
      final current = offsets[i];
      final next = offsets[i + 1];
      final controlX1 = current.dx + (next.dx - current.dx) * 0.45;
      final controlX2 = current.dx + (next.dx - current.dx) * 0.55;
      path.cubicTo(controlX1, current.dy, controlX2, next.dy, next.dx, next.dy);
    }

    // Subtle area fill underneath sparkline
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.18),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

/// Circular arc percentage gauge matching the top-right badge of the Novbank "Financial goals" card.
class CircularArcGauge extends StatelessWidget {
  final double percentage;
  final Color activeColor;
  final Color trackColor;
  final Color textColor;
  final double size;

  const CircularArcGauge({
    super.key,
    required this.percentage,
    required this.activeColor,
    required this.trackColor,
    required this.textColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percentage.clamp(0.0, 100.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcGaugePainter(
              progress: clamped / 100.0,
              activeColor: activeColor,
              trackColor: trackColor,
            ),
          ),
          Text(
            '${clamped.toStringAsFixed(0)}%',
            style: TextStyle(
              color: textColor,
              fontSize: size * 0.25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _ArcGaugePainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 4.5;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    const startAngle = math.pi * 0.8;
    const sweepTotal = math.pi * 1.4;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
          rect, startAngle, sweepTotal * progress, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor;
  }
}
