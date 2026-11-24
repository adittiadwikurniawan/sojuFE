// lib/domain/entities/admin_user_entity.dart
//
// Entity domain untuk Manajemen Multi-User Admin (`SUPER_ADMIN` only, AD-08).

import 'package:flutter/foundation.dart';

/// Peran akun pengelola internal pada `/api/v1/users`.
enum AdminUserRole {
  superAdmin(raw: 'SUPER_ADMIN', label: 'Super Admin'),
  admin(raw: 'ADMIN', label: 'Admin');

  const AdminUserRole({
    required this.raw,
    required this.label,
  });

  /// Nilai string sesuai kontrak backend (`SUPER_ADMIN` / `ADMIN`).
  final String raw;

  /// Label tampilan dalam Bahasa Indonesia.
  final String label;

  /// Mengurai string peran dari backend.
  static AdminUserRole fromRaw(String? raw) {
    final String normalized = (raw ?? '').trim().toUpperCase();
    if (normalized == 'SUPER_ADMIN' || normalized == 'SUPERADMIN') {
      return AdminUserRole.superAdmin;
    }
    return AdminUserRole.admin;
  }
}

/// Representasi akun pengelola (`Pengguna`) yang dikelola oleh `SUPER_ADMIN`.
@immutable
class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.lastLoginAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String email;
  final AdminUserRole role;
  final bool isActive;
  final DateTime? lastLoginAt;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isSuperAdmin => role == AdminUserRole.superAdmin;

  AdminUser copyWith({
    int? id,
    String? name,
    String? email,
    AdminUserRole? role,
    bool? isActive,
    DateTime? lastLoginAt,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Hasil pembuatan akun pengelola baru beserta pesan status dari server.
@immutable
class AdminUserActionResult {
  const AdminUserActionResult({
    required this.user,
    required this.message,
  });

  final AdminUser user;
  final String message;
}

/// Hasil pemicuan email reset password untuk akun admin.
@immutable
class AdminUserPasswordResetResult {
  const AdminUserPasswordResetResult({
    required this.userId,
    required this.email,
    required this.message,
  });

  final int userId;
  final String email;
  final String message;
}
