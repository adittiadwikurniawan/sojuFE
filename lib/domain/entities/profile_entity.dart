// lib/domain/entities/profile_entity.dart
//
// Entity profil akun dan preferensi notifikasi.
//
// Semua data pada Phase A berasal dari datasource mock. Kontrak method
// repository sudah disiapkan untuk endpoint profil sehingga Phase B cukup
// mengganti datasource tanpa mengubah screen, controller, atau entity.

import 'package:flutter/foundation.dart';

/// Profil akun aktif yang tampil pada layar Profil dan Akun Saya.
@immutable
class ProfileEntity {
  const ProfileEntity({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'Owner',
    this.avatarAsset,
    this.avatarUrl,
  });

  /// Identitas dari API (boleh absen pada mock Phase A).
  final String? id;

  final String name;
  final String email;
  final String phone;
  final String role;

  /// Aset lokal untuk foto contoh (mock).
  final String? avatarAsset;

  /// URL foto dari API (Phase B).
  final String? avatarUrl;

  bool get hasPhoto =>
      (avatarAsset?.isNotEmpty ?? false) || (avatarUrl?.isNotEmpty ?? false);

  /// Inisial untuk fallback ketika foto belum dipilih.
  String get initials {
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

  ProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatarAsset,
    String? avatarUrl,
    bool clearAvatar = false,
  }) {
    return ProfileEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarAsset: clearAvatar ? null : (avatarAsset ?? this.avatarAsset),
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
    );
  }
}

/// Draf perubahan data profil yang dikirim ke repository.
@immutable
class ProfileUpdateDraft {
  const ProfileUpdateDraft({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

  /// Payload snake_case sesuai kontrak API Buku Dapur.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'nama': name,
      'email': email,
      'no_telepon': phone,
    };
  }
}

/// Draf perubahan foto profil.
///
/// [assetPath] dipakai oleh mock Phase A; [imageUrl] disiapkan untuk hasil
/// unggah ke storage API pada Phase B.
@immutable
class ProfilePhotoDraft {
  const ProfilePhotoDraft({
    this.assetPath,
    this.imageUrl,
    this.remove = false,
  });

  final String? assetPath;
  final String? imageUrl;
  final bool remove;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'hapus_foto': remove,
      if (!remove && imageUrl != null) 'foto_profil': imageUrl,
      if (!remove && assetPath != null) 'foto_profil_asset': assetPath,
    };
  }
}

/// Draf perubahan password.
@immutable
class ChangePasswordDraft {
  const ChangePasswordDraft({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'password_lama': currentPassword,
      'password_baru': newPassword,
    };
  }
}

/// Preferensi notifikasi akun.
@immutable
class NotificationPreferencesEntity {
  const NotificationPreferencesEntity({
    required this.stockLow,
    required this.cashDifference,
    required this.dailyTransaction,
  });

  final bool stockLow;
  final bool cashDifference;
  final bool dailyTransaction;

  NotificationPreferencesEntity copyWith({
    bool? stockLow,
    bool? cashDifference,
    bool? dailyTransaction,
  }) {
    return NotificationPreferencesEntity(
      stockLow: stockLow ?? this.stockLow,
      cashDifference: cashDifference ?? this.cashDifference,
      dailyTransaction: dailyTransaction ?? this.dailyTransaction,
    );
  }

  bool sameAs(NotificationPreferencesEntity other) {
    return stockLow == other.stockLow &&
        cashDifference == other.cashDifference &&
        dailyTransaction == other.dailyTransaction;
  }
}

/// Draf preferensi notifikasi yang dikirim ke repository.
@immutable
class NotificationPreferencesDraft {
  const NotificationPreferencesDraft({
    required this.stockLow,
    required this.cashDifference,
    required this.dailyTransaction,
  });

  factory NotificationPreferencesDraft.fromEntity(
    NotificationPreferencesEntity entity,
  ) {
    return NotificationPreferencesDraft(
      stockLow: entity.stockLow,
      cashDifference: entity.cashDifference,
      dailyTransaction: entity.dailyTransaction,
    );
  }

  final bool stockLow;
  final bool cashDifference;
  final bool dailyTransaction;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'stok_menipis': stockLow,
      'selisih_kas': cashDifference,
      'transaksi_harian': dailyTransaction,
    };
  }
}
