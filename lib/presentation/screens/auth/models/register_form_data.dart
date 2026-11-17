import 'package:flutter/foundation.dart';

/// Isian formulir pendaftaran (frame `546:1547`).
///
/// Dipakai sebagai kontrak antara UI dan lapisan data: layar hanya
/// mengumpulkan isian, sedangkan pemanggilan API dilakukan oleh pemilik
/// [RegisterScreen.onSubmit].
@immutable
class RegisterFormData {
  const RegisterFormData({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.acceptedTerms,
  });

  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final bool acceptedTerms;
}
