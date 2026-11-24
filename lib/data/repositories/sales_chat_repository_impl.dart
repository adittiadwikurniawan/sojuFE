// lib/data/repositories/sales_chat_repository_impl.dart
//
// Implementasi repository prototype chat penjualan.
//
// Memilih datasource mock Phase A, mengurai envelope `{success, data,
// message?}`, memetakan DTO ke entity domain, dan mengembalikan `Result`.
// Tidak ada request jaringan pada prototype ini.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/sales_chat_entity.dart';
import '../../domain/repositories/sales_chat_repository.dart';
import '../datasources/interfaces/sales_chat_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/sales_chat/sales_chat_draft_model.dart';

/// Repository draft chat penjualan di atas [SalesChatDataSource].
class SalesChatRepositoryImpl implements SalesChatRepository {
  const SalesChatRepositoryImpl(this._dataSource);

  final SalesChatDataSource _dataSource;

  @override
  Future<Result<SalesChatDraft?>> parseRecap(String input) async {
    try {
      final Map<String, Object?> raw = await _dataSource.parseRecapRaw(input);
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Draft penjualan tidak tersedia.',
          ),
        );
      }
      if (envelope.data == null) {
        return Result.success(null);
      }
      final SalesChatDraftModel model =
          SalesChatDraftModel.fromJson(envelope.data);
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
