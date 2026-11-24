// lib/domain/usecases/auth_usecases.dart
//
// Usecase autentikasi lintas peran (Admin/Super Admin dan Pelanggan).

import '../../core/common/result.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// Login dengan email, password, dan jalur portal ([AuthPortal.admin] atau [AuthPortal.customer]).
class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required String email,
    required String password,
    AuthPortal portal = AuthPortal.admin,
  }) {
    return _repository.login(
      email: email,
      password: password,
      portal: portal,
    );
  }
}

/// Pendaftaran akun Pelanggan baru (`/api/customer/auth/daftar`).
class Register {
  const Register(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  }) {
    return _repository.register(
      name: name,
      email: email,
      phone: phone,
      address: address,
      password: password,
      promotionAllowed: promotionAllowed,
    );
  }
}

/// Meminta tautan/token reset password untuk Admin atau Pelanggan.
class RequestPasswordReset {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<Result<String>> call({
    required String email,
    AuthPortal portal = AuthPortal.admin,
  }) {
    return _repository.requestPasswordReset(
      email: email,
      portal: portal,
    );
  }
}

/// Mengatur ulang password menggunakan token untuk Admin atau Pelanggan.
class ResetPassword {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  Future<Result<String>> call({
    required String token,
    required String newPassword,
    AuthPortal portal = AuthPortal.admin,
  }) {
    return _repository.resetPassword(
      token: token,
      newPassword: newPassword,
      portal: portal,
    );
  }
}

/// Mengambil user aktif dari token dan peran yang tersimpan.
class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call() => _repository.restoreSession();
}

/// Logout lokal.
class Logout {
  const Logout(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}
