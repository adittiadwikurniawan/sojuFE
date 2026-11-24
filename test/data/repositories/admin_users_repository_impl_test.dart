import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/core/services/api_client/api_client.dart';
import 'package:soju_fe/core/services/api_client/api_response.dart';
import 'package:soju_fe/data/datasources/remote/admin_users_remote_datasource.dart';
import 'package:soju_fe/data/repositories/admin_users_repository_impl.dart';
import 'package:soju_fe/domain/entities/admin_user_entity.dart';

class _RecordingApiClient implements ApiClient {
  String? lastMethod;
  String? lastPath;
  Object? lastBody;
  Map<String, String>? lastQuery;
  ApiResponse nextResponse = const ApiResponse(statusCode: 200, body: <String, Object?>{});

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    lastMethod = 'GET';
    lastPath = path;
    lastQuery = queryParameters;
    return nextResponse;
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
    lastQuery = queryParameters;
    return nextResponse;
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
    lastQuery = queryParameters;
    return nextResponse;
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
    lastQuery = queryParameters;
    return nextResponse;
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
    lastQuery = queryParameters;
    return nextResponse;
  }
}

Map<String, Object?> _sampleUserJson({
  int id = 2,
  String nama = 'Budi Admin',
  String email = 'budi@sojucorp.com',
  String peran = 'ADMIN',
  bool aktif = true,
}) {
  return <String, Object?>{
    'id': id,
    'nama': nama,
    'email': email,
    'peran': peran,
    'aktif': aktif,
    'terakhirMasukPada': '2026-11-24T08:00:00.000Z',
    'dibuatOleh': 1,
    'dibuatPada': '2026-01-10T08:00:00.000Z',
    'diubahPada': '2026-11-24T08:00:00.000Z',
  };
}

void main() {
  late _RecordingApiClient apiClient;
  late AdminUsersRepositoryImpl repository;

  setUp(() {
    apiClient = _RecordingApiClient();
    repository = AdminUsersRepositoryImpl(
      AdminUsersRemoteDataSource(apiClient),
    );
  });

  group('AdminUsersRepositoryImpl', () {
    test('fetchUsers forwards search/peran/aktif query params and parses entities', () async {
      apiClient.nextResponse = ApiResponse(
        statusCode: 200,
        body: <String, Object?>{
          'success': true,
          'data': <Object?>[
            _sampleUserJson(id: 1, nama: 'Dea Owner', peran: 'SUPER_ADMIN'),
            _sampleUserJson(id: 2, nama: 'Budi Admin', peran: 'ADMIN'),
          ],
        },
      );

      final Result<List<AdminUser>> result = await repository.fetchUsers(
        search: 'dea',
        role: AdminUserRole.superAdmin,
        isActive: true,
      );

      expect(apiClient.lastMethod, 'GET');
      expect(apiClient.lastPath, '/api/v1/users');
      expect(apiClient.lastQuery, <String, String>{
        'search': 'dea',
        'peran': 'SUPER_ADMIN',
        'aktif': 'true',
      });
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, hasLength(2));
      expect(result.valueOrNull!.first.role, AdminUserRole.superAdmin);
      expect(result.valueOrNull!.last.role, AdminUserRole.admin);
    });

    test('createUser posts payload to /api/v1/users and returns action result', () async {
      apiClient.nextResponse = ApiResponse(
        statusCode: 201,
        body: <String, Object?>{
          'success': true,
          'data': _sampleUserJson(id: 5, nama: 'Rina Baru', email: 'rina@sojucorp.com'),
          'message': 'Akun Admin berhasil dibuat',
        },
      );

      final Result<AdminUserActionResult> result = await repository.createUser(
        name: 'Rina Baru',
        email: 'rina@sojucorp.com',
        password: 'password123',
        role: AdminUserRole.admin,
        sendInvite: false,
      );

      expect(apiClient.lastMethod, 'POST');
      expect(apiClient.lastPath, '/api/v1/users');
      expect(apiClient.lastBody, <String, Object?>{
        'nama': 'Rina Baru',
        'email': 'rina@sojucorp.com',
        'peran': 'ADMIN',
        'sendInvite': false,
        'password': 'password123',
      });
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.user.id, 5);
      expect(result.valueOrNull!.message, 'Akun Admin berhasil dibuat');
    });

    test('updateUser patches /api/v1/users/:id with provided fields only', () async {
      apiClient.nextResponse = ApiResponse(
        statusCode: 200,
        body: <String, Object?>{
          'success': true,
          'data': _sampleUserJson(id: 2, nama: 'Budi Updated', peran: 'SUPER_ADMIN'),
          'message': 'Data akun admin berhasil diperbarui',
        },
      );

      final Result<AdminUserActionResult> result = await repository.updateUser(
        userId: 2,
        name: 'Budi Updated',
        role: AdminUserRole.superAdmin,
      );

      expect(apiClient.lastMethod, 'PATCH');
      expect(apiClient.lastPath, '/api/v1/users/2');
      expect(apiClient.lastBody, <String, Object?>{
        'nama': 'Budi Updated',
        'peran': 'SUPER_ADMIN',
      });
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.user.role, AdminUserRole.superAdmin);
    });

    test('updateUserStatus patches /api/v1/users/:id/status', () async {
      apiClient.nextResponse = ApiResponse(
        statusCode: 200,
        body: <String, Object?>{
          'success': true,
          'data': _sampleUserJson(id: 3, aktif: true),
          'message': 'Akun admin berhasil diaktifkan',
        },
      );

      final Result<AdminUserActionResult> result =
          await repository.updateUserStatus(userId: 3, isActive: true);

      expect(apiClient.lastMethod, 'PATCH');
      expect(apiClient.lastPath, '/api/v1/users/3/status');
      expect(apiClient.lastBody, <String, Object?>{'aktif': true});
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.user.isActive, isTrue);
    });

    test('softDisableUser sends DELETE /api/v1/users/:id', () async {
      apiClient.nextResponse = ApiResponse(
        statusCode: 200,
        body: <String, Object?>{
          'success': true,
          'data': _sampleUserJson(id: 2, aktif: false),
          'message': 'Akun admin berhasil dinonaktifkan',
        },
      );

      final Result<AdminUserActionResult> result =
          await repository.softDisableUser(userId: 2);

      expect(apiClient.lastMethod, 'DELETE');
      expect(apiClient.lastPath, '/api/v1/users/2');
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.user.isActive, isFalse);
    });

    test('triggerPasswordReset posts to /api/v1/users/:id/reset-password', () async {
      apiClient.nextResponse = const ApiResponse(
        statusCode: 200,
        body: <String, Object?>{
          'success': true,
          'data': <String, Object?>{
            'userId': 2,
            'email': 'budi@sojucorp.com',
          },
          'message': 'Tautan reset password telah dikirim ke email admin.',
        },
      );

      final Result<AdminUserPasswordResetResult> result =
          await repository.triggerPasswordReset(userId: 2);

      expect(apiClient.lastMethod, 'POST');
      expect(apiClient.lastPath, '/api/v1/users/2/reset-password');
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.userId, 2);
      expect(result.valueOrNull!.email, 'budi@sojucorp.com');
    });

    test('maps 403/409 server responses to ServerFailure with Indonesian message', () async {
      apiClient.nextResponse = const ApiResponse(
        statusCode: 403,
        body: <String, Object?>{
          'success': false,
          'message': 'Tidak dapat menonaktifkan akun sendiri',
        },
      );

      final Result<AdminUserActionResult> result =
          await repository.softDisableUser(userId: 1);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(
        result.failureOrNull!.message,
        'Tidak dapat menonaktifkan akun sendiri',
      );
    });

    test('maps 401 response to UnauthorizedFailure', () async {
      apiClient.nextResponse = const ApiResponse(
        statusCode: 401,
        body: <String, Object?>{
          'success': false,
          'message': 'Sesi berakhir.',
        },
      );

      final Result<List<AdminUser>> result = await repository.fetchUsers();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });
  });
}
