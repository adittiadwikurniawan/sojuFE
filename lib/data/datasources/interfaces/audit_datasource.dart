// lib/data/datasources/interfaces/audit_datasource.dart
//
// Kontrak datasource audit.
//
// Datasource mengembalikan map JSON mentah (hasil decode, sesuai bentuk
// respons API) agar implementasi mock dan remote (Phase B) identik;
// penguraian envelope/model dilakukan repository.

import '../../../domain/entities/audit_log_entity.dart';

/// Sumber data mentah log audit.
abstract interface class AuditDataSource {
  /// Mengembalikan map envelope `{success, data, message?}` untuk
  /// `GET /api/v1/audit-log`.
  Future<Map<String, Object?>> fetchRawAuditLogs({
    required AuditLogQuery query,
  });
}
