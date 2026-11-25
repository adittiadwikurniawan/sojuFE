// lib/domain/repositories/profile_repository.dart
//
// Kontrak repository profil, password, dan preferensi notifikasi.
//
// Phase A memakai datasource mock. Phase B cukup mengganti datasource di
// `data/data_providers.dart`; usecase, controller, dan UI tidak berubah.

import '../../core/common/result.dart';
import '../entities/profile_entity.dart';

/// Repository profil akun.
abstract interface class ProfileRepository {
  /// Mengambil profil akun aktif.
  Future<Result<ProfileEntity>> getProfile();

  /// Menyimpan perubahan nama, email, dan nomor telepon.
  Future<Result<ProfileEntity>> updateProfile({
    required ProfileUpdateDraft draft,
  });

  /// Mengganti atau menghapus foto profil.
  Future<Result<ProfileEntity>> updatePhoto({
    required ProfilePhotoDraft draft,
  });

  /// Mengubah password akun.
  Future<Result<String>> changePassword({
    required ChangePasswordDraft draft,
  });

  /// Mengambil preferensi notifikasi.
  Future<Result<NotificationPreferencesEntity>> getNotificationPreferences();

  /// Menyimpan preferensi notifikasi.
  Future<Result<NotificationPreferencesEntity>> updateNotificationPreferences({
    required NotificationPreferencesDraft draft,
  });
}
