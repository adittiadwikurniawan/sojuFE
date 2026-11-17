// lib/presentation/screens/audit/widgets/audit_top_bar.dart
//
// Bilah atas layar Audit & Stok (konsisten dengan gaya frame Figma
// `546:2937` Analytics: permukaan putih, sudut bawah membulat).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Bilah atas layar Audit & Stok dengan tombol kembali.
class AuditTopBar extends StatelessWidget {
  const AuditTopBar({
    super.key,
    required this.scale,
    required this.topInset,
    required this.title,
    this.onBack,
  });

  final double scale;

  /// Tinggi area status bar agar posisi konten mengikuti desain.
  final double topInset;
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 1),
            blurRadius: 14,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        math.max(0, 20 * scale - topInset),
        16 * scale,
        18 * scale,
      ),
      child: SizedBox(
        height: 52 * scale,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 52 * scale,
                    height: 52 * scale,
                    decoration: const BoxDecoration(
                      color: SojuColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24 * scale,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                // Spasi simetris agar judul tetap di tengah.
                SizedBox(width: 52 * scale),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
