// lib/data/datasources/remote/profile_remote_datasource.dart
//
// Remote datasource Profil & Keamanan Akun Admin/Super Admin:
// - `GET /api/v1/auth/me`
// - `PATCH /api/v1/auth/me`
// - `POST /api/v1/auth/change-password`

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../../../domain/entities/profile_entity.dart';
import '../interfaces/profile_datasource.dart';

class ProfileRemoteDataSource implements ProfileDataSource {
  ProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  String _cachedPhone = '0812 3456 7890';
  String? _cachedAvatarAsset = 'assets/images/avatar_profil.png';
  String? _cachedAvatarUrl;
  Map<String, Object?> _cachedProfile = <String, Object?>{
    'id': 'admin',
    'nama': 'Pengelola SOJU',
    'email': 'admin@bukudapur.com',
    'no_telepon': '0812 3456 7890',
    'role': 'Admin',
    'foto_profil_asset': 'assets/images/avatar_profil.png',
  };

  final Map<String, Object?> _notificationPreferences = <String, Object?>{
    'stok_menipis': true,
    'selisih_kas': false,
    'transaksi_harian': false,
  };

  static String _roleLabel(Object? rawRole) {
    return switch (rawRole?.toString().toUpperCase()) {
      'SUPER_ADMIN' => 'Super Admin',
      'ADMIN' => 'Admin',
      _ => 'Admin',
    };
  }

  Map<String, Object?> _normalizeUserMap(Map<Object?, Object?> data) {
    final Map<String, Object?> normalized = <String, Object?>{
      'id': data['id']?.toString() ?? _cachedProfile['id'],
      'nama': data['nama']?.toString() ??
          data['name']?.toString() ??
          _cachedProfile['nama'],
      'email': data['email']?.toString() ?? _cachedProfile['email'],
      'no_telepon': data['noTelepon']?.toString() ??
          data['no_telepon']?.toString() ??
          _cachedPhone,
      'role': _roleLabel(data['peran'] ?? data['role']),
      if (_cachedAvatarAsset != null) 'foto_profil_asset': _cachedAvatarAsset,
      if (_cachedAvatarUrl != null) 'foto_profil': _cachedAvatarUrl,
    };
    _cachedProfile = normalized;
    return normalized;
  }

  @override
  Future<Map<String, Object?>> fetchProfileRaw() async {
    final Map<String, Object?> body =
        await _send(_apiClient.get('/api/v1/auth/me'));
    final Object? data = body['data'];
    if (data is Map) {
      return <String, Object?>{
        'success': true,
        'data': _normalizeUserMap(data),
      };
    }
    return <String, Object?>{'success': true, 'data': _cachedProfile};
  }

  @override
  Future<Map<String, Object?>> updateProfileRaw({
    required ProfileUpdateDraft draft,
  }) async {
    _cachedPhone = draft.phone;
    final Map<String, Object?> body = await _send(
      _apiClient.patch(
        '/api/v1/auth/me',
        body: <String, Object?>{
          'nama': draft.name,
          'email': draft.email,
        },
      ),
    );
    final Object? data = body['data'];
    if (data is Map) {
      return <String, Object?>{
        'success': true,
        'data': _normalizeUserMap(data),
      };
    }
    return <String, Object?>{'success': true, 'data': _cachedProfile};
  }

  @override
  Future<Map<String, Object?>> updatePhotoRaw({
    required ProfilePhotoDraft draft,
  }) async {
    if (draft.remove) {
      _cachedAvatarAsset = null;
      _cachedAvatarUrl = null;
      _cachedProfile.remove('foto_profil');
      _cachedProfile.remove('foto_profil_asset');
    } else {
      if (draft.imageUrl != null) {
        _cachedAvatarUrl = draft.imageUrl;
        _cachedProfile['foto_profil'] = draft.imageUrl;
      }
      if (draft.assetPath != null) {
        _cachedAvatarAsset = draft.assetPath;
        _cachedProfile['foto_profil_asset'] = draft.assetPath;
      }
    }
    return <String, Object?>{
      'success': true,
      'data': Map<String, Object?>.of(_cachedProfile),
    };
  }

  @override
  Future<Map<String, Object?>> changePasswordRaw({
    required ChangePasswordDraft draft,
  }) async {
    final Map<String, Object?> body = await _send(
      _apiClient.post(
        '/api/v1/auth/change-password',
        body: <String, Object?>{
          'passwordLama': draft.currentPassword,
          'passwordBaru': draft.newPassword,
        },
      ),
    );
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'message': body['message']?.toString() ?? 'Password berhasil diperbarui.',
      },
    };
  }

  @override
  Future<Map<String, Object?>> fetchNotificationPreferencesRaw() async {
    return <String, Object?>{
      'success': true,
      'data': Map<String, Object?>.of(_notificationPreferences),
    };
  }

  @override
  Future<Map<String, Object?>> updateNotificationPreferencesRaw({
    required NotificationPreferencesDraft draft,
  }) async {
    _notificationPreferences
      ..['stok_menipis'] = draft.stockLow
      ..['selisih_kas'] = draft.cashDifference
      ..['transaksi_harian'] = draft.dailyTransaction;
    return <String, Object?>{
      'success': true,
      'data': Map<String, Object?>.of(_notificationPreferences),
    };
  }

  Future<Map<String, Object?>> _send(Future<ApiResponse> request) async {
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
