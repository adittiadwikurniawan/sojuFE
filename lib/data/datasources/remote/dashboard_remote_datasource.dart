// lib/data/datasources/remote/dashboard_remote_datasource.dart
//
// Implementasi remote datasource dashboard di atas ApiClient.
// Endpoints:
// - `GET /api/v1/dashboard/summary`
// - `GET /api/v1/dashboard/grafik-kas`
// - `GET /api/v1/dashboard/aktivitas-terbaru`

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/dashboard_datasource.dart';

class DashboardRemoteDataSource implements DashboardDataSource {
  const DashboardRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchSummary({String period = '7d'}) async {
    return _asMap(
      _apiClient.get(
        '/api/v1/dashboard/summary',
        queryParameters: <String, String>{'periode': period},
      ),
    );
  }

  @override
  Future<Map<String, Object?>> fetchCashChart({String period = '7d'}) async {
    return _asMap(
      _apiClient.get(
        '/api/v1/dashboard/grafik-kas',
        queryParameters: <String, String>{'periode': period},
      ),
    );
  }

  @override
  Future<List<Map<String, Object?>>> fetchRecentActivities({
    int limit = 5,
  }) async {
    final ApiResponse response;
    try {
      response = await _apiClient.get(
        '/api/v1/dashboard/aktivitas-terbaru',
        queryParameters: <String, String>{'limit': limit.toString()},
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }

    if (response.statusCode == 401) {
      throw const UnauthorizedFailure();
    }
    if (!response.isSuccess) {
      throw ServerFailure(statusCode: response.statusCode);
    }

    final Object? raw = response.body;
    final Object? data = raw is Map ? raw['data'] : null;
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (Map m) => <String, Object?>{
              for (final MapEntry<Object?, Object?> e in m.entries)
                e.key.toString(): e.value,
            },
          )
          .toList();
    }
    return <Map<String, Object?>>[];
  }

  Future<Map<String, Object?>> _asMap(Future<ApiResponse> request) async {
    final ApiResponse response;
    try {
      response = await request;
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
