// lib/data/datasources/mock/customer_profile_mock_datasource.dart
//
// Mock data profil pelanggan in-memory untuk pengujian terisolasi (TASK-025).

import '../../../core/errors/app_failure.dart';
import '../interfaces/customer_profile_datasource.dart';

class CustomerProfileMockDataSource implements CustomerProfileDataSource {
  CustomerProfileMockDataSource({Map<String, Object?>? initialProfile})
      : _profile = initialProfile != null
            ? Map<String, Object?>.from(initialProfile)
            : <String, Object?>{
                'id': 1,
                'nama': 'Pelanggan SOJU',
                'email': 'pelanggan@sojucorp.com',
                'noTelepon': '081234567890',
                'alamat': 'Jl. Senopati No. 45, Jakarta Selatan',
                'promosiDiizinkan': true,
                'emailTerverifikasiPada': '2026-11-20T10:00:00.000Z',
                'dibuatPada': '2026-11-20T09:00:00.000Z',
                'terakhirMasukPada': '2026-11-25T01:00:00.000Z',
              };

  final Map<String, Object?> _profile;
  String _currentPassword = 'password123';

  @override
  Future<Map<String, Object?>> fetchProfile() async {
    return <String, Object?>{
      'status': 'success',
      'data': Map<String, Object?>.from(_profile),
    };
  }

  @override
  Future<Map<String, Object?>> updateProfile(Map<String, Object?> payload) async {
    for (final String key in <String>['nama', 'email', 'noTelepon', 'alamat', 'promosiDiizinkan']) {
      if (payload.containsKey(key)) {
        _profile[key] = payload[key];
      }
    }
    return <String, Object?>{
      'status': 'success',
      'message': 'Profil berhasil diperbarui',
      'data': Map<String, Object?>.from(_profile),
    };
  }

  @override
  Future<Map<String, Object?>> changePassword(Map<String, Object?> payload) async {
    final String oldPass = (payload['passwordLama'] ?? payload['currentPassword'] ?? '') as String;
    final String newPass = (payload['passwordBaru'] ?? payload['newPassword'] ?? '') as String;

    if (oldPass != _currentPassword) {
      throw const ServerFailure(
        statusCode: 400,
        message: 'Password lama tidak sesuai',
      );
    }
    if (newPass.length < 8) {
      throw const ServerFailure(
        statusCode: 400,
        message: 'Password baru minimal 8 karakter',
      );
    }

    _currentPassword = newPass;
    return <String, Object?>{
      'status': 'success',
      'message': 'Password berhasil diperbarui',
      'data': null,
    };
  }
}
