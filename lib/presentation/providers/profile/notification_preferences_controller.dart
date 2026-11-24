// lib/presentation/providers/profile/notification_preferences_controller.dart
//
// State + controller preferensi notifikasi.

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/usecases/profile_usecases.dart';

/// Status layar preferensi notifikasi.
enum NotificationPreferencesStatus { loading, ready, saving, saved, error }

/// State preferensi notifikasi.
@immutable
class NotificationPreferencesState {
  const NotificationPreferencesState({
    this.saved,
    this.draft,
    this.status = NotificationPreferencesStatus.loading,
    this.errorMessage,
  });

  final NotificationPreferencesEntity? saved;
  final NotificationPreferencesEntity? draft;
  final NotificationPreferencesStatus status;
  final String? errorMessage;

  bool get isLoading => status == NotificationPreferencesStatus.loading;
  bool get isSaving => status == NotificationPreferencesStatus.saving;
  bool get hasError => status == NotificationPreferencesStatus.error;
  bool get hasChanges =>
      saved != null && draft != null && !saved!.sameAs(draft!);

  NotificationPreferencesState copyWith({
    NotificationPreferencesEntity? saved,
    NotificationPreferencesEntity? draft,
    NotificationPreferencesStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationPreferencesState(
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Controller preferensi notifikasi.
class NotificationPreferencesController extends ChangeNotifier {
  NotificationPreferencesController({
    required GetNotificationPreferences getPreferences,
    required UpdateNotificationPreferences updatePreferences,
    NotificationPreferencesEntity? initialPreferences,
  })  : _getPreferences = getPreferences,
        _updatePreferences = updatePreferences,
        _state = NotificationPreferencesState(
          saved: initialPreferences,
          draft: initialPreferences,
          status: initialPreferences == null
              ? NotificationPreferencesStatus.loading
              : NotificationPreferencesStatus.ready,
        );

  final GetNotificationPreferences _getPreferences;
  final UpdateNotificationPreferences _updatePreferences;

  NotificationPreferencesState _state;
  bool _disposed = false;

  NotificationPreferencesState get state => _state;

  Future<void> load() async {
    if (_state.draft == null) {
      _state = _state.copyWith(
        status: NotificationPreferencesStatus.loading,
        clearError: true,
      );
      _notify();
    }

    final Result<NotificationPreferencesEntity> result =
        await _getPreferences();
    if (_disposed) {
      return;
    }
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: NotificationPreferencesStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (NotificationPreferencesEntity preferences) {
        _state = _state.copyWith(
          saved: preferences,
          draft: preferences,
          status: NotificationPreferencesStatus.ready,
          clearError: true,
        );
      },
    );
    _notify();
  }

  void toggleStockLow(bool value) {
    final NotificationPreferencesEntity? draft = _state.draft;
    if (draft == null) {
      return;
    }
    _state = _state.copyWith(
      draft: draft.copyWith(stockLow: value),
      status: NotificationPreferencesStatus.ready,
      clearError: true,
    );
    _notify();
  }

  void toggleCashDifference(bool value) {
    final NotificationPreferencesEntity? draft = _state.draft;
    if (draft == null) {
      return;
    }
    _state = _state.copyWith(
      draft: draft.copyWith(cashDifference: value),
      status: NotificationPreferencesStatus.ready,
      clearError: true,
    );
    _notify();
  }

  void toggleDailyTransaction(bool value) {
    final NotificationPreferencesEntity? draft = _state.draft;
    if (draft == null) {
      return;
    }
    _state = _state.copyWith(
      draft: draft.copyWith(dailyTransaction: value),
      status: NotificationPreferencesStatus.ready,
      clearError: true,
    );
    _notify();
  }

  Future<bool> save() async {
    final NotificationPreferencesEntity? draft = _state.draft;
    if (draft == null) {
      return false;
    }

    _state = _state.copyWith(
      status: NotificationPreferencesStatus.saving,
      clearError: true,
    );
    _notify();

    final Result<NotificationPreferencesEntity> result =
        await _updatePreferences(
      draft: NotificationPreferencesDraft.fromEntity(draft),
    );
    if (_disposed) {
      return false;
    }

    return result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: NotificationPreferencesStatus.error,
          errorMessage: failure.message,
        );
        _notify();
        return false;
      },
      onSuccess: (NotificationPreferencesEntity preferences) {
        _state = _state.copyWith(
          saved: preferences,
          draft: preferences,
          status: NotificationPreferencesStatus.saved,
          clearError: true,
        );
        _notify();
        return true;
      },
    );
  }

  void clearError() {
    if (_state.errorMessage == null) {
      return;
    }
    _state = _state.copyWith(
      status: _state.draft == null
          ? NotificationPreferencesStatus.loading
          : NotificationPreferencesStatus.ready,
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
