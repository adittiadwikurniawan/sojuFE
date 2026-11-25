// lib/data/datasources/interfaces/free_table_datasource.dart
//
// Kontrak datasource Tabel Bebas.
//
// Datasource mengembalikan map JSON mentah berbentuk envelope
// `{success, data, message?}` agar mock Phase A dan remote Phase B memakai
// jalur parsing repository yang sama.

import '../../../domain/entities/free_table_entity.dart';

/// Sumber data mentah pembuatan kategori Tabel Bebas.
abstract interface class FreeTableDataSource {
  /// Mengirim draf kategori dan mengembalikan envelope respons.
  Future<Map<String, Object?>> createRawCategory({
    required FreeTableCategoryDraft draft,
  });
}
