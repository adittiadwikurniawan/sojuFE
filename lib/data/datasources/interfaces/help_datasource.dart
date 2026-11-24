// lib/data/datasources/interfaces/help_datasource.dart
//
// Kontrak datasource Pusat Bantuan.

/// Sumber data mentah topik dan artikel bantuan.
abstract interface class HelpDataSource {
  Future<Map<String, Object?>> fetchTopicsRaw();

  Future<Map<String, Object?>> fetchArticleRaw(String id);
}
