// lib/data/datasources/interfaces/profile_datasource.dart
//
// Kontrak datasource profil.
//
// Datasource mengembalikan map JSON mentah berbentuk envelope
// `{success, data, message?}` agar mock Phase A dan remote Phase B memakai
// jalur parsing repository yang sama.

import '../../../domain/entities/profile_entity.dart';

/// Sumber data mentah profil, password, dan preferensi notifikasi.
abstract interface class ProfileDataSource {
  Future<Map<String, Object?>> fetchProfileRaw();

  Future<Map<String, Object?>> updateProfileRaw({
    required ProfileUpdateDraft draft,
  });

  Future<Map<String, Object?>> updatePhotoRaw({
    required ProfilePhotoDraft draft,
  });

  Future<Map<String, Object?>> changePasswordRaw({
    required ChangePasswordDraft draft,
  });

  Future<Map<String, Object?>> fetchNotificationPreferencesRaw();

  Future<Map<String, Object?>> updateNotificationPreferencesRaw({
    required NotificationPreferencesDraft draft,
  });
}
