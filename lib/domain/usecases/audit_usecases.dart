// lib/domain/usecases/audit_usecases.dart
//
// Usecase baca audit.

import '../../core/common/result.dart';
import '../entities/audit_log_entity.dart';
import '../repositories/audit_repository.dart';

/// Membaca log audit satu halaman sesuai filter rentang waktu.
class GetAuditLogs {
  const GetAuditLogs(this._repository);

  final AuditLogRepository _repository;

  Future<Result<AuditLogPageEntity>> call({required AuditLogQuery query}) {
    return _repository.fetchAuditLogs(query: query);
  }
}
