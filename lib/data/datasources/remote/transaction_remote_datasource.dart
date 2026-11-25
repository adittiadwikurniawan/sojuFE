// lib/data/datasources/remote/transaction_remote_datasource.dart
//
// Implementasi remote datasource transaksi di atas ApiClient.
// Endpoint: `GET /api/v1/transactions`

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/transaction_datasource.dart';

class TransactionRemoteDataSource implements TransactionDataSource {
  const TransactionRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchTransactionsRaw({
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['tanggal_mulai'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['tanggal_selesai'] = endDate;
    }

    final ApiResponse response;
    try {
      response = await _apiClient.get(
        '/api/v1/transactions',
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
