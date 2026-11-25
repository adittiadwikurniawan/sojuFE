// lib/data/repositories/auth_repository_impl.dart
//
// Implementasi repository auth lintas peran: parsing envelope, mapping DTO,
// penyimpanan token + peran di SecureTokenStorage, serta pemetaan kegagalan ke Result.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../core/services/token_storage/token_storage.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/interfaces/auth_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/auth/auth_session_model.dart';
import '../models/auth/auth_user_model.dart';

/// Repository auth di atas [AuthDataSource] dan [TokenStorage].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource, this._tokenStorage);

  static const String _defaultForgotMessage =
      'Jika email terdaftar dan aktif, tautan reset password telah dikirim ke email Anda.';
  static const String _defaultResetMessage =
      'Password berhasil diatur ulang. Silakan masuk dengan password baru Anda.';

  final AuthDataSource _dataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    AuthPortal portal = AuthPortal.admin,
  }) {
    if (portal == AuthPortal.customer) {
      return _sessionResult(
        () => _dataSource.loginCustomerRaw(email: email, password: password),
        defaultRole: UserRole.customer,
      );
    }
    return _sessionResult(
      () => _dataSource.loginAdminRaw(email: email, password: password),
      defaultRole: UserRole.admin,
    );
  }

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  }) {
    return _sessionResult(
      () => _dataSource.registerCustomerRaw(
        name: name,
        email: email,
        phone: phone,
        address: address,
        password: password,
        promotionAllowed: promotionAllowed,
      ),
      defaultRole: UserRole.customer,
    );
  }

  @override
  Future<Result<String>> requestPasswordReset({
    required String email,
    AuthPortal portal = AuthPortal.admin,
  }) {
    return _messageResult(
      () => portal == AuthPortal.customer
          ? _dataSource.forgotPasswordCustomerRaw(email: email)
          : _dataSource.forgotPasswordAdminRaw(email: email),
      fallbackSuccessMessage: _defaultForgotMessage,
      fallbackErrorMessage: 'Gagal mengirim tautan reset password.',
    );
  }

  @override
  Future<Result<String>> resetPassword({
    required String token,
    required String newPassword,
    AuthPortal portal = AuthPortal.admin,
  }) {
    return _messageResult(
      () => portal == AuthPortal.customer
          ? _dataSource.resetPasswordCustomerRaw(
              token: token,
              newPassword: newPassword,
            )
          : _dataSource.resetPasswordAdminRaw(
              token: token,
              newPassword: newPassword,
            ),
      fallbackSuccessMessage: _defaultResetMessage,
      fallbackErrorMessage: 'Gagal mengatur ulang password.',
    );
  }

  @override
  Future<Result<AuthUser>> me({UserRole? role}) async {
    try {
      final UserRole targetRole = role ??
          UserRole.tryParse(await _tokenStorage.readRole()) ??
          UserRole.admin;
      return _userResult(
        targetRole == UserRole.customer
            ? _dataSource.meCustomerRaw
            : _dataSource.meAdminRaw,
        defaultRole: targetRole,
      );
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AuthUser>> restoreSession() async {
    try {
      final String? token = await _tokenStorage.read();
      if (token == null || token.isEmpty) {
        return Result.failure(
          const UnauthorizedFailure(message: 'Sesi tidak ditemukan.'),
        );
      }

      final String? storedRoleRaw = await _tokenStorage.readRole();
      final UserRole storedRole =
          UserRole.tryParse(storedRoleRaw) ?? UserRole.admin;

      final Result<AuthUser> result = await _userResult(
        storedRole == UserRole.customer
            ? _dataSource.meCustomerRaw
            : _dataSource.meAdminRaw,
        defaultRole: storedRole,
      );

      if (result.failureOrNull is UnauthorizedFailure) {
        await _tokenStorage.clear();
        return result;
      }

      final AuthUser? restoredUser = result.valueOrNull;
      if (restoredUser != null) {
        try {
          await _tokenStorage.writeRole(restoredUser.role.storageValue);
        } on Object {
          // Kegagalan sinkronisasi ulang role tidak membatalkan sesi valid.
        }
      }

      return result;
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _tokenStorage.clear();
      return Result<void>.success(null);
    } on Object {
      return Result.failure(
        const ServerFailure(message: 'Gagal menghapus sesi lokal.'),
      );
    }
  }

  Future<Result<AuthSession>> _sessionResult(
    Future<Map<String, Object?>> Function() request, {
    required UserRole defaultRole,
  }) async {
    final Map<String, Object?> raw;
    try {
      raw = await request();
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }

    final ApiEnvelopeModel envelope;
    final AuthSessionModel model;
    try {
      envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Autentikasi gagal.',
          ),
        );
      }
      model = AuthSessionModel.fromJson(
        envelope.data,
        defaultRole: defaultRole,
      );
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    }

    final AuthSession session = model.toEntity();

    try {
      await _tokenStorage.write(session.token);
      await _tokenStorage.writeRole(session.user.role.storageValue);
    } on Object {
      return Result.failure(
        const ServerFailure(
          message: 'Sesi berhasil dibuat, tetapi gagal disimpan di perangkat. '
              'Coba lagi.',
        ),
      );
    }

    return Result.success(session);
  }

  Future<Result<AuthUser>> _userResult(
    Future<Map<String, Object?>> Function() request, {
    required UserRole defaultRole,
  }) async {
    try {
      final Map<String, Object?> raw = await request();
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Data pengguna tidak valid.',
          ),
        );
      }

      final AuthUserModel model = AuthUserModel.fromJson(
        envelope.data,
        defaultRole: defaultRole,
      );
      return Result.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }

  Future<Result<String>> _messageResult(
    Future<Map<String, Object?>> Function() request, {
    required String fallbackSuccessMessage,
    required String fallbackErrorMessage,
  }) async {
    try {
      final Map<String, Object?> raw = await request();
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? fallbackErrorMessage,
          ),
        );
      }
      final String? msg = envelope.message?.trim();
      return Result.success(
        msg != null && msg.isNotEmpty ? msg : fallbackSuccessMessage,
      );
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }
}
