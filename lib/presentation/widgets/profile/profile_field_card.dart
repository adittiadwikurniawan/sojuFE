// lib/presentation/widgets/profile/profile_field_card.dart
//
// Kartu input data akun (Nama, Email, No Telepon).

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';

/// Kartu berisi label dan bidang teks.
class ProfileFieldCard extends StatelessWidget {
  const ProfileFieldCard({
    super.key,
    required this.scale,
    required this.label,
    required this.controller,
    this.fieldKey,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.enabled = true,
  });

  final double scale;
  final String label;
  final TextEditingController controller;
  final Key? fieldKey;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        14 * scale,
        18 * scale,
        12 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.profileFieldBackground,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(color: SojuColors.profileDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
              color: SojuColors.profileMuted,
            ),
          ),
          SizedBox(height: 2 * scale),
          TextFormField(
            key: fieldKey,
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14 * scale,
              color: SojuColors.ink,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 14 * scale,
                color: SojuColors.profileMuted,
              ),
              errorStyle: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 11 * scale,
                height: 1.3,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
