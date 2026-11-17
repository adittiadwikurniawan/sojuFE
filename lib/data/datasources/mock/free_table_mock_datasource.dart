// lib/data/datasources/mock/free_table_mock_datasource.dart
//
// Sumber data mock pembuatan kategori Tabel Bebas (Phase A).
//
// Mock tidak mengarang data bisnis baru: respons `data` adalah draf yang
// dikirim UI. Dengan begitu kontrak parsing envelope dan model yang sama
// dapat dipakai saat datasource diganti REST pada Phase B.

import '../../../domain/entities/free_table_entity.dart';
import '../interfaces/free_table_datasource.dart';

/// Mock datasource Tabel Bebas.
class FreeTableMockDataSource implements FreeTableDataSource {
  const FreeTableMockDataSource();

  @override
  Future<Map<String, Object?>> createRawCategory({
    required FreeTableCategoryDraft draft,
  }) async {
    return <String, Object?>{
      'success': true,
      'data': draft.toJson(),
    };
  }
}
