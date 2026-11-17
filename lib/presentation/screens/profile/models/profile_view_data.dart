import 'package:flutter/foundation.dart';

/// Data tampilan menu akun aktif.
///
/// Sumbernya masih mock karena endpoint profil/akun belum tersedia. Saat API
/// siap, cukup petakan respons DTO ke model ini tanpa mengubah widget menu.
@immutable
class ProfileViewData {
  const ProfileViewData({
    required this.name,
    required this.email,
    required this.role,
    required this.avatarAsset,
  });

  final String name;
  final String email;
  final String role;
  final String avatarAsset;

  /// Data contoh untuk menu Profil / Menu Akun.
  static const ProfileViewData sample = ProfileViewData(
    name: 'Adittia',
    email: 'adittia@sojucorp.com',
    role: 'Owner',
    avatarAsset: 'assets/images/avatar_profil.png',
  );
}
