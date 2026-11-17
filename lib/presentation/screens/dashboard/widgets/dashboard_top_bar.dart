import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Bar putih di atas layar beranda: avatar, medan pencarian, dan tombol
/// notifikasi (frame `546:1616`, node `546:1737`).
class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    required this.scale,
    required this.topInset,
    required this.searchHint,
    required this.avatarAsset,
    this.onAvatarTap,
    this.onSearchTap,
    this.onNotificationTap,
  });

  final double scale;

  /// Tinggi area status bar; dipakai agar posisi baris konten tetap
  /// mengikuti desain (34px dari tepi atas layar).
  final double topInset;

  final String searchHint;
  final String avatarAsset;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

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
        17 * scale,
        math.max(0, 34 * scale - topInset),
        16 * scale,
        29 * scale,
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            key: const Key('dashboard_avatar'),
            onTap: onAvatarTap,
            child: ClipOval(
              child: Image.asset(
                avatarAsset,
                width: 50 * scale,
                height: 50 * scale,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 19 * scale),
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: _SearchField(scale: scale, hint: searchHint),
            ),
          ),
          SizedBox(width: 18 * scale),
          _NotificationButton(scale: scale, onTap: onNotificationTap),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.scale, required this.hint});

  final double scale;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50 * scale,
      decoration: BoxDecoration(
        color: SojuColors.field,
        borderRadius: BorderRadius.circular(30.5 * scale),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15 * scale),
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Icon(Icons.search, size: 21 * scale, color: Colors.black),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 21 * scale,
                fontWeight: FontWeight.w400,
                color: SojuColors.hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50 * scale,
        height: 50 * scale,
        decoration: const BoxDecoration(
          color: SojuColors.field,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.notifications_none,
              size: 24 * scale,
              color: Colors.black,
            ),
            Positioned(
              top: 11 * scale,
              right: 13 * scale,
              child: Container(
                width: 5.8 * scale,
                height: 5.8 * scale,
                decoration: const BoxDecoration(
                  color: SojuColors.alert,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
