// lib/presentation/widgets/profile/profile_avatar.dart
//
// Avatar profil dengan badge kamera untuk aksi ganti foto.

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';

/// Avatar bulat dengan fallback inisial dan badge edit opsional.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.size,
    required this.scale,
    required this.initials,
    this.assetPath,
    this.imageUrl,
    this.onTap,
    this.showEditBadge = false,
    this.isLoading = false,
  });

  final double size;
  final double scale;
  final String initials;
  final String? assetPath;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    Widget avatar = ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: _image(),
      ),
    );

    Widget content = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        avatar,
        if (isLoading)
          Positioned.fill(
            child: ClipOval(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.28),
                child: Center(
                  child: SizedBox(
                    width: 28 * scale,
                    height: 28 * scale,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (showEditBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 41 * scale,
              height: 41 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 18 * scale,
                  color: SojuColors.ink,
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      content = Semantics(
        button: true,
        label: 'Ganti foto profil',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _image() {
    final String? url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) =>
            _fallback(),
      );
    }

    final String? asset = assetPath?.trim();
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) =>
            _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: SojuColors.profileIconBackground,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          color: SojuColors.primary,
        ),
      ),
    );
  }
}
