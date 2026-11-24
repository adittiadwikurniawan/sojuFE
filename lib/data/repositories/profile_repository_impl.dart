// lib/data/repositories/profile_repository_impl.dart
//
// Implementasi repository profil.
//
// Mengurai envelope `{success, data, message?}`, memetakan DTO ke entity
// domain, dan memetakan kegagalan ke `Result` (ARCHITECTURE.md §2.5/§2.8).

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/interfaces/profile_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/profile/profile_model.dart';

/// Repository profil di atas [ProfileDataSource].
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);

  final ProfileDataSource _dataSource;

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return _profileResult(() => _dataSource.fetchProfileRaw());
  }

  @override
  Future<Result<ProfileEntity>> updateProfile({
    required ProfileUpdateDraft draft,
  }) async {
    return _profileResult(
      () => _dataSource.updateProfileRaw(draft: draft),
    );
  }

  @override
  Future<Result<ProfileEntity>> updatePhoto({
    required ProfilePhotoDraft draft,
  }) async {
    return _profileResult(
      () => _dataSource.updatePhotoRaw(draft: draft),
    );
  }

  @override
  Future<Result<String>> changePassword({
    required ChangePasswordDraft draft,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.changePasswordRaw(
        draft: draft,
      );
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Password gagal diperbarui.',
          ),
        );
      }
      final Object? data = envelope.data;
      final String message = data is Map && data['message'] is String
          ? data['message'] as String
          : 'Password berhasil diperbarui.';
      return Result.success(message);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<NotificationPreferencesEntity>>
      getNotificationPreferences() async {
    return _notificationResult(
      () => _dataSource.fetchNotificationPreferencesRaw(),
    );
  }

  @override
  Future<Result<NotificationPreferencesEntity>> updateNotificationPreferences({
    required NotificationPreferencesDraft draft,
  }) async {
    return _notificationResult(
      () => _dataSource.updateNotificationPreferencesRaw(draft: draft),
    );
  }

  Future<Result<ProfileEntity>> _profileResult(
    Future<Map<String, Object?>> Function() request,
  ) async {
    try {
      final Map<String, Object?> raw = await request();
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Data profil tidak valid.',
          ),
        );
      }
      final ProfileModel model = ProfileModel.fromJson(envelope.data);
      return Result.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }

  Future<Result<NotificationPreferencesEntity>> _notificationResult(
    Future<Map<String, Object?>> Function() request,
  ) async {
    try {
      final Map<String, Object?> raw = await request();
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Preferensi notifikasi tidak valid.',
          ),
        );
      }
      final NotificationPreferencesModel model =
          NotificationPreferencesModel.fromJson(envelope.data);
      return Result.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }
}
