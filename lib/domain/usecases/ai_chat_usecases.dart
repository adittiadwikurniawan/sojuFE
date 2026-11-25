// lib/domain/usecases/ai_chat_usecases.dart
//
// Usecases untuk fitur Hybrid RAG AI Admin (`TASK-028`).

import '../../core/common/result.dart';
import '../entities/ai_chat_entity.dart';
import '../repositories/ai_chat_repository.dart';

/// Mengambil daftar riwayat percakapan AI milik pengguna yang sedang login.
class GetAiConversations {
  const GetAiConversations(this._repository);

  final AiChatRepository _repository;

  Future<Result<List<AiConversationSummary>>> call({int? limit}) {
    return _repository.fetchConversations(limit: limit);
  }
}

/// Mengambil detail percakapan AI berdasarkan ID.
class GetAiConversationDetail {
  const GetAiConversationDetail(this._repository);

  final AiChatRepository _repository;

  Future<Result<AiConversationDetail>> call(int conversationId) {
    return _repository.fetchConversationDetail(conversationId);
  }
}

/// Mengirim pesan chat ke endpoint Hybrid RAG `/api/v1/ai/chat`.
class SendAiChatMessage {
  const SendAiChatMessage(this._repository);

  final AiChatRepository _repository;

  Future<Result<AiChatReply>> call({
    required String message,
    int? conversationId,
  }) {
    return _repository.sendMessage(
      message: message,
      conversationId: conversationId,
    );
  }
}

/// Menyimpan draft transaksi yang telah dikonfirmasi pengguna ke `POST /api/v1/transactions`.
class ConfirmAiDraftTransaction {
  const ConfirmAiDraftTransaction(this._repository);

  final AiChatRepository _repository;

  Future<Result<AiConfirmedTransaction>> call(AiActionDraft draft) {
    return _repository.confirmDraftTransaction(draft);
  }
}

/// Memicu reindex basis pengetahuan AI (`SUPER_ADMIN` only).
class TriggerAiReindex {
  const TriggerAiReindex(this._repository);

  final AiChatRepository _repository;

  Future<Result<AiReindexResult>> call() {
    return _repository.triggerReindex();
  }
}
