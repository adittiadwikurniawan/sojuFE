// lib/data/datasources/remote/admin_users_remote_datasource.dart
//
// Remote datasource Manajemen Multi-User Admin (`SUPER_ADMIN` only):
// - `GET /api/v1/users?search=&peran=&aktif=`
// - `POST /api/v1/users`
// - `PATCH /api/v1/users/:id`
// - `PATCH /api/v1/users/:id/status`
// - `DELETE /api/v1/users/:id`
// - `POST /api/v1/users/:id/reset-password`

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/admin_users_datasource.dart';

class AdminUsersRemoteDataSource implements AdminUsersDataSource {
  const AdminUsersRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchUsersRaw({
    String? search,
    String? role,
    bool? isActive,
  }) {
    final Map<String, String> query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (role != null && role.trim().isNotEmpty) {
      query['peran'] = role.trim();
    }
    if (isActive != null) {
      query['aktif'] = isActive ? 'true' : 'false';
    }
    return _map(
      _apiClient.get(
        '/api/v1/users',
        queryParameters: query.isEmpty ? null : query,
      ),
    );
  }

  @override
  Future<Map<String, Object?>> createUserRaw({
    required String name,
    required String email,
    String? password,
    required String role,
    bool sendInvite = false,
  }) {
    final Map<String, Object?> payload = <String, Object?>{
      'nama': name.trim(),
      'email': email.trim(),
      'peran': role,
      'sendInvite': sendInvite,
    };
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }
    return _map(
      _apiClient.post('/api/v1/users', body: payload),
    );
  }

  @override
  Future<Map<String, Object?>> updateUserRaw({
    required int userId,
    String? name,
    String? email,
    String? role,
  }) {
    final Map<String, Object?> payload = <String, Object?>{};
    if (name != null) payload['nama'] = name.trim();
    if (email != null) payload['email'] = email.trim();
    if (role != null) payload['peran'] = role;

    return _map(
      _apiClient.patch('/api/v1/users/$userId', body: payload),
    );
  }

  @override
  Future<Map<String, Object?>> updateUserStatusRaw({
    required int userId,
    required bool isActive,
  }) {
    return _map(
      _apiClient.patch(
        '/api/v1/users/$userId/status',
        body: <String, Object?>{'aktif': isActive},
      ),
    );
  }

  @override
  Future<Map<String, Object?>> softDisableUserRaw({
    required int userId,
  }) {
    return _map(
      _apiClient.delete('/api/v1/users/$userId'),
    );
  }

  @override
  Future<Map<String, Object?>> triggerPasswordResetRaw({
    required int userId,
  }) {
    return _map(
      _apiClient.post('/api/v1/users/$userId/reset-password'),
    );
  }

  Future<Map<String, Object?>> _map(Future<ApiResponse> request) async {
    final ApiResponse response;
    try {
      response = await request;
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }

    final Object? raw = response.body;
    final Map<String, Object?>? body = raw is Map
        ? <String, Object?>{
            for (final MapEntry<Object?, Object?> e in raw.entries)
              e.key.toString(): e.value,
          }
        : null;

    final Object? message = body?['message'];
    final String? text =
        message is String && message.trim().isNotEmpty ? message.trim() : null;

    if (response.statusCode == 401) {
      throw UnauthorizedFailure(message: text);
    }
    if (!response.isSuccess) {
      throw ServerFailure(statusCode: response.statusCode, message: text);
    }
    if (body == null) {
      throw const ParsingFailure();
    }

    return body;
  }
}
