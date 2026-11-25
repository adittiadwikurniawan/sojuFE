// lib/data/datasources/interfaces/sales_chat_datasource.dart
//
// Kontrak sumber data prototype chat penjualan harian/shift.
//
// Phase A hanya memakai mock lokal. Tidak ada endpoint AI `/add` atau `/ask`
// yang dipanggil karena kontraknya belum tersedia.

/// Sumber data mentah draft chat penjualan.
abstract interface class SalesChatDataSource {
  /// Mengembalikan envelope `{success, data, message?}`.
  ///
  /// `data == null` berarti input belum bisa dipetakan menjadi draft pada
  /// mode demo. Implementasi mock tidak melakukan request jaringan.
  Future<Map<String, Object?>> parseRecapRaw(String input);
}
