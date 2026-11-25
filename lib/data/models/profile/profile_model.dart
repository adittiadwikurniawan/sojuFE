// lib/data/models/profile/profile_model.dart
//
// DTO profil dan preferensi notifikasi.
//
// Bentuk `data` pada envelope Phase A:
//
// ```json
// {
//   "id": "profile-1",
//   "nama": "Adittia",
//   "email": "adittia@sojucorp.com",
//   "no_telepon": "0812 3456 7890",
//   "role": "Owner",
//   "foto_profil_asset": "assets/images/avatar_profil.png"
// }
// ```

import '../../../domain/entities/profile_entity.dart';

/// DTO profil akun.
class ProfileModel {
  const ProfileModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarAsset,
    this.avatarUrl,
  });

  final String? id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarAsset;
  final String? avatarUrl;

  /// Mengurai isi `data`; `nama` dan `email` wajib ada.
  factory ProfileModel.fromJson(Object? raw) {
    final Map<String, Object?> json = _asMap(raw, 'data');
    final String? name = _asString(json['nama'] ?? json['name']);
    final String? email = _asString(json['email']);
    if (name == null || name.isEmpty) {
      throw const FormatException('Field `nama` profil tidak valid.');
    }
    if (email == null || email.isEmpty) {
      throw const FormatException('Field `email` profil tidak valid.');
    }
    return ProfileModel(
      id: _asString(json['id']),
      name: name,
      email: email,
      phone: _asString(json['no_telepon'] ?? json['phone']) ?? '',
      role: _asString(json['role']) ?? 'Owner',
      avatarAsset: _asString(
        json['foto_profil_asset'] ?? json['avatar_asset'],
      ),
      avatarUrl: _asString(json['foto_profil'] ?? json['avatar_url']),
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      avatarAsset: avatarAsset,
      avatarUrl: avatarUrl,
    );
  }
}

/// DTO preferensi notifikasi.
class NotificationPreferencesModel {
  const NotificationPreferencesModel({
    required this.stockLow,
    required this.cashDifference,
    required this.dailyTransaction,
  });

  final bool stockLow;
  final bool cashDifference;
  final bool dailyTransaction;

  factory NotificationPreferencesModel.fromJson(Object? raw) {
    final Map<String, Object?> json = _asMap(raw, 'data');
    return NotificationPreferencesModel(
      stockLow: _asBool(json['stok_menipis'] ?? json['stock_low']),
      cashDifference: _asBool(
        json['selisih_kas'] ?? json['cash_difference'],
      ),
      dailyTransaction: _asBool(
        json['transaksi_harian'] ?? json['daily_transaction'],
      ),
    );
  }

  NotificationPreferencesEntity toEntity() {
    return NotificationPreferencesEntity(
      stockLow: stockLow,
      cashDifference: cashDifference,
      dailyTransaction: dailyTransaction,
    );
  }
}

Map<String, Object?> _asMap(Object? raw, String field) {
  if (raw is Map) {
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        entry.key.toString(): entry.value,
    };
  }
  throw FormatException('Field `$field` bukan objek JSON.');
}

String? _asString(Object? raw) {
  if (raw is String) {
    final String value = raw.trim();
    return value.isEmpty ? null : value;
  }
  return null;
}

bool _asBool(Object? raw) {
  if (raw is bool) {
    return raw;
  }
  if (raw is num) {
    return raw != 0;
  }
  if (raw is String) {
    return raw.toLowerCase() == 'true' || raw == '1';
  }
  return false;
}
