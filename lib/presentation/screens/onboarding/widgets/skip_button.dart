import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Tautan teks sekunder "Lewati" di bawah tombol utama.
class SkipButton extends StatelessWidget {
  const SkipButton({
    super.key,
    required this.onPressed,
    required this.scale,
    this.label = 'Lewati',
  });

  final VoidCallback onPressed;
  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 32 * scale,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: SojuColors.inkMuted,
          textStyle: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w500,
            height: 22.86 / 18,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
