import 'package:flutter/material.dart';

import '../../../../core/themes/soju_colors.dart';

/// Bentuk gradien yang "memercik" dari lingkaran kecil di tengah layar menjadi
/// latar penuh (keyframe `Ob 1`–`Ob 5` pada Figma).
///
/// Ukuran [width]/[height] dinyatakan dalam px pada frame desain 430 dan
/// dikalikan [scale] agar proporsional di layar lain.
class SplashBlob extends StatelessWidget {
  const SplashBlob({
    super.key,
    required this.width,
    required this.height,
    required this.scale,
  });

  final double width;
  final double height;
  final double scale;

  /// Radius sudut pada Figma; otomatis terpotong menjadi lingkaran saat bentuk
  /// masih kecil.
  static const double _radius = 142;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * scale,
      height: height * scale,
      decoration: BoxDecoration(
        gradient: SojuColors.splash,
        borderRadius: BorderRadius.circular(_radius * scale),
      ),
    );
  }
}
