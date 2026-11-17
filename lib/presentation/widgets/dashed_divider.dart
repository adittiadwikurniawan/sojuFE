import 'package:flutter/material.dart';

/// Garis putus-putus horizontal (frame `546:2937`,
/// node `546:2957` "Dashed separator").
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.height = 1,
    this.dashWidth = 4,
    this.dashGap = 3,
    this.color = const Color(0xFFE6E8EA),
  });

  /// Tinggi garis.
  final double height;

  /// Panjang satu potongan garis.
  final double dashWidth;

  /// Jarak antar potongan.
  final double dashGap;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          dashWidth: dashWidth,
          dashGap: dashGap,
          color: color,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.dashWidth,
    required this.dashGap,
    required this.color,
  });

  final double dashWidth;
  final double dashGap;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.butt;

    double x = 0;
    while (x < size.width) {
      final double end = (x + dashWidth).clamp(0, size.width);
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(end, size.height / 2),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) {
    return oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.color != color;
  }
}
