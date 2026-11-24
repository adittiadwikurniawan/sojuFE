// lib/presentation/widgets/profile/profile_buttons.dart
//
// Tombol aksi layar profil.

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';

/// Tombol utama selebar kontainer.
class ProfilePrimaryButton extends StatelessWidget {
  const ProfilePrimaryButton({
    super.key,
    required this.scale,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final double scale;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 56 * scale,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: SojuColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SojuColors.profileMuted,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15 * scale),
          ),
          textStyle: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22 * scale,
                height: 22 * scale,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Tombol garis untuk aksi sekunder seperti Keluar.
class ProfileOutlineButton extends StatelessWidget {
  const ProfileOutlineButton({
    super.key,
    required this.scale,
    required this.label,
    required this.onPressed,
    this.foregroundColor = SojuColors.ink,
    this.borderColor = SojuColors.profileMuted,
  });

  final double scale;
  final String label;
  final VoidCallback? onPressed;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56 * scale,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15 * scale),
          ),
          textStyle: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
