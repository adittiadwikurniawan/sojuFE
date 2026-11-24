// lib/presentation/widgets/profile/profile_tiles.dart
//
// Baris menu, baris pengaturan, dan baris switch pada layar profil.

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';

/// Baris menu besar dengan kotak ikon (frame Profil).
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.scale,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final double scale;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15 * scale),
        onTap: onTap,
        child: SizedBox(
          height: 72 * scale,
          child: Row(
            children: <Widget>[
              Container(
                width: 72 * scale,
                height: 72 * scale,
                decoration: BoxDecoration(
                  color: SojuColors.profileIconBackground,
                  borderRadius: BorderRadius.circular(15 * scale),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 32 * scale,
                  color: SojuColors.ink,
                ),
              ),
              SizedBox(width: 20 * scale),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: SojuColors.ink,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 28 * scale,
                color: SojuColors.profileMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Baris pengaturan sederhana.
class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
    required this.scale,
    required this.label,
    this.onTap,
    this.showChevron = true,
  });

  final double scale;
  final String label;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52 * scale,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w500,
                    color: SojuColors.ink,
                  ),
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 26 * scale,
                  color: SojuColors.profileMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Baris preferensi notifikasi dengan switch.
class ProfileToggleTile extends StatelessWidget {
  const ProfileToggleTile({
    super.key,
    required this.scale,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.switchKey,
  });

  final double scale;
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14 * scale),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w500,
                    color: SojuColors.ink,
                  ),
                ),
                if (description != null) ...<Widget>[
                  SizedBox(height: 4 * scale),
                  Text(
                    description!,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12 * scale,
                      height: 1.4,
                      color: SojuColors.profileHelpBody,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 16 * scale),
          Switch(
            key: switchKey,
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: SojuColors.profileSwitchActive,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: SojuColors.profileSwitchInactive,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
