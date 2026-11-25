// lib/domain/repositories/admin_users_repository.dart
//
// Kontrak repository Manajemen Multi-User Admin (`/api/v1/users/*`, SUPER_ADMIN only).

import '../../core/common/result.dart';
import '../entities/admin_user_entity.dart';

/// Kontrak data layer untuk operasi CRUD & proteksi akun pengelola.
abstract interface class AdminUsersRepository {
  /// Mengambil daftar akun admin dengan filter pencarian, peran, dan status aktif.
  Future<Result<List<AdminUser>>> fetchUsers({
    String? search,
    AdminUserRole? role,
    bool? isActive,
  });

  /// Membuat akun admin atau super admin baru (`POST /api/v1/users`).
  Future<Result<AdminUserActionResult>> createUser({
    required String name,
    required String email,
    String? password,
    required AdminUserRole role,
    bool sendInvite = false,
  });

  /// Memperbarui nama, email, dan/atau peran akun admin (`PATCH /api/v1/users/:id`).
  Future<Result<AdminUserActionResult>> updateUser({
    required int userId,
    String? name,
    String? email,
    AdminUserRole? role,
  });

  /// Mengubah status aktif akun admin (`PATCH /api/v1/users/:id/status`).
  Future<Result<AdminUserActionResult>> updateUserStatus({
    required int userId,
    required bool isActive,
  });

  /// Menonaktifkan akun admin secara lunak (`DELETE /api/v1/users/:id`).
  Future<Result<AdminUserActionResult>> softDisableUser({
    required int userId,
  });

  /// Memicu pengiriman tautan reset password (`POST /api/v1/users/:id/reset-password`).
  Future<Result<AdminUserPasswordResetResult>> triggerPasswordReset({
    required int userId,
  });
}
