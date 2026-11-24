// lib/data/models/auth/auth_session_model.dart
//
// DTO sesi dari respons login Admin (`/api/v1/auth/login`) atau
// login/daftar Pelanggan (`/api/customer/auth/masuk`, `/api/customer/auth/daftar`):
// `{ token, user: { ... } }` atau `{ token, customer: { ... } }`.

import '../../../domain/entities/auth_session_entity.dart';
import 'auth_user_model.dart';

/// DTO sesi autentikasi.
class AuthSessionModel {
  const AuthSessionModel({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUserModel user;

  factory AuthSessionModel.fromJson(
    Object? raw, {
    UserRole? defaultRole,
  }) {
    final Map<String, Object?> json = _asMap(raw, 'data');
    final String? token = _asString(json['token']);
    if (token == null || token.isEmpty) {
      throw const FormatException('Field `token` tidak valid.');
    }

    final Object? customerPayload = json['customer'] ?? json['pelanggan'];
    if (customerPayload != null) {
      return AuthSessionModel(
        token: token,
        user: AuthUserModel.fromJson(
          customerPayload,
          defaultRole: UserRole.customer,
        ),
      );
    }

    return AuthSessionModel(
      token: token,
      user: AuthUserModel.fromJson(
        json['user'],
        defaultRole: defaultRole,
      ),
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      token: token,
      user: user.toEntity(),
    );
  }
}

Map<String, Object?> _asMap(Object? raw, String field) {
  if (raw is Map) {
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        entry.key.toString(): entry.value,
    };
  }
  throw FormatException('Field `$field` bukan objek JSON.');
}

String? _asString(Object? raw) {
  if (raw is String) {
    final String value = raw.trim();
    return value.isEmpty ? null : value;
  }
  return null;
}
