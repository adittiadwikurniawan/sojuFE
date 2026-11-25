// lib/data/datasources/remote/secure_token_storage.dart
//
// Adapter TokenStorage berbasis Keychain/Keystore melalui
// `flutter_secure_storage`. Token tidak pernah ditulis ke SharedPreferences.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/services/token_storage/token_storage.dart';

/// Penyimpanan token dan peran aman milik OS.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'soju_auth_token';
  static const String _roleKey = 'soju_auth_role';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _tokenKey);

  @override
  Future<void> write(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> readRole() => _storage.read(key: _roleKey);

  @override
  Future<void> writeRole(String role) {
    return _storage.write(key: _roleKey, value: role);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }
}
