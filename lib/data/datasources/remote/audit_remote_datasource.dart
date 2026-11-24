// lib/data/datasources/remote/audit_remote_datasource.dart
//
// Implementasi AuditDataSource di atas ApiClient (REST Phase B).
// Endpoint: `GET /api/v1/audit-log`.

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../../../domain/entities/audit_log_entity.dart';
import '../interfaces/audit_datasource.dart';

/// Datasource audit log via REST API.
class AuditRemoteDataSource implements AuditDataSource {
  const AuditRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchRawAuditLogs({
    required AuditLogQuery query,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'page': query.page.toString(),
    };

    if (query.startDate != null && query.endDate != null) {
      final DateTime start = query.startDate!;
      final DateTime end = query.endDate!;
      queryParams['dateFrom'] =
          '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      queryParams['dateTo'] =
          '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    } else if (query.days != null) {
      queryParams['days'] = query.days.toString();
    } else {
      queryParams['days'] = 'all';
    }

    final ApiResponse response;
    try {
      response = await _apiClient.get(
        '/api/v1/audit-log',
        queryParameters: queryParams,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }

    final Object? raw = response.body;
    final Map<String, Object?>? body = raw is Map
        ? <String, Object?>{
            for (final MapEntry<Object?, Object?> e in raw.entries)
              e.key.toString(): e.value,
          }
        : null;

    final Object? message = body?['message'];
    final String? text =
        message is String && message.trim().isNotEmpty ? message.trim() : null;

    if (response.statusCode == 401) {
      throw UnauthorizedFailure(message: text);
    }
    if (!response.isSuccess) {
      throw ServerFailure(statusCode: response.statusCode, message: text);
    }
    if (body == null) {
      throw const ParsingFailure();
    }

    return body;
  }
}
