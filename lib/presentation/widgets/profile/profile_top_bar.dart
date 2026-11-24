// lib/presentation/widgets/profile/profile_top_bar.dart
//
// Bilah atas layar profil (frame Figma `546:5561` dst.).
// Judul berada di tengah, tombol kembali berbentuk lingkaran di kiri.

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';

/// Bilah atas dengan judul dan tombol kembali.
class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({
    super.key,
    required this.scale,
    required this.topInset,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final double scale;
  final double topInset;
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final double topPadding = topInset + 20 * scale;
    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30 * scale),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        15 * scale,
        topPadding,
        15 * scale,
        18 * scale,
      ),
      child: SizedBox(
        height: 52 * scale,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: _ProfileBackButton(scale: scale, onTap: onBack!),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 64 * scale),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                  height: 1.2,
                ),
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!),
          ],
        ),
      ),
    );
  }
}

/// Bilah atas dengan kolom pencarian (frame Topik).
class ProfileSearchTopBar extends StatelessWidget {
  const ProfileSearchTopBar({
    super.key,
    required this.scale,
    required this.topInset,
    required this.controller,
    required this.onChanged,
    this.onBack,
    this.searchFieldKey,
  });

  final double scale;
  final double topInset;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBack;
  final Key? searchFieldKey;

  @override
  Widget build(BuildContext context) {
    final double topPadding = topInset + 20 * scale;
    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30 * scale),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        15 * scale,
        topPadding,
        15 * scale,
        18 * scale,
      ),
      child: Row(
        children: <Widget>[
          if (onBack != null) _ProfileBackButton(scale: scale, onTap: onBack!),
          SizedBox(width: 29 * scale),
          Expanded(
            child: Container(
              height: 52 * scale,
              padding: EdgeInsets.symmetric(horizontal: 18 * scale),
              decoration: BoxDecoration(
                color: SojuColors.profileBackground,
                borderRadius: BorderRadius.circular(26 * scale),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.search_rounded,
                    size: 22 * scale,
                    color: SojuColors.profileMuted,
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: TextField(
                      key: searchFieldKey,
                      controller: controller,
                      onChanged: onChanged,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 14 * scale,
                        color: SojuColors.ink,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Cari Topik',
                        hintStyle: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 14 * scale,
                          color: SojuColors.profileMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label bagian kecil pada layar pengaturan.
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel({
    super.key,
    required this.scale,
    required this.label,
  });

  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppTypography.family,
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        color: SojuColors.profileMuted,
      ),
    );
  }
}

class _ProfileBackButton extends StatelessWidget {
  const _ProfileBackButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.profileBackground,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52 * scale,
          height: 52 * scale,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20 * scale,
            color: SojuColors.ink,
          ),
        ),
      ),
    );
  }
}
