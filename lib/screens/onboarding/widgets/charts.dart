import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../theme/soju_colors.dart';

/// Bar chart ringkas (mis. Run-Rate di Onboarding 2) — batang biru/hijau.
class MiniBars extends StatelessWidget {
  const MiniBars({
    super.key,
    this.values = const [0.35, 0.5, 0.45, 0.62, 0.7, 1.0],
    this.barWidth = 24,
    this.activeIndex = 5,
  });

  final List<double> values;
  final double barWidth;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(values.length, (i) {
        final h = 44.0 * values[i];
        final color = i == activeIndex
            ? SojuColors.green
            : (i >= values.length - 2
                ? SojuColors.primary
                : SojuColors.primarySoft);
        return Container(
          width: barWidth,
          height: h.clamp(4, 60),
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// Area chart dengan garis tegas + titik ujung (mimic chart Omzet Onboarding 3).
class AreaChart extends StatelessWidget {
  const AreaChart({
    super.key,
    this.points = const [0.3, 0.45, 0.4, 0.6, 0.55, 0.75, 0.9],
    this.lineColor = SojuColors.primary,
    this.strokeWidth = 3,
    this.fill = true,
  });

  final List<double> points;
  final Color lineColor;
  final double strokeWidth;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(280, 80),
      painter: _AreaChartPainter(
        points: points,
        lineColor: lineColor,
        strokeWidth: strokeWidth,
        fill: fill,
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  const _AreaChartPainter({
    required this.points,
    required this.lineColor,
    required this.strokeWidth,
    required this.fill,
  });

  final List<double> points;
  final Color lineColor;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final dx = size.width / (points.length - 1);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height - (points[i].clamp(0.0, 1.0) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withOpacity(0.28),
              lineColor.withOpacity(0.02),
            ],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Titik akhir
    final lastX = (points.length - 1) * dx;
    final lastY = size.height - (points.last.clamp(0.0, 1.0) * size.height);
    canvas.drawCircle(
      Offset(lastX, lastY),
      strokeWidth + 2,
      Paint()..color = lineColor,
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      strokeWidth + 2 - 3.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter old) =>
      old.points != points || old.lineColor != lineColor;
}

/// Garis kecil onda-onda dekoratif di bawah kartu (mimic vector wave Figma).
class WaveDivider extends StatelessWidget {
  const WaveDivider({super.key, this.color = const Color(0xFFC2C6D8)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(358, 24),
        painter: _WavePainter(color.withOpacity(0.35)),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path();
    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height / 2 + math.sin(x / 60.0) * 6;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.color != color;
}