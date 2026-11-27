// lib/data/datasources/interfaces/ai_chat_datasource.dart
//
// Kontrak datasource untuk Hybrid RAG AI (`/api/v1/ai/*`) dan konfirmasi
// draft transaksi (`POST /api/v1/transactions`).

abstract interface class AiChatDataSource {
  Future<Map<String, Object?>> fetchConversationsRaw({int? limit});

  Future<Map<String, Object?>> fetchConversationDetailRaw(int conversationId);

  Future<Map<String, Object?>> sendChatMessageRaw({
    required String message,
    int? conversationId,
  });

  Future<Map<String, Object?>> confirmDraftTransactionRaw(
    Map<String, Object?> payload, {
    String endpoint = '/api/v1/transactions',
  });

  Future<Map<String, Object?>> triggerReindexRaw();
}
