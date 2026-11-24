// lib/domain/entities/auth_session_entity.dart
//
// Entity domain sesi auth lintas peran (SUPER_ADMIN, ADMIN, CUSTOMER).

import 'package:flutter/foundation.dart';

/// Peran pengguna pada aplikasi SOJU (AD-08, AD-11).
enum UserRole {
  superAdmin,
  admin,
  customer;

  /// Nilai kunci yang disimpan pada [TokenStorage].
  String get storageValue => name;

  /// Apakah peran merupakan akun pengelola internal (`ADMIN` atau `SUPER_ADMIN`).
  bool get isAdminPortal =>
      this == UserRole.admin || this == UserRole.superAdmin;

  /// Apakah peran adalah `SUPER_ADMIN`.
  bool get isSuperAdmin => this == UserRole.superAdmin;

  /// Apakah peran adalah `CUSTOMER` (pelanggan storefront).
  bool get isCustomer => this == UserRole.customer;

  /// Label peran dalam Bahasa Indonesia.
  String get label => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.admin => 'Admin',
        UserRole.customer => 'Pelanggan',
      };

  /// Memetakan nilai `peran` dari backend (`SUPER_ADMIN`, `ADMIN`, `CUSTOMER`)
  /// atau nilai penyimpanan lokal (`superAdmin`, `admin`, `customer`).
  static UserRole? tryParse(String? raw) {
    if (raw == null) {
      return null;
    }
    final String normalized = raw.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return switch (normalized.toUpperCase()) {
      'SUPER_ADMIN' || 'SUPERADMIN' => UserRole.superAdmin,
      'ADMIN' => UserRole.admin,
      'CUSTOMER' || 'PELANGGAN' => UserRole.customer,
      _ => null,
    };
  }
}

/// Jalur portal autentikasi saat masuk atau pemulihan password.
///
/// Akun `ADMIN` dan `SUPER_ADMIN` masuk melalui jalur [AuthPortal.admin]
/// (`/api/v1/auth/*`), sedangkan akun `CUSTOMER` melalui [AuthPortal.customer]
/// (`/api/customer/auth/*`).
enum AuthPortal {
  admin('Admin'),
  customer('Pelanggan');

  const AuthPortal(this.label);

  /// Label tombol pemilih jalur akun dalam Bahasa Indonesia.
  final String label;

  /// Mengurai query parameter atau string jalur portal.
  static AuthPortal fromQuery(String? raw) {
    if (raw == null) {
      return AuthPortal.admin;
    }
    return switch (raw.trim().toLowerCase()) {
      'customer' || 'pelanggan' => AuthPortal.customer,
      _ => AuthPortal.admin,
    };
  }
}

/// User yang sedang login (pengelola internal maupun pelanggan).
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.admin,
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
}

/// Sesi auth: token JWT + user.
@immutable
class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUser user;
}
