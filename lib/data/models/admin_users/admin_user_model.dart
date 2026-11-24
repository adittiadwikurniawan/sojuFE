// lib/data/models/admin_users/admin_user_model.dart
//
// DTO model untuk akun pengelola (`/api/v1/users/*`).

import '../../../domain/entities/admin_user_entity.dart';

class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleRaw,
    required this.isActive,
    this.lastLoginAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String email;
  final String roleRaw;
  final bool isActive;
  final DateTime? lastLoginAt;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AdminUserModel.fromJson(Map<String, Object?> json) {
    final DateTime fallbackNow = DateTime.fromMillisecondsSinceEpoch(0);
    return AdminUserModel(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['nama'] ?? json['name']),
      email: _asString(json['email']),
      roleRaw: _asString(json['peran'] ?? json['role'], fallback: 'ADMIN'),
      isActive: _asBool(json['aktif'] ?? json['isActive'], fallback: true),
      lastLoginAt: _asDateTime(json['terakhirMasukPada'] ?? json['lastLoginAt']),
      createdBy: _asInt(json['dibuatOleh'] ?? json['createdBy']),
      createdAt:
          _asDateTime(json['dibuatPada'] ?? json['createdAt']) ?? fallbackNow,
      updatedAt:
          _asDateTime(json['diubahPada'] ?? json['updatedAt']) ?? fallbackNow,
    );
  }

  AdminUser toEntity() {
    return AdminUser(
      id: id,
      name: name,
      email: email,
      role: AdminUserRole.fromRaw(roleRaw),
      isActive: isActive,
      lastLoginAt: lastLoginAt,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static String _asString(Object? value, {String fallback = ''}) {
    if (value is String) return value.trim();
    return fallback;
  }

  static bool _asBool(Object? value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }
}
