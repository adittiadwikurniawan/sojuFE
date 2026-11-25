// lib/presentation/screens/profile/profile_screen.dart
//
// Layar Profil (frame Figma `546:5561`).
//
// Menu utama menuju Akun Saya, Pengaturan, dan Pusat Bantuan. Data identitas
// dimuat lewat controller mock yang siap diganti endpoint profil.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../providers/profile/profile_controller.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/profile/profile_message_banner.dart';
import '../../widgets/profile/profile_tiles.dart';
import '../../widgets/profile/profile_top_bar.dart';
import 'models/profile_view_data.dart';

/// Layar menu profil.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
    this.onAccount,
    this.onSettings,
    this.onHelp,
  });

  final ProfileController Function() controllerFactory;
  final VoidCallback? onBack;

  /// Aksi membuka Akun Saya. Profil dimuat ulang setelah layar kembali agar
  /// perubahan nama/foto langsung terlihat.
  final Future<void> Function()? onAccount;

  final VoidCallback? onSettings;
  final VoidCallback? onHelp;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAccount() async {
    final Future<void> Function()? callback = widget.onAccount;
    if (callback == null) {
      return;
    }
    await callback();
    if (!mounted) {
      return;
    }
    await _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('profile_screen'),
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
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return _body(
                    context,
                    scale: scale,
                    topInset: topInset,
                    state: _controller.state,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context, {
    required double scale,
    required double topInset,
    required ProfileState state,
  }) {
    final ProfileEntity? profile = state.profile;
    final String name = profile?.name ?? ProfileViewData.sample.name;
    final String email = profile?.email ?? ProfileViewData.sample.email;
    final String? asset = profile?.avatarAsset ??
        (profile == null ? ProfileViewData.sample.avatarAsset : null);
    final String initials = profile?.initials ?? _initialsOf(name);

    return Column(
      children: <Widget>[
        ProfileTopBar(
          scale: scale,
          topInset: topInset,
          title: 'Profil',
          onBack: widget.onBack,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewport) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 40 * scale),
                        ProfileAvatar(
                          key: const Key('profile_avatar'),
                          size: 105 * scale,
                          scale: scale,
                          initials: initials,
                          assetPath: asset,
                          imageUrl: profile?.avatarUrl,
                        ),
                        SizedBox(height: 14 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24 * scale,
                          ),
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700,
                              color: SojuColors.ink,
                            ),
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24 * scale,
                          ),
                          child: Text(
                            email,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 14 * scale,
                              color: SojuColors.ink,
                            ),
                          ),
                        ),
                        if (state.hasError) ...<Widget>[
                          SizedBox(height: 16 * scale),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24 * scale,
                            ),
                            child: ProfileMessageBanner(
                              scale: scale,
                              message:
                                  state.errorMessage ?? 'Profil gagal dimuat.',
                            ),
                          ),
                        ],
                        SizedBox(height: 28 * scale),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: SojuColors.surface,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(60 * scale),
                              ),
                            ),
                            padding: EdgeInsets.fromLTRB(
                              42 * scale,
                              61 * scale,
                              42 * scale,
                              40 * scale + MediaQuery.paddingOf(context).bottom,
                            ),
                            child: Column(
                              children: <Widget>[
                                ProfileMenuTile(
                                  key: const Key('profile_account_menu'),
                                  scale: scale,
                                  icon: Icons.person_outline_rounded,
                                  label: 'Akun Saya',
                                  onTap: widget.onAccount == null
                                      ? null
                                      : _openAccount,
                                ),
                                SizedBox(height: 37 * scale),
                                ProfileMenuTile(
                                  key: const Key('profile_settings_menu'),
                                  scale: scale,
                                  icon: Icons.settings_outlined,
                                  label: 'Pengaturan',
                                  onTap: widget.onSettings,
                                ),
                                SizedBox(height: 37 * scale),
                                ProfileMenuTile(
                                  key: const Key('profile_help_menu'),
                                  scale: scale,
                                  icon: Icons.help_outline_rounded,
                                  label: 'Pusat Bantuan',
                                  onTap: widget.onHelp,
                                ),
                                const Spacer(),
                                Padding(
                                  padding: EdgeInsets.only(top: 72 * scale),
                                  child: Text(
                                    'Anda bergabung dengan Buku Kita pada '
                                    'September 2021. Butuh bantuan? Hubungi '
                                    'tim dukungan Buku Kita.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 12 * scale,
                                      height: 1.5,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _initialsOf(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
