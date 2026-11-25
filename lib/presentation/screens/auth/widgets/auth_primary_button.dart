import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Tombol aksi utama pada layar auth (frame `546:1497` node `546:1528`,
/// frame `546:1547` node `546:1601`).
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.scale,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final double scale;
  final String label;
  final VoidCallback onPressed;

  /// Menampilkan indikator proses dan menonaktifkan tombol.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56 * scale,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: SojuColors.primary,
          foregroundColor: SojuColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15 * scale),
          ),
          textStyle: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 16.3 * scale,
            fontWeight: FontWeight.w500,
            height: 23.3 / 16.3,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20 * scale,
                width: 20 * scale,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    SojuColors.surface,
                  ),
                ),
              )
            : Text(label),
      ),
    );
  }
}
