// lib/data/datasources/remote/customer_profile_remote_datasource.dart
//
// Implementasi CustomerProfileDataSource di atas ApiClient:
// - `GET /api/customer/profil`
// - `PATCH /api/customer/profil`
// - `POST /api/customer/ubah-password`

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/customer_profile_datasource.dart';

class CustomerProfileRemoteDataSource implements CustomerProfileDataSource {
  const CustomerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchProfile() {
    return _map(_apiClient.get('/api/customer/profil'));
  }

  @override
  Future<Map<String, Object?>> updateProfile(Map<String, Object?> payload) {
    return _map(
      _apiClient.patch(
        '/api/customer/profil',
        body: payload,
      ),
    );
  }

  @override
  Future<Map<String, Object?>> changePassword(Map<String, Object?> payload) {
    return _map(
      _apiClient.post(
        '/api/customer/ubah-password',
        body: payload,
      ),
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
