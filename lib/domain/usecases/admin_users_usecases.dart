// lib/domain/usecases/admin_users_usecases.dart
//
// Usecase untuk Manajemen Multi-User Admin (`SUPER_ADMIN` only).

import '../../core/common/result.dart';
import '../entities/admin_user_entity.dart';
import '../repositories/admin_users_repository.dart';

class GetAdminUsers {
  const GetAdminUsers(this._repository);

  final AdminUsersRepository _repository;

  Future<Result<List<AdminUser>>> call({
    String? search,
    AdminUserRole? role,
    bool? isActive,
  }) {
    return _repository.fetchUsers(
      search: search,
      role: role,
      isActive: isActive,
    );
  }
}

class CreateAdminUser {
  const CreateAdminUser(this._repository);

  final AdminUsersRepository _repository;

  Future<Result<AdminUserActionResult>> call({
    required String name,
    required String email,
    String? password,
    required AdminUserRole role,
    bool sendInvite = false,
  }) {
    return _repository.createUser(
      name: name,
      email: email,
      password: password,
      role: role,
      sendInvite: sendInvite,
    );
  }
}

class UpdateAdminUser {
  const UpdateAdminUser(this._repository);

  final AdminUsersRepository _repository;

  Future<Result<AdminUserActionResult>> call({
    required int userId,
    String? name,
    String? email,
    AdminUserRole? role,
  }) {
    return _repository.updateUser(
      userId: userId,
      name: name,
      email: email,
      role: role,
    );
  }
}

class UpdateAdminUserStatus {
  const UpdateAdminUserStatus(this._repository);

  final AdminUsersRepository _repository;

  Future<Result<AdminUserActionResult>> call({
    required int userId,
    required bool isActive,
  }) {
    return _repository.updateUserStatus(
      userId: userId,
      isActive: isActive,
    );
  }
}

class SoftDisableAdminUser {
  const SoftDisableAdminUser(this._repository);

  final AdminUsersRepository _repository;

  Future<Result<AdminUserActionResult>> call({
    required int userId,
  }) {
    return _repository.softDisableUser(userId: userId);
  }
}

class TriggerAdminUserPasswordReset {
  const TriggerAdminUserPasswordReset(this._repository);

  final AdminUsersRepository _repository;

  Future<Result<AdminUserPasswordResetResult>> call({
    required int userId,
  }) {
    return _repository.triggerPasswordReset(userId: userId);
  }
}
