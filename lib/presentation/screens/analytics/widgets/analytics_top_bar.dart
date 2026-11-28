import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Bilah atas layar Analytics (frame `546:2937`, node `546:2973`).
class AnalyticsTopBar extends StatelessWidget {
  const AnalyticsTopBar({
    super.key,
    required this.scale,
    required this.topInset,
    this.title = 'Analytics',
    this.onBack,
    this.onNotificationTap,
    this.onAddTap,
    this.onExportTap,
    this.isExporting = false,
  });

  final double scale;

  /// Tinggi area status bar agar posisi konten mengikuti desain.
  final double topInset;

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onExportTap;
  final bool isExporting;

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
        math.max(0, 24 * scale - topInset),
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
                _CircleButton(
                  key: const Key('analytics_back'),
                  scale: scale,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
                const Spacer(),
                _CircleButton(
                  scale: scale,
                  icon: Icons.notifications_none,
                  showDot: true,
                  onTap: onNotificationTap,
                ),
                SizedBox(width: 8 * scale),
                Tooltip(
                  message: 'Unduh Spreadsheet',
                  child: _CircleButton(
                    key: const Key('analytics_top_export'),
                    scale: scale,
                    icon: Icons.file_download_outlined,
                    isLoading: isExporting,
                    onTap: isExporting ? null : onExportTap,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 24 * scale,
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    super.key,
    required this.scale,
    required this.icon,
    this.showDot = false,
    this.isLoading = false,
    this.onTap,
  });

  final double scale;
  final IconData icon;
  final bool showDot;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52 * scale,
        height: 52 * scale,
        decoration: const BoxDecoration(
          color: SojuColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (isLoading)
              SizedBox(
                width: 20 * scale,
                height: 20 * scale,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SojuColors.primary,
                ),
              )
            else
              Icon(icon, size: 24 * scale, color: Colors.black),
            if (showDot)
              Positioned(
                top: 12 * scale,
                right: 14 * scale,
                child: Container(
                  width: 6 * scale,
                  height: 6 * scale,
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
