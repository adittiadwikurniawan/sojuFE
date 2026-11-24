// lib/presentation/providers/profile/change_password_controller.dart
//
// State + validasi form Ganti Password.

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/usecases/profile_usecases.dart';

/// Status form ganti password.
enum ChangePasswordStatus { editing, submitting, success, error }

/// State form ganti password.
@immutable
class ChangePasswordState {
  const ChangePasswordState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.status = ChangePasswordStatus.editing,
    this.currentError,
    this.newError,
    this.confirmError,
    this.errorMessage,
    this.successMessage,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final ChangePasswordStatus status;
  final String? currentError;
  final String? newError;
  final String? confirmError;
  final String? errorMessage;
  final String? successMessage;

  bool get isSubmitting => status == ChangePasswordStatus.submitting;
  bool get isSuccess => status == ChangePasswordStatus.success;

  ChangePasswordState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    ChangePasswordStatus? status,
    String? currentError,
    String? newError,
    String? confirmError,
    String? errorMessage,
    String? successMessage,
    bool clearFieldErrors = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return ChangePasswordState(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      currentError:
          clearFieldErrors ? null : (currentError ?? this.currentError),
      newError: clearFieldErrors ? null : (newError ?? this.newError),
      confirmError:
          clearFieldErrors ? null : (confirmError ?? this.confirmError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Controller form ganti password.
class ChangePasswordController extends ChangeNotifier {
  ChangePasswordController({required ChangePassword changePassword})
      : _changePassword = changePassword;

  final ChangePassword _changePassword;

  ChangePasswordState _state = const ChangePasswordState();
  bool _disposed = false;

  ChangePasswordState get state => _state;

  void updateCurrentPassword(String value) {
    _state = _state.copyWith(
      currentPassword: value,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    _notify();
  }

  void updateNewPassword(String value) {
    _state = _state.copyWith(
      newPassword: value,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    _notify();
  }

  void updateConfirmPassword(String value) {
    _state = _state.copyWith(
      confirmPassword: value,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    _notify();
  }

  /// Validasi lalu kirim ke repository.
  Future<bool> submit() async {
    final String current = _state.currentPassword;
    final String next = _state.newPassword;
    final String confirm = _state.confirmPassword;

    String? currentError;
    String? newError;
    String? confirmError;

    if (current.trim().isEmpty) {
      currentError = 'Password saat ini wajib diisi.';
    }
    if (next.isEmpty) {
      newError = 'Password baru wajib diisi.';
    } else if (next.length < 8) {
      newError = 'Password baru minimal 8 karakter.';
    } else if (next == current) {
      newError = 'Password baru harus berbeda dari password saat ini.';
    }
    if (confirm.isEmpty) {
      confirmError = 'Konfirmasi password wajib diisi.';
    } else if (confirm != next) {
      confirmError = 'Konfirmasi password tidak cocok.';
    }

    if (currentError != null || newError != null || confirmError != null) {
      _state = _state.copyWith(
        status: ChangePasswordStatus.editing,
        currentError: currentError,
        newError: newError,
        confirmError: confirmError,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      );
      _notify();
      return false;
    }

    _state = _state.copyWith(
      status: ChangePasswordStatus.submitting,
      clearFieldErrors: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    _notify();

    final Result<String> result = await _changePassword(
      draft: ChangePasswordDraft(
        currentPassword: current,
        newPassword: next,
      ),
    );
    if (_disposed) {
      return false;
    }

    return result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: ChangePasswordStatus.error,
          errorMessage: failure.message,
        );
        _notify();
        return false;
      },
      onSuccess: (String message) {
        _state = _state.copyWith(
          status: ChangePasswordStatus.success,
          successMessage: message,
          clearErrorMessage: true,
        );
        _notify();
        return true;
      },
    );
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
