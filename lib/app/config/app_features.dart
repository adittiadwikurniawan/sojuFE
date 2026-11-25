/// Feature flag aplikasi.
///
/// Prototype AI chat penjualan **tidak aktif secara default** karena PRD
/// mobile masih menetapkan aplikasi baca-saja dan AI Assistant belum menjadi
/// fitur produksi. Aktifkan hanya untuk demo lokal:
///
/// ```
/// flutter run --dart-define=ENABLE_SALES_CHAT_PROTOTYPE=true
/// ```
class AppFeatures {
  const AppFeatures({this.salesChatPrototype = false});

  /// Menampilkan prototype chat input penjualan harian/shift.
  final bool salesChatPrototype;

  /// Nilai default build. Tanpa `--dart-define`, flag tetap `false`.
  static const AppFeatures fromEnvironment = AppFeatures(
    salesChatPrototype: bool.fromEnvironment('ENABLE_SALES_CHAT_PROTOTYPE'),
  );
}
