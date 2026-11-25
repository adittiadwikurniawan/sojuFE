// lib/data/repositories/free_table_repository_impl.dart
//
// Implementasi repository Tabel Bebas.
//
// Mengurai envelope `{success, data, message?}`, memetakan DTO ke entity
// domain, dan memetakan kegagalan ke `Result` (ARCHITECTURE.md §2.5/§2.8).

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/free_table_entity.dart';
import '../../domain/repositories/free_table_repository.dart';
import '../datasources/interfaces/free_table_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/free_table/free_table_category_model.dart';

/// Repository Tabel Bebas di atas [FreeTableDataSource].
class FreeTableRepositoryImpl implements FreeTableRepository {
  const FreeTableRepositoryImpl(this._dataSource);

  final FreeTableDataSource _dataSource;

  @override
  Future<Result<FreeTableCategoryEntity>> createCategory({
    required FreeTableCategoryDraft draft,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.createRawCategory(
        draft: draft,
      );
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Respon kategori tidak valid.',
          ),
        );
      }
      final FreeTableCategoryModel model =
          FreeTableCategoryModel.fromJson(envelope.data);
      return Result.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }
}
