// lib/data/data_providers.dart
//
// Titik pemilihan sumber data (mock Phase A / REST Phase B).
//
// Presentation hanya memakai usecase dari file ini. Saat backend tersedia,
// ganti `FreeTableMockDataSource` dengan datasource remote tanpa mengubah
// screen, provider, atau entity.

import '../domain/usecases/free_table_usecases.dart';
import 'datasources/mock/free_table_mock_datasource.dart';
import 'repositories/free_table_repository_impl.dart';

/// Factory dependency data tingkat aplikasi.
abstract final class DataProviders {
  /// Usecase pembuatan kategori Tabel Bebas (Phase A: mock).
  static CreateFreeTableCategory createFreeTableCategory() {
    return const CreateFreeTableCategory(
      FreeTableRepositoryImpl(FreeTableMockDataSource()),
    );
  }
}
