// lib/data/datasources/remote/storefront_remote_datasource.dart
//
// Implementasi StorefrontDataSource di atas ApiClient:
// - `GET /api/public/products` (tanpa autentikasi)
// - `GET/PUT /api/customer/keranjang` (Bearer token Pelanggan)

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/featured_products_datasource.dart';

/// Datasource REST etalase Pelanggan.
class StorefrontRemoteDataSource implements FeaturedProductsDataSource {
  const StorefrontRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchRawFeaturedContent() {
    return _map(
      _apiClient.get(
        '/api/public/cms/content/produk_unggulan',
        authenticated: false,
      ),
    );
  }

  @override
  Future<Map<String, Object?>> fetchRawCatalog({String? search}) {
    final String query = search?.trim() ?? '';
    return _map(
      _apiClient.get(
        '/api/public/products',
        authenticated: false,
        queryParameters:
            query.isEmpty ? null : <String, String>{'search': query},
      ),
    );
  }

  @override
  Future<Map<String, Object?>> fetchRawCart() {
    return _map(_apiClient.get('/api/customer/keranjang'));
  }

  @override
  Future<Map<String, Object?>> saveRawCart(List<Map<String, Object?>> items) {
    return _map(
      _apiClient.put(
        '/api/customer/keranjang',
        body: <String, Object?>{'items': items},
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
