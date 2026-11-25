// lib/data/datasources/remote/customer_order_remote_datasource.dart
//
// Implementasi CustomerOrderDataSource di atas ApiClient:
// - `POST /api/customer/checkout`
// - `GET /api/customer/pesanan`
// - `GET /api/customer/pesanan/:id`

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/customer_order_datasource.dart';

class CustomerOrderRemoteDataSource implements CustomerOrderDataSource {
  const CustomerOrderRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> checkout(Map<String, Object?> payload) {
    return _map(
      _apiClient.post(
        '/api/customer/checkout',
        body: payload,
      ),
    );
  }

  @override
  Future<Map<String, Object?>> fetchOrders() {
    return _map(_apiClient.get('/api/customer/pesanan'));
  }

  @override
  Future<Map<String, Object?>> fetchOrderDetail(int id) {
    return _map(_apiClient.get('/api/customer/pesanan/$id'));
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
