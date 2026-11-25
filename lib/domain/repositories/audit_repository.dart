// lib/domain/repositories/audit_repository.dart
//
// Kontrak repository audit (read-only).
//
// Implementasinya berganti antara mock (Phase A) dan REST
// `GET /api/v1/audit-log` (Phase B) tanpa mengubah presentation.

import '../../../core/common/result.dart';
import '../entities/audit_log_entity.dart';

/// Sumber data log audit untuk pembacaan.
abstract interface class AuditLogRepository {
  /// Membaca satu halaman log audit sesuai [query].
  Future<Result<AuditLogPageEntity>> fetchAuditLogs({
    required AuditLogQuery query,
  });
}
