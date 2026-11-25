// lib/data/datasources/remote/auth_remote_datasource.dart
//
// Implementasi AuthDataSource di atas ApiClient untuk jalur Admin (`/api/v1/auth/*`)
// dan Pelanggan (`/api/customer/*`).

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/auth_datasource.dart';

/// Datasource auth untuk endpoint `/api/v1/auth/*` dan `/api/customer/*`.
class AuthRemoteDataSource implements AuthDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> loginAdminRaw({
    required String email,
    required String password,
  }) {
    return _mapResponse(
      _apiClient.post(
        '/api/v1/auth/login',
        authenticated: false,
        body: <String, Object?>{
          'email': email,
          'password': password,
        },
      ),
    );
  }

  @override
  Future<Map<String, Object?>> loginCustomerRaw({
    required String email,
    required String password,
  }) {
    return _mapResponse(
      _apiClient.post(
        '/api/customer/auth/masuk',
        authenticated: false,
        body: <String, Object?>{
          'email': email,
          'password': password,
        },
      ),
    );
  }

  @override
  Future<Map<String, Object?>> registerCustomerRaw({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  }) {
    return _mapResponse(
      _apiClient.post(
        '/api/customer/auth/daftar',
        authenticated: false,
        body: <String, Object?>{
          'nama': name,
          'email': email,
          'noTelepon': phone,
          'alamat': address,
          'password': password,
          'promosiDiizinkan': promotionAllowed,
        },
      ),
    );
  }

  @override
  Future<Map<String, Object?>> forgotPasswordAdminRaw({
    required String email,
  }) {
    return _mapResponse(
      _apiClient.post(
        '/api/v1/auth/forgot-password',
        authenticated: false,
        body: <String, Object?>{'email': email},
      ),
    );
  }

  @override
  Future<Map<String, Object?>> forgotPasswordCustomerRaw({
    required String email,
  }) {
    return _mapResponse(
      _apiClient.post(
        '/api/customer/auth/lupa-password',
        authenticated: false,
        body: <String, Object?>{'email': email},
      ),
    );
  }

  @override
  Future<Map<String, Object?>> resetPasswordAdminRaw({
    required String token,
    required String newPassword,
  }) {
    return _mapResponse(
      _apiClient.post(
        '/api/v1/auth/reset-password',
        authenticated: false,
        body: <String, Object?>{
          'token': token,
          'passwordBaru': newPassword,
        },
      ),
    );
  }

  @override
  Future<Map<String, Object?>> resetPasswordCustomerRaw({
    required String token,
    required String newPassword,
  }) {
    return _mapResponse(
      _apiClient.post(
        '/api/customer/auth/reset-password',
        authenticated: false,
        body: <String, Object?>{
          'token': token,
          'passwordBaru': newPassword,
        },
      ),
    );
  }

  @override
  Future<Map<String, Object?>> meAdminRaw() {
    return _mapResponse(_apiClient.get('/api/v1/auth/me'));
  }

  @override
  Future<Map<String, Object?>> meCustomerRaw() {
    return _mapResponse(_apiClient.get('/api/customer/profil'));
  }

  Future<Map<String, Object?>> _mapResponse(
    Future<ApiResponse> request,
  ) async {
    final ApiResponse response = await request;
    final Map<String, Object?>? body = _asMap(response.body);

    if (response.statusCode == 401) {
      throw UnauthorizedFailure(
        message: _message(body) ?? 'Sesi berakhir. Silakan masuk kembali.',
      );
    }

    if (body == null) {
      if (response.statusCode >= 500) {
        throw ServerFailure(statusCode: response.statusCode);
      }
      throw const ParsingFailure(
        message: 'Respon server autentikasi tidak dapat dibaca.',
      );
    }

    return body;
  }

  Map<String, Object?>? _asMap(Object? raw) {
    if (raw is Map) {
      return <String, Object?>{
        for (final MapEntry<Object?, Object?> entry in raw.entries)
          entry.key.toString(): entry.value,
      };
    }
    return null;
  }

  String? _message(Map<String, Object?>? body) {
    final Object? message = body?['message'];
    return message is String && message.trim().isNotEmpty
        ? message.trim()
        : null;
  }
}
