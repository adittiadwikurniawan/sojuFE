// lib/data/repositories/audit_repository_impl.dart
//
// Implementasi repository audit.
//
// Memilih sumber data mentah (mock Phase A / REST Phase B), mengurai envelope
// `{success, data, message?}`, memetakan DTO ke entity domain, dan memetakan
// kegagalan ke `Result` (lihat `ARCHITECTURE.md` §2.5 dan §2.8).

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/repositories/audit_repository.dart';
import '../datasources/interfaces/audit_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/audit/audit_log_model.dart';

/// Repository audit di atas [AuditDataSource].
class AuditRepositoryImpl implements AuditLogRepository {
  const AuditRepositoryImpl(this._dataSource);

  final AuditDataSource _dataSource;

  @override
  Future<Result<AuditLogPageEntity>> fetchAuditLogs({
    required AuditLogQuery query,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchRawAuditLogs(
        query: query,
      );
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Respon audit-log tidak valid.',
          ),
        );
      }
      final AuditLogPageModel page = AuditLogPageModel.fromJson(envelope.data);
      return Result.success(page.toEntity());
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      // Kegagalan tak terduga (termasuk transport pada Phase B).
      return Result.failure(const NetworkFailure());
    }
  }
}
