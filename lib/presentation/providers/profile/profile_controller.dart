// lib/presentation/providers/profile/profile_controller.dart
//
// State + controller layar Profil dan Akun Saya.
//
// Semua request melewati usecase profil. Phase A memakai datasource mock;
// controller tidak pernah memanggil HTTP secara langsung.

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/usecases/profile_usecases.dart';

/// Status pemuatan/penyimpanan profil.
enum ProfileStatus { loading, ready, saving, error }

/// State layar profil.
@immutable
class ProfileState {
  const ProfileState({
    this.profile,
    this.status = ProfileStatus.loading,
    this.errorMessage,
    this.isUploadingPhoto = false,
  });

  final ProfileEntity? profile;
  final ProfileStatus status;
  final String? errorMessage;
  final bool isUploadingPhoto;

  bool get isLoading => status == ProfileStatus.loading;
  bool get isSaving => status == ProfileStatus.saving;
  bool get hasError => status == ProfileStatus.error;

  ProfileState copyWith({
    ProfileEntity? profile,
    ProfileStatus? status,
    String? errorMessage,
    bool clearError = false,
    bool? isUploadingPhoto,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }
}

/// Controller data profil akun.
class ProfileController extends ChangeNotifier {
  ProfileController({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required UpdateProfilePhoto updateProfilePhoto,
    ProfileEntity? initialProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _updateProfilePhoto = updateProfilePhoto,
        _state = ProfileState(
          profile: initialProfile,
          status: initialProfile == null
              ? ProfileStatus.loading
              : ProfileStatus.ready,
        );

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final UpdateProfilePhoto _updateProfilePhoto;

  ProfileState _state;
  bool _disposed = false;

  ProfileState get state => _state;

  /// Memuat profil terbaru. Profil awal (bila ada) tetap tampil selama load.
  Future<void> load() async {
    if (_state.profile == null) {
      _state = _state.copyWith(
        status: ProfileStatus.loading,
        clearError: true,
      );
      _notify();
    }

    final Result<ProfileEntity> result = await _getProfile();
    if (_disposed) {
      return;
    }
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (ProfileEntity profile) {
        _state = _state.copyWith(
          profile: profile,
          status: ProfileStatus.ready,
          clearError: true,
        );
      },
    );
    _notify();
  }

  /// Menyimpan perubahan nama/email/no telepon.
  Future<bool> save(ProfileUpdateDraft draft) async {
    _state = _state.copyWith(
      status: ProfileStatus.saving,
      clearError: true,
    );
    _notify();

    final Result<ProfileEntity> result = await _updateProfile(draft: draft);
    if (_disposed) {
      return false;
    }
    return result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
        _notify();
        return false;
      },
      onSuccess: (ProfileEntity profile) {
        _state = _state.copyWith(
          profile: profile,
          status: ProfileStatus.ready,
          clearError: true,
        );
        _notify();
        return true;
      },
    );
  }

  /// Mengganti atau menghapus foto profil.
  Future<bool> updatePhoto(ProfilePhotoDraft draft) async {
    _state = _state.copyWith(
      isUploadingPhoto: true,
      clearError: true,
    );
    _notify();

    final Result<ProfileEntity> result = await _updateProfilePhoto(
      draft: draft,
    );
    if (_disposed) {
      return false;
    }
    return result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          isUploadingPhoto: false,
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
        _notify();
        return false;
      },
      onSuccess: (ProfileEntity profile) {
        _state = _state.copyWith(
          profile: profile,
          status: ProfileStatus.ready,
          isUploadingPhoto: false,
          clearError: true,
        );
        _notify();
        return true;
      },
    );
  }

  /// Menghapus pesan galat setelah ditampilkan.
  void clearError() {
    if (_state.errorMessage == null && _state.status != ProfileStatus.error) {
      return;
    }
    _state = _state.copyWith(
      status:
          _state.profile == null ? ProfileStatus.loading : ProfileStatus.ready,
      clearError: true,
    );
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
