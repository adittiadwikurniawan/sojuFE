import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Wordmark "Buku Kita": logo (aset) di atas teks bergradien dengan garis
/// tepi putih.
class BukuKitaWordmark extends StatelessWidget {
  const BukuKitaWordmark({super.key, required this.scale});

  final double scale;

  static const String _text = 'Buku Kita';

  @override
  Widget build(BuildContext context) {
    final TextStyle base = TextStyle(
      fontFamily: AppTypography.wordmarkFamily,
      fontSize: 44 * scale,
      fontWeight: FontWeight.w700,
      height: 32 / 44,
      letterSpacing: 0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          'assets/images/logo_bukukita.png',
          width: 222 * scale,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 8 * scale),
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              _text,
              style: base.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2 * scale
                  ..color = SojuColors.surface,
              ),
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) =>
                  SojuColors.wordmark.createShader(bounds),
              child: Text(
                _text,
                style: base.copyWith(color: SojuColors.surface),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
