import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Pembatas "atau" di antara tombol masuk dan opsi masuk lain
/// (frame `546:1497`, node `546:1540`).
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.scale, this.label = 'atau'});

  final double scale;
  final String label;

  static const Color _line = Color(0xFFCFC4C5);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(height: 1.2 * scale, color: _line),
          Container(
            color: SojuColors.surface,
            padding: EdgeInsets.symmetric(horizontal: 14 * scale),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w400,
                color: SojuColors.fieldIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
