// lib/data/datasources/interfaces/storefront_datasource.dart
//
// Kontrak sumber data mentah etalase Pelanggan. Mengembalikan envelope
// `{success, data, message?}` mentah; melempar `AppFailure` untuk kegagalan
// transport/HTTP.

/// Sumber data katalog publik dan keranjang.
abstract interface class StorefrontDataSource {
  Future<Map<String, Object?>> fetchRawCatalog({String? search});

  Future<Map<String, Object?>> fetchRawCart();

  Future<Map<String, Object?>> saveRawCart(List<Map<String, Object?>> items);
}
