// lib/presentation/screens/notifications/widgets/notifications_top_bar.dart
//
// Bilah atas halaman Notifikasi (node Figma `546:1842`).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Header putih dengan tombol kembali dan judul "Notifikasi".
class NotificationsTopBar extends StatelessWidget {
  const NotificationsTopBar({
    super.key,
    required this.scale,
    required this.topInset,
    this.onBack,
  });

  final double scale;

  /// Tinggi area status bar agar posisi konten mengikuti desain.
  final double topInset;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30 * scale),
        ),
        boxShadow: const <BoxShadow>[
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
                  key: const Key('notifications_back'),
                  onTap: onBack,
                  child: Container(
                    width: 49 * scale,
                    height: 49 * scale,
                    decoration: const BoxDecoration(
                      color: SojuColors.field,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20 * scale,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                // Spasi simetris agar judul tetap di tengah.
                SizedBox(width: 49 * scale),
              ],
            ),
            Text(
              'Notifikasi',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 19 * scale,
                fontWeight: FontWeight.w600,
                color: SojuColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
