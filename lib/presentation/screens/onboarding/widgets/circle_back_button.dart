import 'package:flutter/material.dart';

import '../../../../core/themes/soju_colors.dart';

/// Tombol kembali bulat (abu muda) di sudut kiri atas layar onboarding.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({
    super.key,
    required this.onPressed,
    required this.scale,
  });

  final VoidCallback onPressed;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.surfaceMuted,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 50 * scale,
          height: 50 * scale,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18 * scale,
            color: SojuColors.ink,
          ),
        ),
      ),
    );
  }
}
