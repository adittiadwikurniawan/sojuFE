import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/admin_user_entity.dart';
import 'package:soju_fe/domain/repositories/admin_users_repository.dart';
import 'package:soju_fe/domain/usecases/admin_users_usecases.dart';
import 'package:soju_fe/presentation/providers/admin_users/admin_users_controller.dart';

class _FakeAdminUsersRepository implements AdminUsersRepository {
  List<AdminUser> usersToReturn = <AdminUser>[];
  AppFailure? nextFailure;
  String? lastSearch;
  AdminUserRole? lastRole;
  bool? lastIsActive;
  bool softDisableCalled = false;
  bool updateStatusCalled = false;
  int? resetCalledForUserId;

  @override
  Future<Result<List<AdminUser>>> fetchUsers({
    String? search,
    AdminUserRole? role,
    bool? isActive,
  }) async {
    lastSearch = search;
    lastRole = role;
    lastIsActive = isActive;
    if (nextFailure != null) return Result.failure(nextFailure!);
    return Result.success(usersToReturn);
  }

  @override
  Future<Result<AdminUserActionResult>> createUser({
    required String name,
    required String email,
    String? password,
    required AdminUserRole role,
    bool sendInvite = false,
  }) async {
    if (nextFailure != null) return Result.failure(nextFailure!);
    final DateTime now = DateTime.utc(2026, 11, 25);
    final AdminUser created = AdminUser(
      id: 99,
      name: name,
      email: email,
      role: role,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    return Result.success(
      AdminUserActionResult(
        user: created,
        message: 'Akun Admin berhasil dibuat',
      ),
    );
  }

  @override
  Future<Result<AdminUserActionResult>> updateUser({
    required int userId,
    String? name,
    String? email,
    AdminUserRole? role,
  }) async {
    if (nextFailure != null) return Result.failure(nextFailure!);
    final AdminUser existing =
        usersToReturn.firstWhere((AdminUser u) => u.id == userId);
    final AdminUser updated = existing.copyWith(
      name: name ?? existing.name,
      email: email ?? existing.email,
      role: role ?? existing.role,
    );
    return Result.success(
      AdminUserActionResult(
        user: updated,
        message: 'Data akun admin berhasil diperbarui',
      ),
    );
  }

  @override
  Future<Result<AdminUserActionResult>> updateUserStatus({
    required int userId,
    required bool isActive,
  }) async {
    updateStatusCalled = true;
    if (nextFailure != null) return Result.failure(nextFailure!);
    final AdminUser existing =
        usersToReturn.firstWhere((AdminUser u) => u.id == userId);
    final AdminUser updated = existing.copyWith(isActive: isActive);
    return Result.success(
      AdminUserActionResult(
        user: updated,
        message: isActive
            ? 'Akun admin berhasil diaktifkan'
            : 'Akun admin berhasil dinonaktifkan',
      ),
    );
  }

  @override
  Future<Result<AdminUserActionResult>> softDisableUser({
    required int userId,
  }) async {
    softDisableCalled = true;
    if (nextFailure != null) return Result.failure(nextFailure!);
    final AdminUser existing =
        usersToReturn.firstWhere((AdminUser u) => u.id == userId);
    final AdminUser updated = existing.copyWith(isActive: false);
    return Result.success(
      AdminUserActionResult(
        user: updated,
        message: 'Akun admin berhasil dinonaktifkan',
      ),
    );
  }

  @override
  Future<Result<AdminUserPasswordResetResult>> triggerPasswordReset({
    required int userId,
  }) async {
    resetCalledForUserId = userId;
    if (nextFailure != null) return Result.failure(nextFailure!);
    return Result.success(
      AdminUserPasswordResetResult(
        userId: userId,
        email: 'budi@sojucorp.com',
        message: 'Tautan reset password telah dikirim ke email admin.',
      ),
    );
  }
}

AdminUser _makeUser({
  required int id,
  required String name,
  required String email,
  AdminUserRole role = AdminUserRole.admin,
  bool isActive = true,
}) {
  final DateTime now = DateTime.utc(2026, 11, 25);
  return AdminUser(
    id: id,
    name: name,
    email: email,
    role: role,
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late _FakeAdminUsersRepository repo;
  late AdminUsersController controller;

  setUp(() {
    repo = _FakeAdminUsersRepository();
    controller = AdminUsersController(
      getAdminUsers: GetAdminUsers(repo),
      createAdminUser: CreateAdminUser(repo),
      updateAdminUser: UpdateAdminUser(repo),
      updateAdminUserStatus: UpdateAdminUserStatus(repo),
      softDisableAdminUser: SoftDisableAdminUser(repo),
      triggerPasswordReset: TriggerAdminUserPasswordReset(repo),
    );
  });

  tearDown(() => controller.dispose());

  group('AdminUsersController', () {
    test('load populates data, empty, and error states', () async {
      repo.usersToReturn = <AdminUser>[
        _makeUser(
          id: 1,
          name: 'Dea Owner',
          email: 'dea@sojucorp.com',
          role: AdminUserRole.superAdmin,
        ),
      ];

      await controller.load();
      expect(controller.state.status, AdminUsersStatus.data);
      expect(controller.state.users, hasLength(1));

      repo.usersToReturn = <AdminUser>[];
      await controller.load();
      expect(controller.state.status, AdminUsersStatus.empty);

      repo.nextFailure = const ServerFailure(
        statusCode: 500,
        message: 'Server bermasalah',
      );
      await controller.load();
      expect(controller.state.status, AdminUsersStatus.error);
      expect(controller.state.errorMessage, 'Server bermasalah');
    });

    test('search and role/status filters forward query arguments and reset cleanly', () async {
      await controller.setSearchQuery('budi');
      expect(repo.lastSearch, 'budi');

      await controller.setRoleFilter(AdminUserRole.admin);
      expect(repo.lastRole, AdminUserRole.admin);

      await controller.setActiveFilter(false);
      expect(repo.lastIsActive, isFalse);
      expect(controller.state.hasActiveFilters, isTrue);

      await controller.clearFilters();
      expect(repo.lastSearch, isNull);
      expect(repo.lastRole, isNull);
      expect(repo.lastIsActive, isNull);
      expect(controller.state.hasActiveFilters, isFalse);
    });

    test('createUser appends created user to state', () async {
      await controller.load();
      final AdminUsersMutationResult outcome = await controller.createUser(
        name: 'Rina Baru',
        email: 'rina@sojucorp.com',
        password: 'password123',
        role: AdminUserRole.admin,
      );

      expect(outcome.ok, isTrue);
      expect(controller.state.status, AdminUsersStatus.data);
      expect(controller.state.users.any((AdminUser u) => u.email == 'rina@sojucorp.com'), isTrue);
    });

    test('updateUser updates user entry in state', () async {
      repo.usersToReturn = <AdminUser>[
        _makeUser(id: 2, name: 'Budi', email: 'budi@sojucorp.com'),
      ];
      await controller.load();

      final AdminUsersMutationResult outcome = await controller.updateUser(
        userId: 2,
        name: 'Budi Senior',
        role: AdminUserRole.superAdmin,
      );

      expect(outcome.ok, isTrue);
      expect(controller.state.users.first.name, 'Budi Senior');
      expect(controller.state.users.first.role, AdminUserRole.superAdmin);
    });

    test('toggleUserStatus uses softDisable for active user and updateStatus for inactive user', () async {
      final AdminUser activeUser =
          _makeUser(id: 2, name: 'Budi', email: 'budi@sojucorp.com', isActive: true);
      final AdminUser inactiveUser =
          _makeUser(id: 3, name: 'Sari', email: 'sari@sojucorp.com', isActive: false);
      repo.usersToReturn = <AdminUser>[activeUser, inactiveUser];
      await controller.load();

      final AdminUsersMutationResult disableOutcome =
          await controller.toggleUserStatus(user: activeUser);
      expect(disableOutcome.ok, isTrue);
      expect(repo.softDisableCalled, isTrue);
      expect(
        controller.state.users.firstWhere((AdminUser u) => u.id == 2).isActive,
        isFalse,
      );

      final AdminUsersMutationResult activateOutcome =
          await controller.toggleUserStatus(user: inactiveUser);
      expect(activateOutcome.ok, isTrue);
      expect(repo.updateStatusCalled, isTrue);
      expect(
        controller.state.users.firstWhere((AdminUser u) => u.id == 3).isActive,
        isTrue,
      );
    });

    test('triggerPasswordReset delegates to repository and returns Bahasa Indonesia message', () async {
      final AdminUsersMutationResult outcome =
          await controller.triggerPasswordReset(userId: 2);

      expect(outcome.ok, isTrue);
      expect(repo.resetCalledForUserId, 2);
      expect(outcome.message, contains('reset password'));
    });
  });
}
