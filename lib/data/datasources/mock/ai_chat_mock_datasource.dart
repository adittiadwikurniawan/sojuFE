// lib/data/datasources/mock/ai_chat_mock_datasource.dart
//
// Fallback ringan untuk pengujian router tanpa konfigurasi API live.
// Aplikasi produksi selalu memakai `AiChatRemoteDataSource` melalui
// `DataProviders.configure(...)`.

import '../interfaces/ai_chat_datasource.dart';

class AiChatMockDataSource implements AiChatDataSource {
  const AiChatMockDataSource();

  @override
  Future<Map<String, Object?>> fetchConversationsRaw({int? limit}) async {
    return <String, Object?>{
      'success': true,
      'data': <Object?>[],
    };
  }

  @override
  Future<Map<String, Object?>> fetchConversationDetailRaw(
    int conversationId,
  ) async {
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'id': conversationId,
        'title': 'Percakapan AI SOJU',
        'messages': <Object?>[],
      },
    };
  }

  @override
  Future<Map<String, Object?>> sendChatMessageRaw({
    required String message,
    int? conversationId,
  }) async {
    final int id = conversationId ?? 1;
    final String now = DateTime.now().toIso8601String();
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'conversationId': id,
        'title': message,
        'routePath': 'REFUSAL',
        'reply': 'Informasi tidak ditemukan dalam basis pengetahuan SOJU.',
        'citations': <Object?>[],
        'actions': <Object?>[],
        'userMessage': <String, Object?>{
          'id': 1,
          'conversationId': id,
          'role': 'USER',
          'content': message,
          'routePath': null,
          'citations': <Object?>[],
          'actions': <Object?>[],
          'createdAt': now,
        },
        'assistantMessage': <String, Object?>{
          'id': 2,
          'conversationId': id,
          'role': 'ASSISTANT',
          'content': 'Informasi tidak ditemukan dalam basis pengetahuan SOJU.',
          'routePath': 'REFUSAL',
          'citations': <Object?>[],
          'actions': <Object?>[],
          'createdAt': now,
        },
      },
    };
  }

  @override
  Future<Map<String, Object?>> confirmDraftTransactionRaw(
    Map<String, Object?> payload, {
    String endpoint = '/api/v1/transactions',
  }) async {
    if (endpoint.trim() == '/api/v1/products') {
      return <String, Object?>{
        'success': true,
        'message': 'Produk berhasil ditambahkan ke katalog.',
        'data': <String, Object?>{
          'id': 1,
          'kode': payload['kode'] ?? 'PRD000001',
          'namaBarang': payload['namaBarang'] ?? payload['nama_barang'] ?? 'Produk Baru',
          'hargaDefault': payload['hargaDefault'] ?? payload['harga_default'] ?? 0,
        },
      };
    }
    return <String, Object?>{
      'success': true,
      'message': 'Transaksi berhasil dicatat.',
      'data': <String, Object?>{
        'id': 1,
        'kode': 'PJL001-00001',
        'namaTransaksi': payload['nama_transaksi'] ?? 'Penjualan',
        'nominal': payload['nominal'] ?? 0,
      },
    };
  }

  @override
  Future<Map<String, Object?>> triggerReindexRaw() async {
    return <String, Object?>{
      'success': true,
      'message': 'Reindex basis pengetahuan AI berhasil dijalankan',
      'data': <String, Object?>{
        'documentsProcessed': 0,
        'chunksCreated': 0,
        'piiRedactedChunks': 0,
        'sources': <String, Object?>{
          'documents': 0,
          'products': 0,
          'cms': 0,
        },
      },
    };
  }
}
