// lib/data/datasources/interfaces/admin_users_datasource.dart
//
// Kontrak datasource Manajemen Multi-User Admin (`/api/v1/users/*`).

abstract interface class AdminUsersDataSource {
  Future<Map<String, Object?>> fetchUsersRaw({
    String? search,
    String? role,
    bool? isActive,
  });

  Future<Map<String, Object?>> createUserRaw({
    required String name,
    required String email,
    String? password,
    required String role,
    bool sendInvite = false,
  });

  Future<Map<String, Object?>> updateUserRaw({
    required int userId,
    String? name,
    String? email,
    String? role,
  });

  Future<Map<String, Object?>> updateUserStatusRaw({
    required int userId,
    required bool isActive,
  });

  Future<Map<String, Object?>> softDisableUserRaw({
    required int userId,
  });

  Future<Map<String, Object?>> triggerPasswordResetRaw({
    required int userId,
  });
}
