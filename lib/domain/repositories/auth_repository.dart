// lib/domain/repositories/auth_repository.dart
//
// Kontrak repository autentikasi lintas peran (SUPER_ADMIN, ADMIN, CUSTOMER).

import '../../core/common/result.dart';
import '../entities/auth_session_entity.dart';

/// Repository login, daftar pelanggan, lupa/reset password, sesi, dan logout.
abstract interface class AuthRepository {
  /// Login Admin/Super Admin (`/api/v1/auth/login`) atau Pelanggan
  /// (`/api/customer/auth/masuk`) sesuai [portal].
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    AuthPortal portal = AuthPortal.admin,
  });

  /// Pendaftaran akun Pelanggan (`/api/customer/auth/daftar`).
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  });

  /// Meminta tautan/token reset password untuk [portal] (Admin atau Pelanggan).
  Future<Result<String>> requestPasswordReset({
    required String email,
    AuthPortal portal = AuthPortal.admin,
  });

  /// Mengatur ulang password menggunakan [token] satu kali pakai untuk [portal].
  Future<Result<String>> resetPassword({
    required String token,
    required String newPassword,
    AuthPortal portal = AuthPortal.admin,
  });

  /// Mengambil profil sesi aktif sesuai [role] (atau peran tersimpan).
  Future<Result<AuthUser>> me({UserRole? role});

  /// Memulihkan sesi dari token & peran tersimpan melalui `/api/v1/auth/me`
  /// atau `/api/customer/profil`.
  Future<Result<AuthUser>> restoreSession();

  /// Menghapus token dan peran lokal.
  Future<Result<void>> logout();
}
