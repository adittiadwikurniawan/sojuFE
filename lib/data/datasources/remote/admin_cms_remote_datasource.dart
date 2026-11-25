// lib/data/datasources/remote/admin_cms_remote_datasource.dart
//
// Remote datasource Konten CMS (`/api/v1/cms/content`) & Produk (`/api/v1/products`).

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../../../domain/entities/admin_cms_entity.dart';
import '../interfaces/admin_cms_datasource.dart';

class AdminCmsRemoteDataSource implements AdminCmsDataSource {
  const AdminCmsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchCmsContentsRaw() {
    return _map(_apiClient.get('/api/v1/cms/content'));
  }

  @override
  Future<Map<String, Object?>> saveCmsContentRaw({
    required CmsContentDraft draft,
    required bool isCreate,
  }) {
    final Map<String, Object?> payload = <String, Object?>{
      'key': draft.key,
      'judul': draft.title,
      'subJudul': draft.subtitle,
      'konten': draft.content,
      'aktif': draft.isActive,
    };
    if (isCreate) {
      return _map(_apiClient.post('/api/v1/cms/content', body: payload));
    }
    final String encodedKey = Uri.encodeComponent(draft.key);
    return _map(
      _apiClient.put('/api/v1/cms/content/$encodedKey', body: payload),
    );
  }

  @override
  Future<Map<String, Object?>> deleteCmsContentRaw({required String key}) {
    final String encodedKey = Uri.encodeComponent(key);
    return _map(_apiClient.delete('/api/v1/cms/content/$encodedKey'));
  }

  @override
  Future<Map<String, Object?>> fetchProductsRaw({String? search}) {
    final Map<String, String>? query =
        search != null && search.trim().isNotEmpty
            ? <String, String>{'search': search.trim()}
            : null;
    return _map(_apiClient.get('/api/v1/products', queryParameters: query));
  }

  @override
  Future<Map<String, Object?>> createProductRaw({
    required AdminProductDraft draft,
  }) {
    return _map(
      _apiClient.post(
        '/api/v1/products',
        body: <String, Object?>{
          'kode': draft.code,
          'namaBarang': draft.name,
          'varian': draft.variant,
          'satuan': draft.unit,
          'hargaDefault': draft.price,
          'deskripsi': draft.description,
          if (draft.imageUrl != null && draft.imageUrl!.trim().isNotEmpty)
            'gambarUrl': draft.imageUrl!.trim(),
          'aktif': draft.isActive,
        },
      ),
    );
  }

  @override
  Future<Map<String, Object?>> updateProductRaw({
    required int id,
    required AdminProductDraft draft,
  }) {
    return _map(
      _apiClient.put(
        '/api/v1/products/$id',
        body: <String, Object?>{
          'kode': draft.code,
          'namaBarang': draft.name,
          'varian': draft.variant,
          'satuan': draft.unit,
          'hargaDefault': draft.price,
          'deskripsi': draft.description,
          if (draft.imageUrl != null) 'gambarUrl': draft.imageUrl!.trim(),
          'aktif': draft.isActive,
        },
      ),
    );
  }

  @override
  Future<Map<String, Object?>> deleteProductRaw({required int id}) {
    return _map(_apiClient.delete('/api/v1/products/$id'));
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
    if (response.statusCode == 403) {
      throw ServerFailure(
        statusCode: 403,
        message: text ?? 'Akses khusus Super Admin diperlukan.',
      );
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
