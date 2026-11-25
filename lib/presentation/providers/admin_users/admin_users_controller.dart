// lib/presentation/providers/admin_users/admin_users_controller.dart
//
// ChangeNotifier controller untuk Manajemen Multi-User Admin (`SUPER_ADMIN` only).

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/admin_user_entity.dart';
import '../../../domain/usecases/admin_users_usecases.dart';

enum AdminUsersStatus { loading, data, empty, error }

@immutable
class AdminUsersMutationResult {
  const AdminUsersMutationResult({
    required this.ok,
    required this.message,
  });

  final bool ok;
  final String message;
}

@immutable
class AdminUsersState {
  const AdminUsersState({
    required this.status,
    this.users = const <AdminUser>[],
    this.searchQuery = '',
    this.roleFilter,
    this.activeFilter,
    this.errorMessage,
    this.submitting = false,
    this.busyUserId,
  });

  const AdminUsersState.initial() : this(status: AdminUsersStatus.loading);

  final AdminUsersStatus status;
  final List<AdminUser> users;
  final String searchQuery;
  final AdminUserRole? roleFilter;
  final bool? activeFilter;
  final String? errorMessage;
  final bool submitting;
  final int? busyUserId;

  bool isBusy(int userId) => busyUserId == userId;

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      roleFilter != null ||
      activeFilter != null;

  int get totalCount => users.length;
  int get activeCount => users.where((AdminUser u) => u.isActive).length;
  int get activeSuperAdminCount => users
      .where((AdminUser u) => u.isSuperAdmin && u.isActive)
      .length;

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<AdminUser>? users,
    String? searchQuery,
    AdminUserRole? roleFilter,
    bool clearRoleFilter = false,
    bool? activeFilter,
    bool clearActiveFilter = false,
    String? errorMessage,
    bool clearError = false,
    bool? submitting,
    int? busyUserId,
    bool clearBusyUser = false,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
      activeFilter:
          clearActiveFilter ? null : (activeFilter ?? this.activeFilter),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submitting: submitting ?? this.submitting,
      busyUserId: clearBusyUser ? null : (busyUserId ?? this.busyUserId),
    );
  }
}

class AdminUsersController extends ChangeNotifier {
  AdminUsersController({
    required GetAdminUsers getAdminUsers,
    required CreateAdminUser createAdminUser,
    required UpdateAdminUser updateAdminUser,
    required UpdateAdminUserStatus updateAdminUserStatus,
    required SoftDisableAdminUser softDisableAdminUser,
    required TriggerAdminUserPasswordReset triggerPasswordReset,
  })  : _getAdminUsers = getAdminUsers,
        _createAdminUser = createAdminUser,
        _updateAdminUser = updateAdminUser,
        _updateAdminUserStatus = updateAdminUserStatus,
        _softDisableAdminUser = softDisableAdminUser,
        _triggerPasswordReset = triggerPasswordReset;

  final GetAdminUsers _getAdminUsers;
  final CreateAdminUser _createAdminUser;
  final UpdateAdminUser _updateAdminUser;
  final UpdateAdminUserStatus _updateAdminUserStatus;
  final SoftDisableAdminUser _softDisableAdminUser;
  final TriggerAdminUserPasswordReset _triggerPasswordReset;

  AdminUsersState _state = const AdminUsersState.initial();
  AdminUsersState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(
      status: AdminUsersStatus.loading,
      clearError: true,
    );
    notifyListeners();

    final Result<List<AdminUser>> result = await _getAdminUsers(
      search: _state.searchQuery.trim().isEmpty ? null : _state.searchQuery.trim(),
      role: _state.roleFilter,
      isActive: _state.activeFilter,
    );

    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: AdminUsersStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (List<AdminUser> items) {
        _state = _state.copyWith(
          status: items.isEmpty ? AdminUsersStatus.empty : AdminUsersStatus.data,
          users: items,
          clearError: true,
        );
      },
    );
    notifyListeners();
  }

  Future<void> setSearchQuery(String query) async {
    _state = _state.copyWith(searchQuery: query);
    await load();
  }

  Future<void> setRoleFilter(AdminUserRole? role) async {
    _state = _state.copyWith(
      roleFilter: role,
      clearRoleFilter: role == null,
    );
    await load();
  }

  Future<void> setActiveFilter(bool? isActive) async {
    _state = _state.copyWith(
      activeFilter: isActive,
      clearActiveFilter: isActive == null,
    );
    await load();
  }

  Future<void> clearFilters() async {
    _state = _state.copyWith(
      searchQuery: '',
      clearRoleFilter: true,
      clearActiveFilter: true,
    );
    await load();
  }

  Future<AdminUsersMutationResult> createUser({
    required String name,
    required String email,
    String? password,
    required AdminUserRole role,
    bool sendInvite = false,
  }) async {
    _state = _state.copyWith(submitting: true, clearError: true);
    notifyListeners();

    final Result<AdminUserActionResult> result = await _createAdminUser(
      name: name,
      email: email,
      password: password,
      role: role,
      sendInvite: sendInvite,
    );

    late final AdminUsersMutationResult outcome;
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          submitting: false,
          errorMessage: failure.message,
        );
        outcome = AdminUsersMutationResult(ok: false, message: failure.message);
      },
      onSuccess: (AdminUserActionResult created) {
        final List<AdminUser> updated = <AdminUser>[
          ..._state.users,
          created.user,
        ];
        _state = _state.copyWith(
          submitting: false,
          status: AdminUsersStatus.data,
          users: updated,
          clearError: true,
        );
        outcome = AdminUsersMutationResult(ok: true, message: created.message);
      },
    );
    notifyListeners();
    return outcome;
  }

  Future<AdminUsersMutationResult> updateUser({
    required int userId,
    String? name,
    String? email,
    AdminUserRole? role,
  }) async {
    _state = _state.copyWith(
      submitting: true,
      busyUserId: userId,
      clearError: true,
    );
    notifyListeners();

    final Result<AdminUserActionResult> result = await _updateAdminUser(
      userId: userId,
      name: name,
      email: email,
      role: role,
    );

    late final AdminUsersMutationResult outcome;
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          submitting: false,
          clearBusyUser: true,
          errorMessage: failure.message,
        );
        outcome = AdminUsersMutationResult(ok: false, message: failure.message);
      },
      onSuccess: (AdminUserActionResult updatedResult) {
        final List<AdminUser> nextList = _state.users
            .map(
              (AdminUser u) =>
                  u.id == updatedResult.user.id ? updatedResult.user : u,
            )
            .toList(growable: false);
        _state = _state.copyWith(
          submitting: false,
          clearBusyUser: true,
          users: nextList,
          clearError: true,
        );
        outcome = AdminUsersMutationResult(
          ok: true,
          message: updatedResult.message,
        );
      },
    );
    notifyListeners();
    return outcome;
  }

  /// Menonaktifkan (`DELETE /api/v1/users/:id`) atau mengaktifkan kembali
  /// (`PATCH /api/v1/users/:id/status`) akun pengelola.
  Future<AdminUsersMutationResult> toggleUserStatus({
    required AdminUser user,
  }) async {
    _state = _state.copyWith(busyUserId: user.id, clearError: true);
    notifyListeners();

    final Result<AdminUserActionResult> result = user.isActive
        ? await _softDisableAdminUser(userId: user.id)
        : await _updateAdminUserStatus(userId: user.id, isActive: true);

    late final AdminUsersMutationResult outcome;
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          clearBusyUser: true,
          errorMessage: failure.message,
        );
        outcome = AdminUsersMutationResult(ok: false, message: failure.message);
      },
      onSuccess: (AdminUserActionResult updatedResult) {
        final List<AdminUser> nextList = _state.users
            .map(
              (AdminUser u) =>
                  u.id == updatedResult.user.id ? updatedResult.user : u,
            )
            .toList(growable: false);
        _state = _state.copyWith(
          clearBusyUser: true,
          users: nextList,
          clearError: true,
        );
        outcome = AdminUsersMutationResult(
          ok: true,
          message: updatedResult.message,
        );
      },
    );
    notifyListeners();
    return outcome;
  }

  Future<AdminUsersMutationResult> triggerPasswordReset({
    required int userId,
  }) async {
    _state = _state.copyWith(busyUserId: userId, clearError: true);
    notifyListeners();

    final Result<AdminUserPasswordResetResult> result =
        await _triggerPasswordReset(userId: userId);

    late final AdminUsersMutationResult outcome;
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          clearBusyUser: true,
          errorMessage: failure.message,
        );
        outcome = AdminUsersMutationResult(ok: false, message: failure.message);
      },
      onSuccess: (AdminUserPasswordResetResult resetResult) {
        _state = _state.copyWith(
          clearBusyUser: true,
          clearError: true,
        );
        outcome = AdminUsersMutationResult(
          ok: true,
          message: resetResult.message,
        );
      },
    );
    notifyListeners();
    return outcome;
  }
}
