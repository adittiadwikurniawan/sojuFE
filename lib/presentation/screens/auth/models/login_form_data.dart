import 'package:flutter/foundation.dart';

/// Isian formulir masuk (frame `546:1497`).
///
/// Kontrak antara UI dan lapisan data: layar hanya mengumpulkan isian,
/// sedangkan pemanggilan API dilakukan oleh pemilik
/// [LoginScreen.onSubmit].
@immutable
class LoginFormData {
  const LoginFormData({required this.email, required this.password});

  final String email;
  final String password;
}
