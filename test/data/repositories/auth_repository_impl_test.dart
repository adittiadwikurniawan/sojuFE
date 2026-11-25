// Test: AuthUserModel, AuthRemoteDataSource, dan AuthRepositoryImpl lintas peran
// (SUPER_ADMIN, ADMIN, CUSTOMER) serta alur lupa & reset password.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/core/services/api_client/api_client.dart';
import 'package:soju_fe/core/services/api_client/api_response.dart';
import 'package:soju_fe/core/services/token_storage/token_storage.dart';
import 'package:soju_fe/data/datasources/interfaces/auth_datasource.dart';
import 'package:soju_fe/data/datasources/remote/auth_remote_datasource.dart';
import 'package:soju_fe/data/models/auth/auth_user_model.dart';
import 'package:soju_fe/data/repositories/auth_repository_impl.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';

void main() {
  group('AuthUserModel', () {
    test('memetakan peran SUPER_ADMIN dan ADMIN dari payload pengguna', () {
      final AuthUser superAdmin = AuthUserModel.fromJson(<String, Object?>{
        'id': 1,
        'nama': 'Admin Utama',
        'email': 'admin@bukudapur.com',
        'peran': 'SUPER_ADMIN',
        'aktif': true,
      }).toEntity();

      final AuthUser admin = AuthUserModel.fromJson(<String, Object?>{
        'id': 2,
        'nama': 'Kasir Toko',
        'email': 'kasir@bukudapur.com',
        'peran': 'ADMIN',
        'aktif': true,
      }).toEntity();

      expect(superAdmin.role, UserRole.superAdmin);
      expect(superAdmin.role.isSuperAdmin, isTrue);
      expect(superAdmin.role.isAdminPortal, isTrue);
      expect(admin.role, UserRole.admin);
      expect(admin.role.isSuperAdmin, isFalse);
      expect(admin.role.isAdminPortal, isTrue);
    });

    test('memetakan profil pelanggan menjadi UserRole.customer', () {
      final AuthUser customer = AuthUserModel.fromJson(<String, Object?>{
        'id': 12,
        'nama': 'Budi Santoso',
        'email': 'budi@contoh.com',
        'noTelepon': '081234567890',
        'alamat': 'Jl. Melati No. 10, Bandung',
        'emailTerverifikasiPada': '2026-11-24T10:00:00.000Z',
        'promosiDiizinkan': true,
      }).toEntity();

      expect(customer.role, UserRole.customer);
      expect(customer.role.isCustomer, isTrue);
      expect(customer.phone, '081234567890');
      expect(customer.address, 'Jl. Melati No. 10, Bandung');
      expect(customer.emailVerifiedAt, isNotNull);
      expect(customer.promotionAllowed, isTrue);
    });
  });

  group('AuthRemoteDataSource', () {
    late _RecordingApiClient apiClient;
    late AuthRemoteDataSource remoteDataSource;

    setUp(() {
      apiClient = _RecordingApiClient();
      remoteDataSource = AuthRemoteDataSource(apiClient);
    });

    test('memakai endpoint multi-prefix yang tepat untuk Admin & Pelanggan',
        () async {
      await remoteDataSource.loginAdminRaw(
        email: 'admin@bukudapur.com',
        password: 'password123',
      );
      expect(apiClient.lastMethod, 'POST');
      expect(apiClient.lastPath, '/api/v1/auth/login');
      expect(apiClient.lastAuthenticated, isFalse);

      await remoteDataSource.loginCustomerRaw(
        email: 'budi@contoh.com',
        password: 'password123',
      );
      expect(apiClient.lastPath, '/api/customer/auth/masuk');
      expect(apiClient.lastAuthenticated, isFalse);

      await remoteDataSource.registerCustomerRaw(
        name: 'Budi',
        email: 'budi@contoh.com',
        phone: '08123456789',
        address: 'Jl. Merdeka 1',
        password: 'password123',
      );
      expect(apiClient.lastPath, '/api/customer/auth/daftar');
      expect(
        apiClient.lastBody,
        equals(<String, Object?>{
          'nama': 'Budi',
          'email': 'budi@contoh.com',
          'noTelepon': '08123456789',
          'alamat': 'Jl. Merdeka 1',
          'password': 'password123',
          'promosiDiizinkan': false,
        }),
      );

      await remoteDataSource.forgotPasswordAdminRaw(
        email: 'admin@bukudapur.com',
      );
      expect(apiClient.lastPath, '/api/v1/auth/forgot-password');

      await remoteDataSource.forgotPasswordCustomerRaw(
        email: 'budi@contoh.com',
      );
      expect(apiClient.lastPath, '/api/customer/auth/lupa-password');

      await remoteDataSource.resetPasswordAdminRaw(
        token: 'tok-admin',
        newPassword: 'passwordBaru123',
      );
      expect(apiClient.lastPath, '/api/v1/auth/reset-password');
      expect(
        apiClient.lastBody,
        equals(<String, Object?>{
          'token': 'tok-admin',
          'passwordBaru': 'passwordBaru123',
        }),
      );

      await remoteDataSource.resetPasswordCustomerRaw(
        token: 'tok-cust',
        newPassword: 'passwordBaru123',
      );
      expect(apiClient.lastPath, '/api/customer/auth/reset-password');

      await remoteDataSource.meAdminRaw();
      expect(apiClient.lastMethod, 'GET');
      expect(apiClient.lastPath, '/api/v1/auth/me');
      expect(apiClient.lastAuthenticated, isTrue);

      await remoteDataSource.meCustomerRaw();
      expect(apiClient.lastMethod, 'GET');
      expect(apiClient.lastPath, '/api/customer/profil');
      expect(apiClient.lastAuthenticated, isTrue);
    });
  });

  group('AuthRepositoryImpl', () {
    late _FakeAuthDataSource dataSource;
    late _MemoryTokenStorage tokenStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      dataSource = _FakeAuthDataSource();
      tokenStorage = _MemoryTokenStorage();
      repository = AuthRepositoryImpl(dataSource, tokenStorage);
    });

    test('login Admin menyimpan token & peran superAdmin/admin', () async {
      dataSource.loginAdminResponse = _superAdminSessionEnvelope;

      final result = await repository.login(
        email: 'admin@bukudapur.com',
        password: 'password123',
        portal: AuthPortal.admin,
      );

      expect(result.isSuccess, isTrue);
      final AuthSession session = result.valueOrNull!;
      expect(session.token, 'jwt-super-admin');
      expect(session.user.role, UserRole.superAdmin);
      expect(tokenStorage.token, 'jwt-super-admin');
      expect(tokenStorage.role, 'superAdmin');
      expect(dataSource.lastAdminLoginEmail, 'admin@bukudapur.com');
    });

    test('login Pelanggan memanggil loginCustomerRaw dan menyimpan peran customer',
        () async {
      dataSource.loginCustomerResponse = _customerSessionEnvelope;

      final result = await repository.login(
        email: 'budi@contoh.com',
        password: 'password123',
        portal: AuthPortal.customer,
      );

      expect(result.isSuccess, isTrue);
      final AuthSession session = result.valueOrNull!;
      expect(session.token, 'jwt-customer');
      expect(session.user.role, UserRole.customer);
      expect(session.user.phone, '081234567890');
      expect(session.user.address, 'Jl. Melati No. 10');
      expect(tokenStorage.token, 'jwt-customer');
      expect(tokenStorage.role, 'customer');
      expect(dataSource.lastCustomerLoginEmail, 'budi@contoh.com');
    });

    test(
        'login berhasil tetapi penyimpanan token gagal tidak dilaporkan '
        'sebagai gangguan jaringan', () async {
      dataSource.loginAdminResponse = _superAdminSessionEnvelope;
      tokenStorage.failWrite = true;

      final result = await repository.login(
        email: 'admin@bukudapur.com',
        password: 'password123',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(
        result.failureOrNull!.message,
        contains('gagal disimpan di perangkat'),
      );
    });

    test('login gagal tidak menyimpan token maupun peran', () async {
      dataSource.loginAdminResponse = <String, Object?>{
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
      expect(tokenStorage.role, isNull);
    });

    test('register mendaftarkan Pelanggan lengkap dan menyimpan peran customer',
        () async {
      dataSource.registerCustomerResponse = _customerSessionEnvelope;

      final result = await repository.register(
        name: 'Budi',
        email: 'budi@contoh.com',
        phone: '081234567890',
        address: 'Jl. Melati No. 10',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(dataSource.lastRegisterName, 'Budi');
      expect(dataSource.lastRegisterEmail, 'budi@contoh.com');
      expect(dataSource.lastRegisterPhone, '081234567890');
      expect(dataSource.lastRegisterAddress, 'Jl. Melati No. 10');
      expect(result.valueOrNull!.user.role, UserRole.customer);
      expect(tokenStorage.token, 'jwt-customer');
      expect(tokenStorage.role, 'customer');
    });

    test('requestPasswordReset memilih endpoint Admin atau Pelanggan',
        () async {
      final adminRes = await repository.requestPasswordReset(
        email: 'admin@bukudapur.com',
        portal: AuthPortal.admin,
      );
      expect(adminRes.isSuccess, isTrue);
      expect(dataSource.lastForgotAdminEmail, 'admin@bukudapur.com');

      final customerRes = await repository.requestPasswordReset(
        email: 'budi@contoh.com',
        portal: AuthPortal.customer,
      );
      expect(customerRes.isSuccess, isTrue);
      expect(dataSource.lastForgotCustomerEmail, 'budi@contoh.com');
    });

    test('resetPassword memilih endpoint Admin atau Pelanggan', () async {
      final adminRes = await repository.resetPassword(
        token: 'tok-admin-1',
        newPassword: 'passwordBaru123',
        portal: AuthPortal.admin,
      );
      expect(adminRes.isSuccess, isTrue);
      expect(dataSource.lastResetAdminToken, 'tok-admin-1');

      final customerRes = await repository.resetPassword(
        token: 'tok-cust-1',
        newPassword: 'passwordBaru123',
        portal: AuthPortal.customer,
      );
      expect(customerRes.isSuccess, isTrue);
      expect(dataSource.lastResetCustomerToken, 'tok-cust-1');
    });

    test('restoreSession memakai /api/v1/auth/me untuk peran admin/superAdmin',
        () async {
      tokenStorage.token = 'jwt-admin';
      tokenStorage.role = 'admin';
      dataSource.meAdminResponse = _adminMeEnvelope;

      final result = await repository.restoreSession();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.role, UserRole.admin);
      expect(dataSource.meAdminCalls, 1);
      expect(dataSource.meCustomerCalls, 0);
    });

    test('restoreSession memakai /api/customer/profil bila peran tersimpan customer',
        () async {
      tokenStorage.token = 'jwt-customer';
      tokenStorage.role = 'customer';
      dataSource.meCustomerResponse = _customerMeEnvelope;

      final result = await repository.restoreSession();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.role, UserRole.customer);
      expect(result.valueOrNull!.email, 'budi@contoh.com');
      expect(dataSource.meCustomerCalls, 1);
      expect(dataSource.meAdminCalls, 0);
    });

    test('restoreSession tanpa token mengembalikan UnauthorizedFailure',
        () async {
      final result = await repository.restoreSession();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      expect(dataSource.meAdminCalls, 0);
      expect(dataSource.meCustomerCalls, 0);
    });

    test('restoreSession 401 menghapus token dan peran lokal', () async {
      tokenStorage.token = 'jwt-customer';
      tokenStorage.role = 'customer';
      dataSource.meCustomerFailure = const UnauthorizedFailure();

      final result = await repository.restoreSession();

      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      expect(tokenStorage.token, isNull);
      expect(tokenStorage.role, isNull);
    });

    test('logout menghapus token dan peran', () async {
      tokenStorage.token = 'jwt-token';
      tokenStorage.role = 'superAdmin';

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      expect(tokenStorage.token, isNull);
      expect(tokenStorage.role, isNull);
    });
  });
}

const Map<String, Object?> _superAdminSessionEnvelope = <String, Object?>{
  'success': true,
  'data': <String, Object?>{
    'token': 'jwt-super-admin',
    'user': <String, Object?>{
      'id': 1,
      'nama': 'Admin Utama',
      'email': 'admin@bukudapur.com',
      'peran': 'SUPER_ADMIN',
      'aktif': true,
    },
  },
};

const Map<String, Object?> _customerSessionEnvelope = <String, Object?>{
  'success': true,
  'data': <String, Object?>{
    'token': 'jwt-customer',
    'customer': <String, Object?>{
      'id': 12,
      'nama': 'Budi',
      'email': 'budi@contoh.com',
      'noTelepon': '081234567890',
      'alamat': 'Jl. Melati No. 10',
    },
  },
};

const Map<String, Object?> _adminMeEnvelope = <String, Object?>{
  'success': true,
  'data': <String, Object?>{
    'id': 7,
    'nama': 'Dea',
    'email': 'dea@example.com',
    'peran': 'ADMIN',
  },
};

const Map<String, Object?> _customerMeEnvelope = <String, Object?>{
  'success': true,
  'data': <String, Object?>{
    'id': 12,
    'nama': 'Budi',
    'email': 'budi@contoh.com',
    'noTelepon': '081234567890',
    'alamat': 'Jl. Melati No. 10',
  },
};

class _RecordingApiClient implements ApiClient {
  String? lastMethod;
  String? lastPath;
  Object? lastBody;
  bool? lastAuthenticated;

  ApiResponse response = const ApiResponse(
    statusCode: 200,
    body: <String, Object?>{'success': true, 'data': <String, Object?>{}},
  );

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    lastMethod = 'GET';
    lastPath = path;
    lastBody = null;
    lastAuthenticated = authenticated;
    return response;
  }

  @override
  Future<ApiResponse> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    lastMethod = 'POST';
    lastPath = path;
    lastBody = body;
    lastAuthenticated = authenticated;
    return response;
  }

  @override
  Future<ApiResponse> put(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    lastMethod = 'PUT';
    lastPath = path;
    lastBody = body;
    lastAuthenticated = authenticated;
    return response;
  }

  @override
  Future<ApiResponse> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    lastMethod = 'PATCH';
    lastPath = path;
    lastBody = body;
    lastAuthenticated = authenticated;
    return response;
  }

  @override
  Future<ApiResponse> delete(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    lastMethod = 'DELETE';
    lastPath = path;
    lastBody = body;
    lastAuthenticated = authenticated;
    return response;
  }
}

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
  Map<String, Object?> loginAdminResponse = _superAdminSessionEnvelope;
  Map<String, Object?> loginCustomerResponse = _customerSessionEnvelope;
  Map<String, Object?> registerCustomerResponse = _customerSessionEnvelope;
  Map<String, Object?> forgotResponse = <String, Object?>{
    'success': true,
    'data': null,
    'message':
        'Jika email terdaftar dan aktif, tautan reset password telah dikirim ke email Anda.',
  };
  Map<String, Object?> resetResponse = <String, Object?>{
    'success': true,
    'data': null,
    'message':
        'Password berhasil diatur ulang. Silakan masuk dengan password baru Anda.',
  };
  Map<String, Object?> meAdminResponse = _adminMeEnvelope;
  Map<String, Object?> meCustomerResponse = _customerMeEnvelope;

  Object? meAdminFailure;
  Object? meCustomerFailure;

  String? lastAdminLoginEmail;
  String? lastCustomerLoginEmail;
  String? lastRegisterName;
  String? lastRegisterEmail;
  String? lastRegisterPhone;
  String? lastRegisterAddress;
  String? lastForgotAdminEmail;
  String? lastForgotCustomerEmail;
  String? lastResetAdminToken;
  String? lastResetCustomerToken;
  int meAdminCalls = 0;
  int meCustomerCalls = 0;

  @override
  Future<Map<String, Object?>> loginAdminRaw({
    required String email,
    required String password,
  }) async {
    lastAdminLoginEmail = email;
    return loginAdminResponse;
  }

  @override
  Future<Map<String, Object?>> loginCustomerRaw({
    required String email,
    required String password,
  }) async {
    lastCustomerLoginEmail = email;
    return loginCustomerResponse;
  }

  @override
  Future<Map<String, Object?>> registerCustomerRaw({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  }) async {
    lastRegisterName = name;
    lastRegisterEmail = email;
    lastRegisterPhone = phone;
    lastRegisterAddress = address;
    return registerCustomerResponse;
  }

  @override
  Future<Map<String, Object?>> forgotPasswordAdminRaw({
    required String email,
  }) async {
    lastForgotAdminEmail = email;
    return forgotResponse;
  }

  @override
  Future<Map<String, Object?>> forgotPasswordCustomerRaw({
    required String email,
  }) async {
    lastForgotCustomerEmail = email;
    return forgotResponse;
  }

  @override
  Future<Map<String, Object?>> resetPasswordAdminRaw({
    required String token,
    required String newPassword,
  }) async {
    lastResetAdminToken = token;
    return resetResponse;
  }

  @override
  Future<Map<String, Object?>> resetPasswordCustomerRaw({
    required String token,
    required String newPassword,
  }) async {
    lastResetCustomerToken = token;
    return resetResponse;
  }

  @override
  Future<Map<String, Object?>> meAdminRaw() async {
    meAdminCalls++;
    if (meAdminFailure != null) {
      throw meAdminFailure!;
    }
    return meAdminResponse;
  }

  @override
  Future<Map<String, Object?>> meCustomerRaw() async {
    meCustomerCalls++;
    if (meCustomerFailure != null) {
      throw meCustomerFailure!;
    }
    return meCustomerResponse;
  }
}
