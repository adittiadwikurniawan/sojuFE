// lib/domain/usecases/profile_usecases.dart
//
// Usecase profil, password, dan preferensi notifikasi.

import '../../core/common/result.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Mengambil profil akun aktif.
class GetProfile {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<ProfileEntity>> call() => _repository.getProfile();
}

/// Menyimpan perubahan data profil.
class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<ProfileEntity>> call({required ProfileUpdateDraft draft}) {
    return _repository.updateProfile(draft: draft);
  }
}

/// Mengganti atau menghapus foto profil.
class UpdateProfilePhoto {
  const UpdateProfilePhoto(this._repository);

  final ProfileRepository _repository;

  Future<Result<ProfileEntity>> call({required ProfilePhotoDraft draft}) {
    return _repository.updatePhoto(draft: draft);
  }
}

/// Mengubah password akun.
class ChangePassword {
  const ChangePassword(this._repository);

  final ProfileRepository _repository;

  Future<Result<String>> call({required ChangePasswordDraft draft}) {
    return _repository.changePassword(draft: draft);
  }
}

/// Mengambil preferensi notifikasi.
class GetNotificationPreferences {
  const GetNotificationPreferences(this._repository);

  final ProfileRepository _repository;

  Future<Result<NotificationPreferencesEntity>> call() {
    return _repository.getNotificationPreferences();
  }
}

/// Menyimpan preferensi notifikasi.
class UpdateNotificationPreferences {
  const UpdateNotificationPreferences(this._repository);

  final ProfileRepository _repository;

  Future<Result<NotificationPreferencesEntity>> call({
    required NotificationPreferencesDraft draft,
  }) {
    return _repository.updateNotificationPreferences(draft: draft);
  }
}
