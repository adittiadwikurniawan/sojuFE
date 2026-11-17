import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';
import '../screens/profile/models/profile_view_data.dart';

/// Kartu menu Profil / Menu Akun dari Figma `622:1156` varian `Menu=Terbuka`.
///
/// Sesuai PRD, kartu hanya menampilkan identitas akun aktif dan aksi Keluar.
/// Baris "Tambah Akun" dan "Kelola Akun" dari desain tidak dirender karena
/// endpoint pengelolaan akun belum tersedia.
class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    super.key,
    required this.data,
    required this.onLogout,
    this.scale = 1,
  });

  final ProfileViewData data;
  final VoidCallback onLogout;

  /// Skala dari lebar desain 284 px.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: SojuColors.surface,
      elevation: 10,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(22 * s),
      child: Container(
        key: const Key('profile_menu_card'),
        width: 284 * s,
        padding: EdgeInsets.all(20 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22 * s),
          border: Border.all(color: SojuColors.profileCardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                ClipOval(
                  child: Image.asset(
                    data.avatarAsset,
                    width: 35 * s,
                    height: 35 * s,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 16 * s,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 3 * s),
                      Text(
                        data.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 11.5 * s,
                          height: 1.2,
                          fontWeight: FontWeight.w400,
                          color: SojuColors.analyticsMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * s),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.6 * s,
                    vertical: 4.3 * s,
                  ),
                  decoration: BoxDecoration(
                    color: SojuColors.profileRoleBadge,
                    borderRadius: BorderRadius.circular(25.8 * s),
                  ),
                  child: Text(
                    data.role,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 10.5 * s,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            Container(height: 1, color: SojuColors.profileDivider),
            SizedBox(height: 8 * s),
            _LogoutRow(scale: s, onTap: onLogout),
          ],
        ),
      ),
    );
  }
}

class _LogoutRow extends StatelessWidget {
  const _LogoutRow({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('profile_logout'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4 * scale,
          vertical: 8 * scale,
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 35 * scale,
              height: 35 * scale,
              child: Icon(
                Icons.logout_rounded,
                size: 24 * scale,
                color: SojuColors.expense,
              ),
            ),
            SizedBox(width: 15 * scale),
            Text(
              'Keluar',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 16 * scale,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
