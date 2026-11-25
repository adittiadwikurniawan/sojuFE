// lib/data/repositories/admin_users_repository_impl.dart
//
// Implementasi AdminUsersRepository untuk `/api/v1/users/*`.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/repositories/admin_users_repository.dart';
import '../datasources/interfaces/admin_users_datasource.dart';
import '../models/admin_users/admin_user_model.dart';
import '../models/api_envelope_model.dart';

class AdminUsersRepositoryImpl implements AdminUsersRepository {
  const AdminUsersRepositoryImpl(this._dataSource);

  final AdminUsersDataSource _dataSource;

  @override
  Future<Result<List<AdminUser>>> fetchUsers({
    String? search,
    AdminUserRole? role,
    bool? isActive,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchUsersRaw(
        search: search,
        role: role?.raw,
        isActive: isActive,
      );
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Daftar pengguna tidak valid.',
          ),
        );
      }

      final Object? dataContent = envelope.data;
      final List<Object?> items;
      if (dataContent is List) {
        items = dataContent;
      } else if (dataContent is Map && dataContent['data'] is List) {
        items = dataContent['data'] as List<Object?>;
      } else {
        return Result.failure(const ParsingFailure());
      }

      final List<AdminUser> users = items
          .whereType<Map<Object?, Object?>>()
          .map(_normalizeMap)
          .map((Map<String, Object?> m) => AdminUserModel.fromJson(m).toEntity())
          .toList(growable: false);

      return Result.success(users);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AdminUserActionResult>> createUser({
    required String name,
    required String email,
    String? password,
    required AdminUserRole role,
    bool sendInvite = false,
  }) {
    return _parseSingleUserAction(
      () => _dataSource.createUserRaw(
        name: name,
        email: email,
        password: password,
        role: role.raw,
        sendInvite: sendInvite,
      ),
      fallbackError: 'Gagal membuat akun admin.',
      fallbackSuccess: 'Akun Admin berhasil dibuat.',
    );
  }

  @override
  Future<Result<AdminUserActionResult>> updateUser({
    required int userId,
    String? name,
    String? email,
    AdminUserRole? role,
  }) {
    return _parseSingleUserAction(
      () => _dataSource.updateUserRaw(
        userId: userId,
        name: name,
        email: email,
        role: role?.raw,
      ),
      fallbackError: 'Gagal memperbarui data akun admin.',
      fallbackSuccess: 'Data akun admin berhasil diperbarui.',
    );
  }

  @override
  Future<Result<AdminUserActionResult>> updateUserStatus({
    required int userId,
    required bool isActive,
  }) {
    return _parseSingleUserAction(
      () => _dataSource.updateUserStatusRaw(
        userId: userId,
        isActive: isActive,
      ),
      fallbackError: 'Gagal mengubah status akun admin.',
      fallbackSuccess: isActive
          ? 'Akun admin berhasil diaktifkan.'
          : 'Akun admin berhasil dinonaktifkan.',
    );
  }

  @override
  Future<Result<AdminUserActionResult>> softDisableUser({
    required int userId,
  }) {
    return _parseSingleUserAction(
      () => _dataSource.softDisableUserRaw(userId: userId),
      fallbackError: 'Gagal menonaktifkan akun admin.',
      fallbackSuccess: 'Akun admin berhasil dinonaktifkan.',
    );
  }

  @override
  Future<Result<AdminUserPasswordResetResult>> triggerPasswordReset({
    required int userId,
  }) async {
    try {
      final Map<String, Object?> raw =
          await _dataSource.triggerPasswordResetRaw(userId: userId);
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message:
                envelope.message ?? 'Gagal mengirim tautan reset password.',
          ),
        );
      }

      if (envelope.data is! Map) {
        return Result.failure(const ParsingFailure());
      }

      final Map<String, Object?> data =
          _normalizeMap(envelope.data as Map<Object?, Object?>);
      final int parsedUserId = switch (data['userId']) {
        final int v => v,
        final num v => v.toInt(),
        final String v => int.tryParse(v) ?? userId,
        _ => userId,
      };
      final String email = (data['email'] is String)
          ? (data['email'] as String).trim()
          : '';
      final String message = envelope.message ??
          'Tautan reset password telah dikirim ke email admin.';

      return Result.success(
        AdminUserPasswordResetResult(
          userId: parsedUserId,
          email: email,
          message: message,
        ),
      );
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  Future<Result<AdminUserActionResult>> _parseSingleUserAction(
    Future<Map<String, Object?>> Function() request, {
    required String fallbackError,
    required String fallbackSuccess,
  }) async {
    try {
      final Map<String, Object?> raw = await request();
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? fallbackError,
          ),
        );
      }
      if (envelope.data is! Map) {
        return Result.failure(const ParsingFailure());
      }
      final Map<String, Object?> data =
          _normalizeMap(envelope.data as Map<Object?, Object?>);
      final AdminUser user = AdminUserModel.fromJson(data).toEntity();
      return Result.success(
        AdminUserActionResult(
          user: user,
          message: envelope.message ?? fallbackSuccess,
        ),
      );
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  static Map<String, Object?> _normalizeMap(Map<Object?, Object?> source) {
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> e in source.entries)
        e.key.toString(): e.value,
    };
  }
}
