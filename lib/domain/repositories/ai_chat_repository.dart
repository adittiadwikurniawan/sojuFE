// lib/domain/repositories/ai_chat_repository.dart
//
// Kontrak repository domain untuk Hybrid RAG AI Admin (`/api/v1/ai/*`)
// serta konfirmasi draft transaksi (`POST /api/v1/transactions`).

import '../../core/common/result.dart';
import '../entities/ai_chat_entity.dart';

abstract interface class AiChatRepository {
  /// Mengambil daftar riwayat percakapan milik admin yang sedang login.
  Future<Result<List<AiConversationSummary>>> fetchConversations({int? limit});

  /// Mengambil detail percakapan lengkap beserta pesan, sitasi, dan draft aksi.
  Future<Result<AiConversationDetail>> fetchConversationDetail(
    int conversationId,
  );

  /// Mengirim pesan ke Hybrid RAG AI (`POST /api/v1/ai/chat`).
  Future<Result<AiChatReply>> sendMessage({
    required String message,
    int? conversationId,
  });

  /// Mengonfirmasi draft transaksi secara eksplisit ke `POST /api/v1/transactions`.
  Future<Result<AiConfirmedTransaction>> confirmDraftTransaction(
    AiActionDraft draft,
  );

  /// Menjalankan reindex basis pengetahuan AI (`POST /api/v1/ai/reindex`, `SUPER_ADMIN` only).
  Future<Result<AiReindexResult>> triggerReindex();
}
