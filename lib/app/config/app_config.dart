/// Konfigurasi environment aplikasi.
///
/// Base URL API di-inject saat build (lihat `ARCHITECTURE.md` §2.6):
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.contoh.com
/// ```
/// Token TIDAK boleh disimpan di sini maupun di source code.
class AppConfig {
  const AppConfig._();

  /// Base URL REST API. Kosong berarti belum dikonfigurasi (Phase A / mock).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Apakah base URL API sudah tersedia.
  static bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;
}
