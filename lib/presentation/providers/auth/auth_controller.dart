// lib/presentation/providers/auth/auth_controller.dart
//
// State + controller autentikasi lintas peran (SUPER_ADMIN, ADMIN, CUSTOMER).
// Mengikuti pola ChangeNotifier yang sudah dipakai controller lain di repo ini.

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/auth_session_entity.dart';
import '../../../domain/usecases/auth_usecases.dart';

/// Status sesi auth.
enum AuthStatus {
  checking,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

/// State autentikasi.
@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.errorMessage,
    this.feedbackMessage,
    this.isPasswordRecoveryBusy = false,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final String? feedbackMessage;
  final bool isPasswordRecoveryBusy;

  UserRole? get role => user?.role;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isBusy =>
      status == AuthStatus.authenticating || isPasswordRecoveryBusy;
  bool get isChecking => status == AuthStatus.checking;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    String? feedbackMessage,
    bool clearError = false,
    bool clearFeedback = false,
    bool clearUser = false,
    bool? isPasswordRecoveryBusy,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      isPasswordRecoveryBusy:
          isPasswordRecoveryBusy ?? this.isPasswordRecoveryBusy,
    );
  }
}

/// Controller login (Admin & Pelanggan), daftar Pelanggan,
/// lupa/reset password lintas peran, pemulihan sesi, dan logout.
class AuthController extends ChangeNotifier {
  AuthController({
    required Login login,
    required Register register,
    required RestoreSession restoreSession,
    required Logout logout,
    RequestPasswordReset? requestPasswordReset,
    ResetPassword? resetPassword,
  })  : _login = login,
        _register = register,
        _restoreSession = restoreSession,
        _logout = logout,
        _requestPasswordReset = requestPasswordReset,
        _resetPassword = resetPassword;

  final Login _login;
  final Register _register;
  final RestoreSession _restoreSession;
  final Logout _logout;
  final RequestPasswordReset? _requestPasswordReset;
  final ResetPassword? _resetPassword;

  AuthState _state = const AuthState();
  bool _disposed = false;
  bool _actionStarted = false;

  AuthState get state => _state;

  /// Membaca token dan peran tersimpan lalu memvalidasinya lewat
  /// `/api/v1/auth/me` (Admin/Super Admin) atau `/api/customer/profil` (Pelanggan).
  Future<void> bootstrap() async {
    _setState(const AuthState(status: AuthStatus.checking));

    final Result<AuthUser> result = await _restoreSession();
    if (_disposed || _actionStarted) {
      return;
    }

    result.fold(
      onFailure: (AppFailure failure) {
        _setState(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: failure is UnauthorizedFailure
                ? null
                : _friendlyMessage(failure),
          ),
        );
      },
      onSuccess: (AuthUser user) {
        _setState(
          AuthState(
            status: AuthStatus.authenticated,
            user: user,
          ),
        );
      },
    );
  }

  /// Login email/password sesuai [portal] (Admin atau Pelanggan).
  /// Mengembalikan `true` bila berhasil.
  Future<bool> login({
    required String email,
    required String password,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    if (_state.isBusy) {
      return false;
    }

    _actionStarted = true;
    _setState(
      _state.copyWith(
        status: AuthStatus.authenticating,
        clearError: true,
        clearFeedback: true,
      ),
    );

    final Result<AuthSession> result = await _login(
      email: email,
      password: password,
      portal: portal,
    );
    if (_disposed) {
      return false;
    }

    return result.fold(
      onFailure: (AppFailure failure) {
        _setState(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: _friendlyMessage(failure),
          ),
        );
        return false;
      },
      onSuccess: (AuthSession session) {
        _setState(
          AuthState(
            status: AuthStatus.authenticated,
            user: session.user,
          ),
        );
        return true;
      },
    );
  }

  /// Pendaftaran akun Pelanggan baru (`/api/customer/auth/daftar`).
  /// Mengembalikan `true` bila berhasil.
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  }) async {
    if (_state.isBusy) {
      return false;
    }

    _actionStarted = true;
    _setState(
      _state.copyWith(
        status: AuthStatus.authenticating,
        clearError: true,
        clearFeedback: true,
      ),
    );

    final Result<AuthSession> result = await _register(
      name: name,
      email: email,
      phone: phone,
      address: address,
      password: password,
      promotionAllowed: promotionAllowed,
    );
    if (_disposed) {
      return false;
    }

    return result.fold(
      onFailure: (AppFailure failure) {
        _setState(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: _friendlyMessage(failure),
          ),
        );
        return false;
      },
      onSuccess: (AuthSession session) {
        _setState(
          AuthState(
            status: AuthStatus.authenticated,
            user: session.user,
          ),
        );
        return true;
      },
    );
  }

  /// Meminta tautan/token reset password untuk [portal] (Admin atau Pelanggan).
  Future<bool> requestPasswordReset({
    required String email,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    if (_state.isBusy) {
      return false;
    }

    final RequestPasswordReset? usecase = _requestPasswordReset;
    if (usecase == null) {
      _setState(
        _state.copyWith(
          errorMessage: 'Fitur lupa password belum terkonfigurasi.',
          clearFeedback: true,
        ),
      );
      return false;
    }

    _actionStarted = true;
    _setState(
      _state.copyWith(
        isPasswordRecoveryBusy: true,
        clearError: true,
        clearFeedback: true,
      ),
    );

    final Result<String> result = await usecase(
      email: email,
      portal: portal,
    );
    if (_disposed) {
      return false;
    }

    return result.fold(
      onFailure: (AppFailure failure) {
        _setState(
          _state.copyWith(
            isPasswordRecoveryBusy: false,
            errorMessage: _friendlyMessage(failure),
          ),
        );
        return false;
      },
      onSuccess: (String message) {
        _setState(
          _state.copyWith(
            isPasswordRecoveryBusy: false,
            feedbackMessage: message,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Mengatur ulang password menggunakan [token] untuk [portal] (Admin atau Pelanggan).
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    if (_state.isBusy) {
      return false;
    }

    final ResetPassword? usecase = _resetPassword;
    if (usecase == null) {
      _setState(
        _state.copyWith(
          errorMessage: 'Fitur atur ulang password belum terkonfigurasi.',
          clearFeedback: true,
        ),
      );
      return false;
    }

    _actionStarted = true;
    _setState(
      _state.copyWith(
        isPasswordRecoveryBusy: true,
        clearError: true,
        clearFeedback: true,
      ),
    );

    final Result<String> result = await usecase(
      token: token,
      newPassword: newPassword,
      portal: portal,
    );
    if (_disposed) {
      return false;
    }

    return result.fold(
      onFailure: (AppFailure failure) {
        _setState(
          _state.copyWith(
            isPasswordRecoveryBusy: false,
            errorMessage: _friendlyMessage(failure),
          ),
        );
        return false;
      },
      onSuccess: (String message) {
        _setState(
          _state.copyWith(
            isPasswordRecoveryBusy: false,
            feedbackMessage: message,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Logout lokal dan kembali ke status belum login.
  Future<void> logout() async {
    _actionStarted = true;
    await _logout();
    if (_disposed) {
      return;
    }
    _setState(const AuthState(status: AuthStatus.unauthenticated));
  }

  void clearError() {
    if (_state.errorMessage == null && _state.feedbackMessage == null) {
      return;
    }
    _setState(_state.copyWith(clearError: true, clearFeedback: true));
  }

  void _setState(AuthState state) {
    _state = state;
    if (!_disposed) {
      notifyListeners();
    }
  }

  String _friendlyMessage(AppFailure failure) {
    final String raw = failure.message.toLowerCase();
    if (failure is NetworkFailure) {
      return 'Tidak dapat terhubung ke server. Pastikan backend berjalan. '
          'Di perangkat fisik gunakan API_BASE_URL berisi IP LAN komputer, '
          'bukan localhost.';
    }
    if (raw.contains('invalid credentials') ||
        raw.contains('email atau password tidak valid') ||
        raw.contains('email atau password salah')) {
      return 'Email atau password salah.';
    }
    if (raw.contains('email and password')) {
      return 'Email dan password wajib diisi.';
    }
    if (raw.contains('user not found')) {
      return 'Akun pengguna tidak ditemukan.';
    }
    if (raw.contains('account disabled') || raw.contains('disabled')) {
      return 'Akun Anda sedang dinonaktifkan. Hubungi Super Admin.';
    }
    if (raw.contains('email sudah terdaftar') ||
        raw.contains('already registered') ||
        raw.contains('already exists')) {
      return 'Email sudah terdaftar. Silakan masuk.';
    }
    if (raw.contains('invalid token') || raw.contains('token expired')) {
      return 'Token reset password tidak valid atau sudah kedaluwarsa.';
    }
    return failure.message;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
