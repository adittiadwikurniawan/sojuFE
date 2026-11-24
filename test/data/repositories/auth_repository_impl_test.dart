// Test: repository auth memetakan envelope, menyimpan token, dan menangani
// sesi yang ditolak server.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/core/services/token_storage/token_storage.dart';
import 'package:soju_fe/data/datasources/interfaces/auth_datasource.dart';
import 'package:soju_fe/data/repositories/auth_repository_impl.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late _FakeAuthDataSource dataSource;
    late _MemoryTokenStorage tokenStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      dataSource = _FakeAuthDataSource();
      tokenStorage = _MemoryTokenStorage();
      repository = AuthRepositoryImpl(dataSource, tokenStorage);
    });

    test('login menyimpan token dan mengembalikan user', () async {
      dataSource.loginResponse = _sessionEnvelope;

      final result = await repository.login(
        email: 'dea@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      final AuthSession session = result.valueOrNull!;
      expect(session.token, 'jwt-token');
      expect(session.user.id, 7);
      expect(session.user.name, 'Dea');
      expect(session.user.email, 'dea@example.com');
      expect(tokenStorage.token, 'jwt-token');
      expect(dataSource.lastLoginEmail, 'dea@example.com');
      expect(dataSource.lastLoginPassword, 'password123');
    });

    test(
        'login berhasil tetapi penyimpanan token gagal tidak dilaporkan '
        'sebagai gangguan jaringan', () async {
      dataSource.loginResponse = _sessionEnvelope;
      tokenStorage.failWrite = true;

      final result = await repository.login(
        email: 'dea@example.com',
        password: 'password123',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(
        result.failureOrNull!.message,
        contains('gagal disimpan di perangkat'),
      );
    });

    test('login gagal tidak menyimpan token', () async {
      dataSource.loginResponse = <String, Object?>{
        'success': false,
        'message': 'Email atau password salah',
      };

      final result = await repository.login(
        email: 'dea@example.com',
        password: 'salah',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<EnvelopeFailure>());
      expect(result.failureOrNull!.message, 'Email atau password salah');
      expect(tokenStorage.token, isNull);
    });

    test('register mengirim nama/email/password dan menyimpan sesi', () async {
      dataSource.registerResponse = _sessionEnvelope;

      final result = await repository.register(
        name: 'Dea',
        email: 'dea@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(dataSource.lastRegisterName, 'Dea');
      expect(dataSource.lastRegisterEmail, 'dea@example.com');
      expect(tokenStorage.token, 'jwt-token');
    });

    test('loginWithGoogle mengirim ID token dan menyimpan sesi', () async {
      dataSource.googleResponse = _sessionEnvelope;

      final result = await repository.loginWithGoogle(idToken: 'google-id');

      expect(result.isSuccess, isTrue);
      expect(dataSource.lastGoogleIdToken, 'google-id');
      expect(tokenStorage.token, 'jwt-token');
    });

    test('requestPasswordReset mengirim email ke endpoint forgot-password',
        () async {
      final result = await repository.requestPasswordReset(
        email: 'dea@example.com',
      );

      expect(result.isSuccess, isTrue);
      expect(dataSource.lastForgotEmail, 'dea@example.com');
    });

    test('restoreSession memakai /auth/me bila token tersedia', () async {
      tokenStorage.token = 'jwt-token';
      dataSource.meResponse = _userEnvelope;

      final result = await repository.restoreSession();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.email, 'dea@example.com');
      expect(dataSource.meCalls, 1);
    });

    test('restoreSession tanpa token mengembalikan UnauthorizedFailure',
        () async {
      final result = await repository.restoreSession();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      expect(dataSource.meCalls, 0);
    });

    test('restoreSession 401 menghapus token lokal', () async {
      tokenStorage.token = 'jwt-token';
      dataSource.meFailure = const UnauthorizedFailure();

      final result = await repository.restoreSession();

      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      expect(tokenStorage.token, isNull);
    });

    test('logout menghapus token', () async {
      tokenStorage.token = 'jwt-token';

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      expect(tokenStorage.token, isNull);
    });
  });
}

const Map<String, Object?> _sessionEnvelope = <String, Object?>{
  'success': true,
  'data': <String, Object?>{
    'token': 'jwt-token',
    'user': <String, Object?>{
      'id': 7,
      'nama': 'Dea',
      'email': 'dea@example.com',
    },
  },
};

const Map<String, Object?> _userEnvelope = <String, Object?>{
  'success': true,
  'data': <String, Object?>{
    'id': 7,
    'nama': 'Dea',
    'email': 'dea@example.com',
  },
};

class _MemoryTokenStorage implements TokenStorage {
  String? token;
  String? role;
  bool failWrite = false;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async {
    if (failWrite) {
      throw StateError('secure storage tidak tersedia');
    }
    this.token = token;
  }

  @override
  Future<String?> readRole() async => role;

  @override
  Future<void> writeRole(String role) async {
    if (failWrite) {
      throw StateError('secure storage tidak tersedia');
    }
    this.role = role;
  }

  @override
  Future<void> clear() async {
    token = null;
    role = null;
  }
}

class _FakeAuthDataSource implements AuthDataSource {
  Map<String, Object?> loginResponse = _sessionEnvelope;
  Map<String, Object?> registerResponse = _sessionEnvelope;
  Map<String, Object?> googleResponse = _sessionEnvelope;
  Map<String, Object?> forgotResponse = <String, Object?>{
    'success': true,
    'data': <String, Object?>{'email': 'dea@example.com'},
  };
  Map<String, Object?> meResponse = _userEnvelope;

  Object? loginFailure;
  Object? registerFailure;
  Object? googleFailure;
  Object? forgotFailure;
  Object? meFailure;

  String? lastLoginEmail;
  String? lastLoginPassword;
  String? lastRegisterName;
  String? lastRegisterEmail;
  String? lastGoogleIdToken;
  String? lastForgotEmail;
  int meCalls = 0;

  @override
  Future<Map<String, Object?>> loginRaw({
    required String email,
    required String password,
  }) async {
    if (loginFailure != null) {
      throw loginFailure!;
    }
    lastLoginEmail = email;
    lastLoginPassword = password;
    return loginResponse;
  }

  @override
  Future<Map<String, Object?>> registerRaw({
    required String name,
    required String email,
    required String password,
  }) async {
    if (registerFailure != null) {
      throw registerFailure!;
    }
    lastRegisterName = name;
    lastRegisterEmail = email;
    return registerResponse;
  }

  @override
  Future<Map<String, Object?>> googleRaw({
    required String idToken,
  }) async {
    if (googleFailure != null) {
      throw googleFailure!;
    }
    lastGoogleIdToken = idToken;
    return googleResponse;
  }

  @override
  Future<Map<String, Object?>> forgotPasswordRaw({
    required String email,
  }) async {
    if (forgotFailure != null) {
      throw forgotFailure!;
    }
    lastForgotEmail = email;
    return forgotResponse;
  }

  @override
  Future<Map<String, Object?>> meRaw() async {
    meCalls++;
    if (meFailure != null) {
      throw meFailure!;
    }
    return meResponse;
  }
}
