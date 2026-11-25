// lib/domain/usecases/free_table_usecases.dart
//
// Usecase pembuatan kategori Tabel Bebas.

import '../../core/common/result.dart';
import '../entities/free_table_entity.dart';
import '../repositories/free_table_repository.dart';

/// Membuat kategori Tabel Bebas baru dari draf form.
class CreateFreeTableCategory {
  const CreateFreeTableCategory(this._repository);

  final FreeTableRepository _repository;

  Future<Result<FreeTableCategoryEntity>> call({
    required FreeTableCategoryDraft draft,
  }) {
    return _repository.createCategory(draft: draft);
  }
}
