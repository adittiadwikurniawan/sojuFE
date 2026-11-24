import 'package:flutter/foundation.dart';

/// Isian formulir pendaftaran akun Pelanggan (`/api/customer/auth/daftar`).
///
/// Dipakai sebagai kontrak antara UI dan lapisan data: layar hanya
/// mengumpulkan isian, sedangkan pemanggilan API dilakukan oleh pemilik
/// [RegisterScreen.onSubmit].
@immutable
class RegisterFormData {
  const RegisterFormData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.passwordConfirmation,
    required this.acceptedTerms,
    this.promotionAllowed = false,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final String password;
  final String passwordConfirmation;
  final bool acceptedTerms;
  final bool promotionAllowed;
}
