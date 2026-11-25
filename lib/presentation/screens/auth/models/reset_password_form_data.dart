import 'package:flutter/foundation.dart';

import '../../../../domain/entities/auth_session_entity.dart';

/// Isian formulir pengaturan ulang password menggunakan token satu kali pakai.
@immutable
class ResetPasswordFormData {
  const ResetPasswordFormData({
    required this.token,
    required this.newPassword,
    required this.passwordConfirmation,
    this.portal = AuthPortal.admin,
  });

  final String token;
  final String newPassword;
  final String passwordConfirmation;
  final AuthPortal portal;
}
