// lib/data/datasources/remote/admin_order_remote_datasource.dart
//
// Remote datasource pesanan pelanggan untuk admin:
// - `GET /api/v1/customer-orders`
// - `PATCH /api/v1/customer-orders/:id/status`

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/admin_order_datasource.dart';

class AdminOrderRemoteDataSource implements AdminOrderDataSource {
  const AdminOrderRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchOrdersRaw({String? status}) {
    final Map<String, String>? query =
        status != null && status.isNotEmpty ? <String, String>{'status': status} : null;
    return _map(
      _apiClient.get('/api/v1/customer-orders', queryParameters: query),
    );
  }

  @override
  Future<Map<String, Object?>> updateOrderStatusRaw({
    required int id,
    required String status,
  }) {
    return _map(
      _apiClient.patch(
        '/api/v1/customer-orders/$id/status',
        body: <String, Object?>{'status': status},
      ),
    );
  }

  Future<Map<String, Object?>> _map(Future<ApiResponse> request) async {
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
