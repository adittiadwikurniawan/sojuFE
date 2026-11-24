// lib/data/datasources/mock/profile_mock_datasource.dart
//
// Sumber data mock profil (Phase A).
//
// Menyimpan state di memori agar perubahan foto/profil/preferensi langsung
// terlihat saat berpindah layar. Bentuk respons sama dengan envelope API
// sehingga Phase B cukup mengganti datasource ini dengan implementasi remote.

import '../../../domain/entities/profile_entity.dart';
import '../interfaces/profile_datasource.dart';

/// Mock datasource profil akun.
class ProfileMockDataSource implements ProfileDataSource {
  ProfileMockDataSource({
    Map<String, Object?>? initialProfile,
    Map<String, Object?>? initialNotificationPreferences,
  })  : _profile = <String, Object?>{
          'id': 'profile-1',
          'nama': 'Adittia',
          'email': 'adittia@sojucorp.com',
          'no_telepon': '0812 3456 7890',
          'role': 'Owner',
          'foto_profil_asset': 'assets/images/avatar_profil.png',
          ...?initialProfile,
        },
        _notificationPreferences = <String, Object?>{
          'stok_menipis': true,
          'selisih_kas': false,
          'transaksi_harian': false,
          ...?initialNotificationPreferences,
        };

  final Map<String, Object?> _profile;
  final Map<String, Object?> _notificationPreferences;

  @override
  Future<Map<String, Object?>> fetchProfileRaw() async {
    return _envelope(_profile);
  }

  @override
  Future<Map<String, Object?>> updateProfileRaw({
    required ProfileUpdateDraft draft,
  }) async {
    _profile
      ..['nama'] = draft.name
      ..['email'] = draft.email
      ..['no_telepon'] = draft.phone;
    return _envelope(_profile);
  }

  @override
  Future<Map<String, Object?>> updatePhotoRaw({
    required ProfilePhotoDraft draft,
  }) async {
    if (draft.remove) {
      _profile.remove('foto_profil');
      _profile.remove('foto_profil_asset');
    } else {
      if (draft.imageUrl != null) {
        _profile['foto_profil'] = draft.imageUrl;
      }
      if (draft.assetPath != null) {
        _profile['foto_profil_asset'] = draft.assetPath;
      }
    }
    return _envelope(_profile);
  }

  @override
  Future<Map<String, Object?>> changePasswordRaw({
    required ChangePasswordDraft draft,
  }) async {
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'message': 'Password berhasil diperbarui.',
      },
    };
  }

  @override
  Future<Map<String, Object?>> fetchNotificationPreferencesRaw() async {
    return _envelope(_notificationPreferences);
  }

  @override
  Future<Map<String, Object?>> updateNotificationPreferencesRaw({
    required NotificationPreferencesDraft draft,
  }) async {
    _notificationPreferences
      ..['stok_menipis'] = draft.stockLow
      ..['selisih_kas'] = draft.cashDifference
      ..['transaksi_harian'] = draft.dailyTransaction;
    return _envelope(_notificationPreferences);
  }

  Map<String, Object?> _envelope(Map<String, Object?> data) {
    return <String, Object?>{
      'success': true,
      'data': Map<String, Object?>.of(data),
    };
  }
}
