// Test: state AuthController lintas peran (SUPER_ADMIN, ADMIN, CUSTOMER),
// daftar Pelanggan, lupa/reset password, bootstrap, dan logout.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';
import 'package:soju_fe/domain/repositories/auth_repository.dart';
import 'package:soju_fe/domain/usecases/auth_usecases.dart';
import 'package:soju_fe/presentation/providers/auth/auth_controller.dart';

void main() {
  group('AuthController', () {
    late _FakeAuthRepository repository;
    late AuthController controller;

    setUp(() {
      repository = _FakeAuthRepository();
      controller = AuthController(
        login: Login(repository),
        register: Register(repository),
        requestPasswordReset: RequestPasswordReset(repository),
        resetPassword: ResetPassword(repository),
        restoreSession: RestoreSession(repository),
        logout: Logout(repository),
      );
    });

    tearDown(() => controller.dispose());

    test('login Admin berhasil menyimpan peran SUPER_ADMIN', () async {
      repository.loginResult = Result<AuthSession>.success(_superAdminSession);

      final bool success = await controller.login(
        email: 'admin@bukudapur.com',
        password: 'password123',
        portal: AuthPortal.admin,
      );

      expect(success, isTrue);
      expect(repository.lastLoginPortal, AuthPortal.admin);
      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.role, UserRole.superAdmin);
      expect(controller.state.errorMessage, isNull);
    });

    test('login Pelanggan berhasil menyimpan peran CUSTOMER', () async {
      repository.loginResult = Result<AuthSession>.success(_customerSession);

      final bool success = await controller.login(
        email: 'budi@contoh.com',
        password: 'password123',
        portal: AuthPortal.customer,
      );

      expect(success, isTrue);
      expect(repository.lastLoginPortal, AuthPortal.customer);
      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.role, UserRole.customer);
    });

    test('login gagal menampilkan pesan Bahasa Indonesia yang ramah', () async {
      repository.loginResult = Result<AuthSession>.failure(
        const EnvelopeFailure(message: 'Invalid credentials'),
      );

      final bool success = await controller.login(
        email: 'dea@example.com',
        password: 'salah',
      );

      expect(success, isFalse);
      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.errorMessage, 'Email atau password salah.');
    });

    test('register Pelanggan meneruskan nomor telepon & alamat dan set role customer',
        () async {
      repository.registerResult = Result<AuthSession>.success(_customerSession);

      final bool success = await controller.register(
        name: 'Budi',
        email: 'budi@contoh.com',
        phone: '081234567890',
        address: 'Jl. Melati No. 10',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(repository.lastRegisterPhone, '081234567890');
      expect(repository.lastRegisterAddress, 'Jl. Melati No. 10');
      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.role, UserRole.customer);
    });

    test('requestPasswordReset mendukung Admin dan Pelanggan', () async {
      final bool okAdmin = await controller.requestPasswordReset(
        email: 'admin@bukudapur.com',
        portal: AuthPortal.admin,
      );
      expect(okAdmin, isTrue);
      expect(repository.lastForgotPortal, AuthPortal.admin);
      expect(controller.state.feedbackMessage, contains('tautan reset'));

      final bool okCustomer = await controller.requestPasswordReset(
        email: 'budi@contoh.com',
        portal: AuthPortal.customer,
      );
      expect(okCustomer, isTrue);
      expect(repository.lastForgotPortal, AuthPortal.customer);
    });

    test('resetPassword mendukung Admin dan Pelanggan serta menangani token kedaluwarsa',
        () async {
      final bool okCustomer = await controller.resetPassword(
        token: 'token-valid',
        newPassword: 'passwordBaru123',
        portal: AuthPortal.customer,
      );
      expect(okCustomer, isTrue);
      expect(repository.lastResetPortal, AuthPortal.customer);
      expect(controller.state.feedbackMessage, contains('diatur ulang'));

      repository.resetResult = Result<String>.failure(
        const EnvelopeFailure(message: 'Token expired'),
      );
      final bool failedAdmin = await controller.resetPassword(
        token: 'token-lama',
        newPassword: 'passwordBaru123',
        portal: AuthPortal.admin,
      );
      expect(failedAdmin, isFalse);
      expect(repository.lastResetPortal, AuthPortal.admin);
      expect(
        controller.state.errorMessage,
        'Token reset password tidak valid atau sudah kedaluwarsa.',
      );
    });

    test('bootstrap memulihkan sesi Admin maupun Pelanggan sesuai role',
        () async {
      repository.restoreResult =
          Result<AuthUser>.success(_customerSession.user);

      await controller.bootstrap();

      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.user!.name, 'Budi');
      expect(controller.state.role, UserRole.customer);
    });

    test('logout mengosongkan sesi', () async {
      repository.restoreResult =
          Result<AuthUser>.success(_superAdminSession.user);
      await controller.bootstrap();

      await controller.logout();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.user, isNull);
      expect(repository.logoutCalls, 1);
    });
  });
}

const AuthSession _superAdminSession = AuthSession(
  token: 'jwt-admin',
  user: AuthUser(
    id: 1,
    name: 'Admin Utama',
    email: 'admin@bukudapur.com',
    role: UserRole.superAdmin,
  ),
);

const AuthSession _customerSession = AuthSession(
  token: 'jwt-customer',
  user: AuthUser(
    id: 12,
    name: 'Budi',
    email: 'budi@contoh.com',
    role: UserRole.customer,
    phone: '081234567890',
    address: 'Jl. Melati No. 10',
  ),
);

class _FakeAuthRepository implements AuthRepository {
  Result<AuthSession> loginResult =
      Result<AuthSession>.failure(const NetworkFailure());
  Result<AuthSession> registerResult =
      Result<AuthSession>.failure(const NetworkFailure());
  Result<AuthUser> restoreResult =
      Result<AuthUser>.failure(const UnauthorizedFailure());
  Result<String> forgotResult = Result<String>.success(
    'Jika email terdaftar dan aktif, tautan reset password telah dikirim ke email Anda.',
  );
  Result<String> resetResult = Result<String>.success(
    'Password berhasil diatur ulang. Silakan masuk dengan password baru Anda.',
  );
  Result<void> logoutResult = Result<void>.success(null);

  AuthPortal? lastLoginPortal;
  String? lastRegisterPhone;
  String? lastRegisterAddress;
  AuthPortal? lastForgotPortal;
  AuthPortal? lastResetPortal;
  int logoutCalls = 0;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    lastLoginPortal = portal;
    return loginResult;
  }

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  }) async {
    lastRegisterPhone = phone;
    lastRegisterAddress = address;
    return registerResult;
  }

  @override
  Future<Result<String>> requestPasswordReset({
    required String email,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    lastForgotPortal = portal;
    return forgotResult;
  }

  @override
  Future<Result<String>> resetPassword({
    required String token,
    required String newPassword,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    lastResetPortal = portal;
    return resetResult;
  }

  @override
  Future<Result<AuthUser>> me({UserRole? role}) async {
    return restoreResult;
  }

  @override
  Future<Result<AuthUser>> restoreSession() async {
    return restoreResult;
  }

  @override
  Future<Result<void>> logout() async {
    logoutCalls++;
    return logoutResult;
  }
}
