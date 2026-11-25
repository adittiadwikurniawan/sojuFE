// lib/presentation/widgets/profile/profile_message_banner.dart
//
// Banner pesan galat/sukses ringan pada layar profil.

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';

/// Banner pesan dengan ikon.
class ProfileMessageBanner extends StatelessWidget {
  const ProfileMessageBanner({
    super.key,
    required this.scale,
    required this.message,
    this.isError = true,
  });

  final double scale;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color background =
        isError ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final Color border =
        isError ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0);
    final Color foreground =
        isError ? const Color(0xFFB91C1C) : const Color(0xFF047857);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 20 * scale,
            color: foreground,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12.5 * scale,
                height: 1.4,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
