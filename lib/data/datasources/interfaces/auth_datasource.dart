// lib/data/datasources/interfaces/auth_datasource.dart
//
// Kontrak datasource auth lintas peran (Admin/Super Admin dan Pelanggan).
//
// Datasource mengembalikan map JSON mentah berbentuk envelope
// `{success, data, message?}` agar parsing envelope dan pemetaan kegagalan
// tetap berada di repository.

/// Sumber data mentah autentikasi.
abstract interface class AuthDataSource {
  /// Login Admin / Super Admin (`POST /api/v1/auth/login`).
  Future<Map<String, Object?>> loginAdminRaw({
    required String email,
    required String password,
  });

  /// Login Pelanggan (`POST /api/customer/auth/masuk`).
  Future<Map<String, Object?>> loginCustomerRaw({
    required String email,
    required String password,
  });

  /// Pendaftaran akun Pelanggan (`POST /api/customer/auth/daftar`).
  Future<Map<String, Object?>> registerCustomerRaw({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  });

  /// Permintaan tautan reset password Admin (`POST /api/v1/auth/forgot-password`).
  Future<Map<String, Object?>> forgotPasswordAdminRaw({
    required String email,
  });

  /// Permintaan tautan reset password Pelanggan (`POST /api/customer/auth/lupa-password`).
  Future<Map<String, Object?>> forgotPasswordCustomerRaw({
    required String email,
  });

  /// Reset password Admin dengan token (`POST /api/v1/auth/reset-password`).
  Future<Map<String, Object?>> resetPasswordAdminRaw({
    required String token,
    required String newPassword,
  });

  /// Reset password Pelanggan dengan token (`POST /api/customer/auth/reset-password`).
  Future<Map<String, Object?>> resetPasswordCustomerRaw({
    required String token,
    required String newPassword,
  });

  /// Profil sesi Admin/Super Admin (`GET /api/v1/auth/me`).
  Future<Map<String, Object?>> meAdminRaw();

  /// Profil sesi Pelanggan (`GET /api/customer/profil`).
  Future<Map<String, Object?>> meCustomerRaw();
}
