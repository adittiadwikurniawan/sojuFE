// lib/data/datasources/remote/ai_chat_remote_datasource.dart
//
// Remote datasource Hybrid RAG AI Admin:
// - `GET /api/v1/ai/conversations`
// - `GET /api/v1/ai/conversations/:id`
// - `POST /api/v1/ai/chat`
// - `POST /api/v1/ai/reindex` (`SUPER_ADMIN` only)
// - `POST /api/v1/transactions` (konfirmasi manual draft aksi)

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../interfaces/ai_chat_datasource.dart';

class AiChatRemoteDataSource implements AiChatDataSource {
  const AiChatRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchConversationsRaw({int? limit}) {
    final Map<String, String>? query = limit == null
        ? null
        : <String, String>{'limit': '$limit'};
    return _map(
      _apiClient.get('/api/v1/ai/conversations', queryParameters: query),
    );
  }

  @override
  Future<Map<String, Object?>> fetchConversationDetailRaw(int conversationId) {
    return _map(_apiClient.get('/api/v1/ai/conversations/$conversationId'));
  }

  @override
  Future<Map<String, Object?>> sendChatMessageRaw({
    required String message,
    int? conversationId,
  }) {
    final Map<String, Object?> body = <String, Object?>{
      'message': message.trim(),
      if (conversationId != null) 'conversationId': conversationId,
    };
    return _map(_apiClient.post('/api/v1/ai/chat', body: body));
  }

  @override
  Future<Map<String, Object?>> confirmDraftTransactionRaw(
    Map<String, Object?> payload,
  ) {
    final Map<String, Object?> body = Map<String, Object?>.of(payload)
      ..['sumber_input'] = 'AI'
      ..['sumberInput'] = 'AI';
    return _map(_apiClient.post('/api/v1/transactions', body: body));
  }

  @override
  Future<Map<String, Object?>> triggerReindexRaw() {
    return _map(_apiClient.post('/api/v1/ai/reindex'));
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

    final Object? body = response.body;
    final Map<String, Object?> map = body is Map<String, Object?>
        ? body
        : (body is Map
            ? body.map(
                (Object? k, Object? v) =>
                    MapEntry<String, Object?>(k.toString(), v),
              )
            : const <String, Object?>{});

    if (response.isSuccess) {
      return map;
    }

    final String? serverMessage = _extractErrorMessage(map);
    if (response.statusCode == 401) {
      throw UnauthorizedFailure(
        message:
            serverMessage ?? 'Sesi login telah berakhir. Silakan masuk ulang.',
      );
    }
    if (response.statusCode == 403) {
      throw ServerFailure(
        statusCode: 403,
        message: serverMessage ??
            'Anda tidak memiliki akses untuk fitur Asisten AI ini.',
      );
    }
    if (response.statusCode == 404) {
      throw ServerFailure(
        statusCode: 404,
        message: serverMessage ?? 'Percakapan atau sumber AI tidak ditemukan.',
      );
    }
    if (response.statusCode == 429) {
      throw ServerFailure(
        statusCode: 429,
        message: serverMessage ??
            'Terlalu banyak permintaan ke Asisten AI. Coba lagi sebentar lagi.',
      );
    }
    throw ServerFailure(
      statusCode: response.statusCode,
      message: serverMessage ??
          'Gagal terhubung ke layanan Asisten AI (${response.statusCode}).',
    );
  }

  String? _extractErrorMessage(Map<String, Object?> map) {
    final Object? raw = map['message'] ?? map['error'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }
}
