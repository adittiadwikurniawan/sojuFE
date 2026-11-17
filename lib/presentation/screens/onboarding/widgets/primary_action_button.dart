import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Tombol aksi utama berwarna biru pada kartu onboarding.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.scale,
  });

  final String label;
  final VoidCallback onPressed;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15 * scale),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SojuColors.primary.withOpacity(0.24),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58 * scale,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: SojuColors.primary,
            foregroundColor: SojuColors.surface,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13.5 * scale),
            ),
            textStyle: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 15.75 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.16 * scale,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
