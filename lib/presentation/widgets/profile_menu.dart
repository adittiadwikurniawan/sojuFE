import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';
import '../screens/profile/models/profile_view_data.dart';
import 'profile_menu_card.dart';

/// Menampilkan menu Profil / Menu Akun dari avatar.
///
/// Menu ditutup saat area luar diketuk. Menekan "Keluar" membuka dialog
/// konfirmasi; setelah dikonfirmasi, [onLogout] dipanggil. Bila callback belum
/// disambungkan, aplikasi hanya menampilkan pesan mock agar alur tetap aman.
Future<void> showProfileMenu(
  BuildContext context, {
  ProfileViewData data = ProfileViewData.sample,
  VoidCallback? onLogout,
}) async {
  final bool? requestLogout = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup menu profil',
    barrierColor: const Color(0x33000000),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (
      BuildContext dialogContext,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      final double width = MediaQuery.sizeOf(dialogContext).width;
      final double scale = math.min(width / 430, 1);
      return Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 96 * scale),
              child: ProfileMenuCard(
                data: data,
                scale: scale,
                onLogout: () => Navigator.of(dialogContext).pop(true),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          alignment: Alignment.topLeft,
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );

  if (requestLogout != true || !context.mounted) {
    return;
  }

  final bool confirmed = await _confirmLogout(context, data);
  if (!confirmed || !context.mounted) {
    return;
  }

  if (onLogout != null) {
    onLogout();
    return;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text('Berhasil keluar dari akun (mock).')),
    );
}

Future<bool> _confirmLogout(
  BuildContext context,
  ProfileViewData data,
) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text(
          'Keluar dari akun?',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Anda akan keluar dari akun ${data.name}. '
          'Data yang belum disimpan tidak akan tersimpan.',
          style: const TextStyle(
            fontFamily: AppTypography.family,
            height: 1.4,
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('profile_logout_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: AppTypography.family),
            ),
          ),
          FilledButton(
            key: const Key('profile_logout_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: SojuColors.expense,
              foregroundColor: SojuColors.surface,
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
