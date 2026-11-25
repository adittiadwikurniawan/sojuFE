// lib/domain/entities/ai_chat_entity.dart
//
// Entitas domain untuk fitur Hybrid RAG AI Admin (`/api/v1/ai/*`).

import 'package:flutter/foundation.dart';

/// Jalur routing Hybrid RAG yang dikembalikan backend (`AiRoutePath`).
enum AiRoutePath {
  sqlTool('SQL_TOOL'),
  vectorRag('VECTOR_RAG'),
  actionDraft('ACTION_DRAFT'),
  refusal('REFUSAL'),
  unknown('UNKNOWN');

  const AiRoutePath(this.raw);

  final String raw;

  static AiRoutePath fromRaw(String? value) {
    final String normalized = (value ?? '').trim().toUpperCase();
    for (final AiRoutePath path in AiRoutePath.values) {
      if (path.raw == normalized) {
        return path;
      }
    }
    return AiRoutePath.unknown;
  }

  /// Label ringkas Bahasa Indonesia untuk badge jalur jawaban AI.
  String get labelId {
    switch (this) {
      case AiRoutePath.sqlTool:
        return 'Data Langsung';
      case AiRoutePath.vectorRag:
        return 'Basis Pengetahuan';
      case AiRoutePath.actionDraft:
        return 'Draft Transaksi';
      case AiRoutePath.refusal:
        return 'Di Luar Dokumen';
      case AiRoutePath.unknown:
        return 'Asisten AI';
    }
  }
}

/// Pengirim pesan dalam percakapan AI.
enum AiMessageAuthor {
  user('USER'),
  assistant('ASSISTANT'),
  system('SYSTEM');

  const AiMessageAuthor(this.raw);

  final String raw;

  static AiMessageAuthor fromRaw(String? value) {
    final String normalized = (value ?? '').trim().toUpperCase();
    switch (normalized) {
      case 'USER':
        return AiMessageAuthor.user;
      case 'SYSTEM':
        return AiMessageAuthor.system;
      case 'ASSISTANT':
      default:
        return AiMessageAuthor.assistant;
    }
  }
}

/// Sitasi sumber jawaban AI (dokumen vektor `[D1]` atau query SQL `[SQL-1]`).
@immutable
class AiCitation {
  const AiCitation({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.excerpt,
    this.sourceRef,
    this.roleScope,
    this.score,
    this.toolName,
    this.executedAt,
  });

  /// ID sitasi deterministik, mis. `D1` atau `SQL-1`.
  final String id;

  /// Judul dokumen (`title`) atau label tool SQL (`label`).
  final String title;

  /// Tipe sumber, mis. `SOP`, `FAQ`, `MANUAL`, `PRODUK`, `CMS`, `SQL_TOOL`.
  final String sourceType;

  /// Cuplikan konten (`snippet`) atau ringkasan query (`querySummary`).
  final String excerpt;

  final String? sourceRef;
  final String? roleScope;
  final double? score;
  final String? toolName;
  final DateTime? executedAt;

  bool get isSqlTool => sourceType.toUpperCase() == 'SQL_TOOL';

  String get chipLabel => '[$id]';

  String get sourceTypeLabel {
    switch (sourceType.toUpperCase()) {
      case 'SQL_TOOL':
        return 'Data SQL';
      case 'SOP':
        return 'SOP';
      case 'FAQ':
        return 'FAQ';
      case 'MANUAL':
        return 'Panduan';
      case 'PRODUK':
      case 'PRODUCT':
        return 'Produk';
      case 'CMS':
        return 'CMS';
      default:
        return sourceType.isEmpty ? 'Dokumen' : sourceType;
    }
  }
}

/// Baris ringkasan key-value pada draft aksi AI.
@immutable
class AiDraftSummaryRow {
  const AiDraftSummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

/// Rincian item baris menu pada draft aksi AI.
@immutable
class AiDraftLineItem {
  const AiDraftLineItem({
    this.produkId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.subtotal,
    required this.method,
  });

  final int? produkId;
  final String name;
  final int quantity;
  final String unit;
  final int unitPrice;
  final int subtotal;

  /// `'QRIS'` atau `'CASH'`.
  final String method;
}

/// Draft aksi terstruktur yang dikembalikan Path C (`ACTION_DRAFT`).
///
/// Selalu mensyaratkan konfirmasi manual pengguna sebelum memanggil
/// `POST /api/v1/transactions`.
@immutable
class AiActionDraft {
  const AiActionDraft({
    required this.id,
    required this.type,
    required this.intent,
    required this.requiresConfirmation,
    required this.endpoint,
    required this.method,
    required this.title,
    required this.sheet,
    required this.summaryRows,
    required this.total,
    required this.totalAmount,
    required this.badge,
    required this.dateLabel,
    required this.shiftLabel,
    required this.totalLabel,
    required this.breakdownTitle,
    required this.items,
    required this.confirmLabel,
    required this.correctLabel,
    required this.note,
    required this.payload,
    required this.isReadyToConfirm,
    required this.missingFields,
  });

  final String id;
  final String type;
  final String intent;
  final bool requiresConfirmation;
  final String endpoint;
  final String method;
  final String title;
  final String sheet;
  final List<AiDraftSummaryRow> summaryRows;
  final String total;
  final int totalAmount;
  final String badge;
  final String dateLabel;
  final String shiftLabel;
  final String totalLabel;
  final String breakdownTitle;
  final List<AiDraftLineItem> items;
  final String confirmLabel;
  final String correctLabel;
  final String note;

  /// Payload transaksi siap kirim ke `POST /api/v1/transactions`.
  final Map<String, Object?> payload;
  final bool isReadyToConfirm;
  final List<String> missingFields;
}

/// Satu pesan tersimpan dalam percakapan AI.
@immutable
class AiMessage {
  const AiMessage({
    required this.id,
    required this.conversationId,
    required this.author,
    required this.content,
    this.routePath,
    this.citations = const <AiCitation>[],
    this.actions = const <AiActionDraft>[],
    this.createdAt,
  });

  final int id;
  final int conversationId;
  final AiMessageAuthor author;
  final String content;
  final AiRoutePath? routePath;
  final List<AiCitation> citations;
  final List<AiActionDraft> actions;
  final DateTime? createdAt;
}

/// Ringkasan satu percakapan untuk daftar riwayat (`GET /api/v1/ai/conversations`).
@immutable
class AiConversationSummary {
  const AiConversationSummary({
    required this.id,
    required this.title,
    required this.messageCount,
    this.lastMessagePreview,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final int messageCount;
  final String? lastMessagePreview;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// Detail lengkap percakapan AI beserta seluruh pesan (`GET /api/v1/ai/conversations/:id`).
@immutable
class AiConversationDetail {
  const AiConversationDetail({
    required this.id,
    required this.title,
    required this.messages,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final List<AiMessage> messages;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// Hasil pengiriman pesan ke `POST /api/v1/ai/chat`.
@immutable
class AiChatReply {
  const AiChatReply({
    required this.conversationId,
    required this.title,
    required this.routePath,
    required this.reply,
    required this.citations,
    required this.actions,
    this.userMessage,
    this.assistantMessage,
  });

  final int conversationId;
  final String title;
  final AiRoutePath routePath;
  final String reply;
  final List<AiCitation> citations;
  final List<AiActionDraft> actions;
  final AiMessage? userMessage;
  final AiMessage? assistantMessage;
}

/// Hasil konfirmasi draft transaksi ke `POST /api/v1/transactions`.
@immutable
class AiConfirmedTransaction {
  const AiConfirmedTransaction({
    required this.id,
    required this.code,
    required this.name,
    required this.nominal,
    this.message,
  });

  final int id;
  final String code;
  final String name;
  final int nominal;
  final String? message;
}

/// Hasil reindex basis pengetahuan AI (`POST /api/v1/ai/reindex` — `SUPER_ADMIN` only).
@immutable
class AiReindexResult {
  const AiReindexResult({
    required this.documentsProcessed,
    required this.chunksCreated,
    required this.piiRedactedChunks,
    required this.documentsCount,
    required this.productsCount,
    required this.cmsCount,
    this.message,
  });

  final int documentsProcessed;
  final int chunksCreated;
  final int piiRedactedChunks;
  final int documentsCount;
  final int productsCount;
  final int cmsCount;
  final String? message;
}
