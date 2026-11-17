import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Tombol sekunder pada layar auth: latar putih dengan garis tepi.
///
/// Dipakai tombol "Lanjutkan dengan Google" (frame `546:1497`, node
/// `546:1536`) dan tombol "Batalkan" (frame `546:1361`, node `546:1418`).
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.scale,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final double scale;
  final String label;
  final VoidCallback? onPressed;

  /// Menampilkan indikator proses dan menonaktifkan tombol.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56 * scale,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: SojuColors.surface,
          foregroundColor: Colors.black,
          side: BorderSide(
            color: const Color(0xFFCFC4C5),
            width: 1.2 * scale,
          ),
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
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
