import 'package:flutter/foundation.dart';

import '../../../../domain/entities/auth_session_entity.dart';

/// Isian formulir masuk (frame `546:1497`) untuk Admin maupun Pelanggan.
///
/// Kontrak antara UI dan lapisan data: layar hanya mengumpulkan isian,
/// sedangkan pemanggilan API dilakukan oleh pemilik [LoginScreen.onSubmit].
@immutable
class LoginFormData {
  const LoginFormData({
    required this.email,
    required this.password,
    this.portal = AuthPortal.admin,
  });

  final String email;
  final String password;
  final AuthPortal portal;
}
