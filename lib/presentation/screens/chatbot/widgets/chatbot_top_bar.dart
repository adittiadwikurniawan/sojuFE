import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/themes/soju_colors.dart';

/// Bilah atas layar Chatbot Soju (frame `546:3687`, node `546:3691`).
///
/// Tombol kiri berfungsi sebagai navigasi kembali: dari tampilan chat kembali
/// ke daftar riwayat, dan dari daftar riwayat kembali ke layar sebelumnya
/// (Beranda) atau rute cadangan yang diberikan pemanggil.
///
/// Untuk `SUPER_ADMIN`, tombol Reindex basis pengetahuan AI ditampilkan di sisi
/// kanan berdampingan dengan tombol notifikasi.
class ChatbotTopBar extends StatelessWidget {
  const ChatbotTopBar({
    super.key,
    required this.scale,
    required this.topInset,
    this.onBack,
    this.onNotificationTap,
    this.showReindexButton = false,
    this.isReindexing = false,
    this.onReindexTap,
  });

  final double scale;

  /// Tinggi area status bar agar posisi konten mengikuti desain.
  final double topInset;

  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;

  /// Hanya `true` untuk pengguna `SUPER_ADMIN`.
  final bool showReindexButton;
  final bool isReindexing;
  final VoidCallback? onReindexTap;

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
        height: 48 * scale,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                _CircleButton(
                  scale: scale,
                  icon: Icons.arrow_back,
                  label: 'Kembali',
                  onTap: onBack,
                ),
                const Spacer(),
                if (showReindexButton) ...<Widget>[
                  _ReindexButton(
                    key: const Key('ai_reindex_button'),
                    scale: scale,
                    isReindexing: isReindexing,
                    onTap: isReindexing ? null : onReindexTap,
                  ),
                  SizedBox(width: 8 * scale),
                ],
                _CircleButton(
                  scale: scale,
                  icon: Icons.notifications_none,
                  label: 'Notifikasi',
                  showDot: true,
                  onTap: onNotificationTap,
                ),
              ],
            ),
            IgnorePointer(
              child: Image.asset(
                'assets/images/logo_bukukita.png',
                height: 34 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReindexButton extends StatelessWidget {
  const _ReindexButton({
    super.key,
    required this.scale,
    required this.isReindexing,
    this.onTap,
  });

  final double scale;
  final bool isReindexing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Reindex Basis Pengetahuan AI',
      child: Semantics(
        button: true,
        label: 'Reindex Basis Pengetahuan AI',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44 * scale,
            height: 44 * scale,
            decoration: const BoxDecoration(
              color: SojuColors.infoSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isReindexing
                ? SizedBox(
                    width: 18 * scale,
                    height: 18 * scale,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(SojuColors.primary),
                    ),
                  )
                : Icon(
                    Icons.sync_rounded,
                    size: 20 * scale,
                    color: SojuColors.badgeBlue,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.scale,
    required this.icon,
    required this.label,
    this.showDot = false,
    this.onTap,
  });

  final double scale;
  final IconData icon;
  final String label;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48 * scale,
          height: 48 * scale,
          decoration: const BoxDecoration(
            color: SojuColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(icon, size: 22 * scale, color: Colors.black),
              if (showDot)
                Positioned(
                  top: 10 * scale,
                  right: 12 * scale,
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
      ),
    );
  }
}
