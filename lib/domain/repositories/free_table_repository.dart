// lib/domain/repositories/free_table_repository.dart
//
// Kontrak repository Tabel Bebas untuk form "Buat Kategori Baru".
//
// Phase A memakai datasource mock; Phase B cukup mengganti datasource di
// `data/data_providers.dart` tanpa mengubah usecase, provider, atau UI.

import '../../../core/common/result.dart';
import '../entities/free_table_entity.dart';

/// Repository pembuatan kategori Tabel Bebas.
abstract interface class FreeTableRepository {
  /// Mengirim [draft] ke datasource dan mengembalikan kategori yang dibuat.
  Future<Result<FreeTableCategoryEntity>> createCategory({
    required FreeTableCategoryDraft draft,
  });
}
