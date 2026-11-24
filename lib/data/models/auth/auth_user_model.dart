// lib/data/models/auth/auth_user_model.dart
//
// DTO user dari respons `/api/v1/auth/login`, `/api/v1/auth/me`,
// `/api/customer/auth/masuk`, `/api/customer/auth/daftar`, dan
// `/api/customer/profil`.

import '../../../domain/entities/auth_session_entity.dart';

/// DTO user autentikasi lintas peran (Admin/Super Admin dan Pelanggan).
class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.isActive = true,
    this.emailVerifiedAt,
    this.promotionAllowed = false,
  });

  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final bool isActive;
  final DateTime? emailVerifiedAt;
  final bool promotionAllowed;

  factory AuthUserModel.fromJson(
    Object? raw, {
    UserRole? defaultRole,
  }) {
    final Map<String, Object?> json = _asMap(raw, 'user');
    final int? id = _asInt(json['id']);
    final String? name = _asString(json['nama'] ?? json['name']);
    final String? email = _asString(json['email']);

    if (id == null) {
      throw const FormatException('Field `id` user tidak valid.');
    }
    if (name == null || name.isEmpty) {
      throw const FormatException('Field `nama` user tidak valid.');
    }
    if (email == null || email.isEmpty) {
      throw const FormatException('Field `email` user tidak valid.');
    }

    final String? rawRole = _asString(json['peran'] ?? json['role']);
    final String? phone = _asString(json['noTelepon'] ?? json['no_telepon']);
    final String? address = _asString(json['alamat']);
    final bool hasCustomerFields = json.containsKey('noTelepon') ||
        json.containsKey('no_telepon') ||
        json.containsKey('alamat') ||
        json.containsKey('emailTerverifikasiPada') ||
        json.containsKey('promosiDiizinkan');

    final UserRole resolvedRole;
    if (rawRole != null) {
      final UserRole? parsedRole = UserRole.tryParse(rawRole);
      if (parsedRole == null) {
        throw FormatException('Field `peran` user tidak dikenali: $rawRole.');
      }
      resolvedRole = parsedRole;
    } else if (defaultRole != null) {
      resolvedRole = defaultRole;
    } else if (hasCustomerFields) {
      resolvedRole = UserRole.customer;
    } else {
      resolvedRole = UserRole.admin;
    }

    final bool isActive = json['aktif'] is bool ? json['aktif'] as bool : true;
    final DateTime? emailVerifiedAt = _asDateTime(
      json['emailTerverifikasiPada'] ?? json['email_terverifikasi_pada'],
    );
    final bool promotionAllowed = json['promosiDiizinkan'] is bool
        ? json['promosiDiizinkan'] as bool
        : false;

    return AuthUserModel(
      id: id,
      name: name,
      email: email,
      role: resolvedRole,
      phone: phone,
      address: address,
      isActive: isActive,
      emailVerifiedAt: emailVerifiedAt,
      promotionAllowed: promotionAllowed,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      role: role,
      phone: phone,
      address: address,
      isActive: isActive,
      emailVerifiedAt: emailVerifiedAt,
      promotionAllowed: promotionAllowed,
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

int? _asInt(Object? raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  if (raw is String) {
    return int.tryParse(raw.trim());
  }
  return null;
}

String? _asString(Object? raw) {
  if (raw is String) {
    final String value = raw.trim();
    return value.isEmpty ? null : value;
  }
  return null;
}

DateTime? _asDateTime(Object? raw) {
  if (raw is String && raw.trim().isNotEmpty) {
    return DateTime.tryParse(raw.trim());
  }
  return null;
}
