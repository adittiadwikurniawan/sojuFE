import 'package:flutter/foundation.dart';

/// Konfigurasi environment aplikasi.
///
/// Base URL API di-inject saat build (lihat `ARCHITECTURE.md` §2.6):
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.contoh.com/api/v1
/// ```
/// Token TIDAK boleh disimpan di sini maupun di source code.
class AppConfig {
  const AppConfig._();

  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Menormalkan `API_BASE_URL` menjadi origin bersih tanpa trailing `/` atau `/api/v1`.
  ///
  /// Mendukung baik bentuk origin (`http://localhost:4000`) maupun bentuk
  /// berakhiran `/api/v1` (`http://localhost:4000/api/v1`).
  static String normalizeApiOrigin(String rawUrl) {
    String normalized = rawUrl.trim();
    if (normalized.isEmpty) {
      return '';
    }
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    if (normalized.endsWith('/api/v1')) {
      normalized =
          normalized.substring(0, normalized.length - '/api/v1'.length);
    }
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// Origin API tanpa prefix `/api/v1`.
  ///
  /// Tanpa `--dart-define`, nilai default menunjuk backend lokal:
  /// - Android emulator: `http://10.0.2.2:4000`
  /// - iOS simulator / desktop / web: `http://localhost:4000`
  ///
  /// Perangkat fisik wajib memakai `--dart-define` dengan IP LAN komputer.
  static String get apiOrigin {
    if (_configuredApiBaseUrl.isNotEmpty) {
      return normalizeApiOrigin(_configuredApiBaseUrl);
    }
    if (kIsWeb) {
      // Saat web dibuka dari HP lewat IP LAN, `localhost` akan menunjuk ke HP.
      // Turunkan host dari URL web supaya backend tetap di komputer yang sama.
      final Uri webBase = Uri.base;
      if (webBase.host.isNotEmpty) {
        final String scheme = webBase.scheme == 'https' ? 'https' : 'http';
        return '$scheme://${webBase.host}:4000';
      }
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  /// Base URL REST API, selalu berakhir dengan prefix `/api/v1`.
  static String get apiBaseUrl {
    final String origin = apiOrigin;
    if (origin.isEmpty) {
      return '';
    }
    return '$origin/api/v1';
  }

  /// Apakah base URL API sudah tersedia.
  static bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;

  /// OAuth Web Client ID untuk Google Sign-In dan verifikasi backend.
  ///
  /// Isi lewat:
  /// ```
  /// flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=...apps.googleusercontent.com
  /// ```
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// OAuth iOS Client ID untuk Google Sign-In di iOS.
  ///
  /// Isi lewat:
  /// ```
  /// flutter run --dart-define=GOOGLE_IOS_CLIENT_ID=...apps.googleusercontent.com
  /// ```
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );
}
