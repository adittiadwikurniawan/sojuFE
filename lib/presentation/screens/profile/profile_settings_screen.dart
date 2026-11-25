// lib/presentation/screens/profile/profile_settings_screen.dart
//
// Layar Pengaturan (frame Figma `546:5611`).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../widgets/profile/profile_buttons.dart';
import '../../widgets/profile/profile_tiles.dart';
import '../../widgets/profile/profile_top_bar.dart';
import '../../widgets/profile_menu.dart';
import 'models/profile_view_data.dart';

/// Layar pengaturan akun.
class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({
    super.key,
    this.onBack,
    this.onChangePassword,
    this.onNotifications,
    this.onTerms,
    this.onLogout,
    this.profile = ProfileViewData.sample,
  });

  final VoidCallback? onBack;
  final VoidCallback? onChangePassword;
  final VoidCallback? onNotifications;
  final VoidCallback? onTerms;
  final VoidCallback? onLogout;
  final ProfileViewData profile;

  Future<void> _handleLogout(BuildContext context) async {
    final bool confirmed = await confirmLogout(context, profile);
    if (!confirmed || !context.mounted) {
      return;
    }
    if (onLogout != null) {
      onLogout!();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil keluar dari akun (mock).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('profile_settings_screen'),
      backgroundColor: SojuColors.profileBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = math.min(constraints.maxWidth, 480);
          final double scale = width / 430;
          final double topInset = MediaQuery.paddingOf(context).top;
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: Column(
                children: <Widget>[
                  ProfileTopBar(
                    scale: scale,
                    topInset: topInset,
                    title: 'Pengaturan',
                    onBack: onBack,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        22 * scale,
                        22 * scale,
                        22 * scale,
                        32 * scale + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ProfileSectionLabel(scale: scale, label: 'Utama'),
                          SizedBox(height: 10 * scale),
                          Container(
                            decoration: BoxDecoration(
                              color: SojuColors.surface,
                              borderRadius: BorderRadius.circular(15 * scale),
                              border: Border.all(
                                color: SojuColors.profileDivider,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18 * scale,
                            ),
                            child: Column(
                              children: <Widget>[
                                ProfileSettingsTile(
                                  key: const Key('profile_change_password'),
                                  scale: scale,
                                  label: 'Ganti Password',
                                  onTap: onChangePassword,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: SojuColors.profileDivider,
                                ),
                                ProfileSettingsTile(
                                  key: const Key('profile_notifications'),
                                  scale: scale,
                                  label: 'Pemberitahuan',
                                  onTap: onNotifications,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24 * scale),
                          ProfileSectionLabel(scale: scale, label: 'Keamanan'),
                          SizedBox(height: 10 * scale),
                          Container(
                            decoration: BoxDecoration(
                              color: SojuColors.surface,
                              borderRadius: BorderRadius.circular(15 * scale),
                              border: Border.all(
                                color: SojuColors.profileDivider,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18 * scale,
                            ),
                            child: ProfileSettingsTile(
                              key: const Key('profile_terms'),
                              scale: scale,
                              label: 'Syarat & Ketentuan',
                              onTap: onTerms,
                            ),
                          ),
                          SizedBox(height: 30 * scale),
                          ProfileOutlineButton(
                            key: const Key('profile_logout_button'),
                            scale: scale,
                            label: 'Keluar',
                            foregroundColor: SojuColors.expense,
                            borderColor: SojuColors.expense.withValues(alpha: 0.5),
                            onPressed: () => _handleLogout(context),
                          ),
                          SizedBox(height: 24 * scale),
                          Center(
                            child: Text(
                              'Buku Kita v1.1',
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 12 * scale,
                                color: SojuColors.profileFooter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
