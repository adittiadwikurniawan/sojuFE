// lib/data/models/ai/ai_chat_models.dart
//
// DTO JSON untuk kontrak Hybrid RAG AI (`/api/v1/ai/*`) dan
// konfirmasi draft transaksi (`POST /api/v1/transactions`).

import '../../../domain/entities/ai_chat_entity.dart';

Map<String, Object?> _asMap(Object? raw) {
  if (raw is Map<String, Object?>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map(
      (Object? key, Object? value) => MapEntry<String, Object?>(
        key.toString(),
        value,
      ),
    );
  }
  return const <String, Object?>{};
}

List<Map<String, Object?>> _asMapList(Object? raw) {
  if (raw is! List) {
    return const <Map<String, Object?>>[];
  }
  return raw
      .whereType<Map<Object?, Object?>>()
      .map(_asMap)
      .toList(growable: false);
}

int _asInt(Object? raw, {int fallback = 0}) {
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  if (raw is String) {
    final int? parsedInt = int.tryParse(raw.trim());
    if (parsedInt != null) return parsedInt;
    final double? parsedDouble = double.tryParse(raw.trim());
    if (parsedDouble != null) return parsedDouble.round();
  }
  return fallback;
}

int? _asNullableInt(Object? raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  if (raw is String) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.round();
  }
  return null;
}

double? _asNullableDouble(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw.trim());
  return null;
}

String _asString(Object? raw, {String fallback = ''}) {
  if (raw == null) return fallback;
  final String value = raw.toString().trim();
  return value.isEmpty ? fallback : value;
}

String? _asNullableString(Object? raw) {
  if (raw == null) return null;
  final String value = raw.toString().trim();
  return value.isEmpty ? null : value;
}

DateTime? _asDateTime(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  return DateTime.tryParse(raw.toString());
}

/// DTO sitasi dokumen (`DocumentCitation`) maupun SQL (`SqlCitation`).
class AiCitationModel {
  const AiCitationModel({
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

  factory AiCitationModel.fromJson(Map<String, Object?> json) {
    final String sourceType = _asString(json['sourceType'], fallback: 'MANUAL');
    final bool isSql = sourceType.toUpperCase() == 'SQL_TOOL';
    final String title = isSql
        ? _asString(
            json['label'] ?? json['title'] ?? json['toolName'],
            fallback: 'Data Operasional',
          )
        : _asString(
            json['title'] ?? json['label'],
            fallback: 'Dokumen SOJU',
          );
    final String excerpt = isSql
        ? _asString(
            json['querySummary'] ?? json['snippet'],
            fallback: 'Ringkasan data operasional SOJU.',
          )
        : _asString(
            json['snippet'] ?? json['content'] ?? json['querySummary'],
            fallback: 'Cuplikan tidak tersedia.',
          );

    return AiCitationModel(
      id: _asString(json['id'], fallback: isSql ? 'SQL-1' : 'D1'),
      title: title,
      sourceType: sourceType,
      excerpt: excerpt,
      sourceRef: _asNullableString(json['sourceRef']),
      roleScope: _asNullableString(json['roleScope']),
      score: _asNullableDouble(json['score']),
      toolName: _asNullableString(json['toolName']),
      executedAt: _asDateTime(json['executedAt']),
    );
  }

  final String id;
  final String title;
  final String sourceType;
  final String excerpt;
  final String? sourceRef;
  final String? roleScope;
  final double? score;
  final String? toolName;
  final DateTime? executedAt;

  AiCitation toEntity() {
    return AiCitation(
      id: id,
      title: title,
      sourceType: sourceType,
      excerpt: excerpt,
      sourceRef: sourceRef,
      roleScope: roleScope,
      score: score,
      toolName: toolName,
      executedAt: executedAt,
    );
  }
}

/// DTO baris ringkasan pada draft aksi AI.
class AiDraftSummaryRowModel {
  const AiDraftSummaryRowModel({
    required this.label,
    required this.value,
  });

  factory AiDraftSummaryRowModel.fromJson(Map<String, Object?> json) {
    return AiDraftSummaryRowModel(
      label: _asString(json['label']),
      value: _asString(json['value']),
    );
  }

  final String label;
  final String value;

  AiDraftSummaryRow toEntity() => AiDraftSummaryRow(label: label, value: value);
}

/// DTO baris item pada draft aksi AI.
class AiDraftLineItemModel {
  const AiDraftLineItemModel({
    this.produkId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.subtotal,
    required this.method,
  });

  factory AiDraftLineItemModel.fromJson(Map<String, Object?> json) {
    final int qty = _asInt(json['jumlah'] ?? json['quantity'], fallback: 1);
    final int unitPrice = _asInt(
      json['hargaSatuan'] ?? json['unitPrice'],
      fallback: 0,
    );
    final int subtotal = _asInt(
      json['subtotal'],
      fallback: qty * unitPrice,
    );

    return AiDraftLineItemModel(
      produkId: _asNullableInt(json['produkId']),
      name: _asString(json['nama'] ?? json['name'], fallback: 'Item'),
      quantity: qty,
      unit: _asString(json['satuan'] ?? json['unit'], fallback: 'porsi'),
      unitPrice: unitPrice,
      subtotal: subtotal,
      method: _asString(json['metode'] ?? json['method'], fallback: 'CASH')
          .toUpperCase(),
    );
  }

  final int? produkId;
  final String name;
  final int quantity;
  final String unit;
  final int unitPrice;
  final int subtotal;
  final String method;

  AiDraftLineItem toEntity() {
    return AiDraftLineItem(
      produkId: produkId,
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      subtotal: subtotal,
      method: method,
    );
  }
}

/// DTO draft aksi terstruktur dari backend Path C (`ActionDraft`).
class AiActionDraftModel {
  const AiActionDraftModel({
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

  factory AiActionDraftModel.fromJson(Map<String, Object?> json) {
    final List<AiDraftSummaryRowModel> summaryRows =
        _asMapList(json['summaryRows'])
            .map(AiDraftSummaryRowModel.fromJson)
            .toList(growable: false);
    final List<AiDraftLineItemModel> items = _asMapList(json['items'])
        .map(AiDraftLineItemModel.fromJson)
        .toList(growable: false);
    final Map<String, Object?> payload = _asMap(json['payload']);
    final List<String> missingFields = (json['missingFields'] is List)
        ? (json['missingFields'] as List<Object?>)
            .map((Object? e) => e?.toString().trim() ?? '')
            .where((String e) => e.isNotEmpty)
            .toList(growable: false)
        : const <String>[];

    final int totalAmount = _asInt(
      json['totalAmount'] ?? payload['nominal'],
      fallback: items.fold<int>(0, (int s, AiDraftLineItemModel i) => s + i.subtotal),
    );

    return AiActionDraftModel(
      id: _asString(json['id'], fallback: 'draft-${DateTime.now().millisecondsSinceEpoch}'),
      type: _asString(json['type'], fallback: 'CREATE_TRANSACTION'),
      intent: _asString(json['intent'], fallback: 'TRANSAKSI'),
      requiresConfirmation: json['requiresConfirmation'] is bool
          ? json['requiresConfirmation'] as bool
          : true,
      endpoint: _asString(json['endpoint'], fallback: '/api/v1/transactions'),
      method: _asString(json['method'], fallback: 'POST'),
      title: _asString(json['title'], fallback: 'Draft Transaksi'),
      sheet: _asString(json['sheet'], fallback: 'Transaksi'),
      summaryRows: summaryRows,
      total: _asString(json['total'], fallback: 'Rp $totalAmount'),
      totalAmount: totalAmount,
      badge: _asString(json['badge'], fallback: 'Belum disimpan'),
      dateLabel: _asString(json['dateLabel'], fallback: 'Hari ini'),
      shiftLabel: _asString(json['shiftLabel'], fallback: 'Draft AI'),
      totalLabel: _asString(json['totalLabel'], fallback: 'TOTAL TRANSAKSI'),
      breakdownTitle: _asString(
        json['breakdownTitle'],
        fallback: 'Rincian Transaksi',
      ),
      items: items,
      confirmLabel: _asString(
        json['confirmLabel'],
        fallback: 'Konfirmasi & Simpan',
      ),
      correctLabel: _asString(
        json['correctLabel'],
        fallback: 'Koreksi Jumlah / Harga',
      ),
      note: _asString(
        json['note'],
        fallback:
            'Draft ini belum disimpan. Periksa rincian lalu tekan Konfirmasi & Simpan.',
      ),
      payload: payload,
      isReadyToConfirm: json['isReadyToConfirm'] is bool
          ? json['isReadyToConfirm'] as bool
          : missingFields.isEmpty && totalAmount > 0,
      missingFields: missingFields,
    );
  }

  final String id;
  final String type;
  final String intent;
  final bool requiresConfirmation;
  final String endpoint;
  final String method;
  final String title;
  final String sheet;
  final List<AiDraftSummaryRowModel> summaryRows;
  final String total;
  final int totalAmount;
  final String badge;
  final String dateLabel;
  final String shiftLabel;
  final String totalLabel;
  final String breakdownTitle;
  final List<AiDraftLineItemModel> items;
  final String confirmLabel;
  final String correctLabel;
  final String note;
  final Map<String, Object?> payload;
  final bool isReadyToConfirm;
  final List<String> missingFields;

  AiActionDraft toEntity() {
    return AiActionDraft(
      id: id,
      type: type,
      intent: intent,
      requiresConfirmation: requiresConfirmation,
      endpoint: endpoint,
      method: method,
      title: title,
      sheet: sheet,
      summaryRows: summaryRows
          .map((AiDraftSummaryRowModel row) => row.toEntity())
          .toList(growable: false),
      total: total,
      totalAmount: totalAmount,
      badge: badge,
      dateLabel: dateLabel,
      shiftLabel: shiftLabel,
      totalLabel: totalLabel,
      breakdownTitle: breakdownTitle,
      items: items
          .map((AiDraftLineItemModel item) => item.toEntity())
          .toList(growable: false),
      confirmLabel: confirmLabel,
      correctLabel: correctLabel,
      note: note,
      payload: Map<String, Object?>.unmodifiable(payload),
      isReadyToConfirm: isReadyToConfirm,
      missingFields: List<String>.unmodifiable(missingFields),
    );
  }
}

/// DTO satu pesan tersimpan (`PersistedAiMessageDto`).
class AiMessageModel {
  const AiMessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.routePath,
    required this.citations,
    required this.actions,
    this.createdAt,
  });

  factory AiMessageModel.fromJson(Map<String, Object?> json) {
    return AiMessageModel(
      id: _asInt(json['id']),
      conversationId: _asInt(json['conversationId']),
      role: _asString(json['role'], fallback: 'ASSISTANT'),
      content: _asString(json['content']),
      routePath: _asNullableString(json['routePath']),
      citations: _asMapList(json['citations'])
          .map(AiCitationModel.fromJson)
          .toList(growable: false),
      actions: _asMapList(json['actions'])
          .map(AiActionDraftModel.fromJson)
          .toList(growable: false),
      createdAt: _asDateTime(json['createdAt']),
    );
  }

  final int id;
  final int conversationId;
  final String role;
  final String content;
  final String? routePath;
  final List<AiCitationModel> citations;
  final List<AiActionDraftModel> actions;
  final DateTime? createdAt;

  AiMessage toEntity() {
    return AiMessage(
      id: id,
      conversationId: conversationId,
      author: AiMessageAuthor.fromRaw(role),
      content: content,
      routePath: routePath == null ? null : AiRoutePath.fromRaw(routePath),
      citations: citations
          .map((AiCitationModel c) => c.toEntity())
          .toList(growable: false),
      actions: actions
          .map((AiActionDraftModel a) => a.toEntity())
          .toList(growable: false),
      createdAt: createdAt,
    );
  }
}

/// DTO ringkasan percakapan (`ConversationSummaryDto`).
class AiConversationSummaryModel {
  const AiConversationSummaryModel({
    required this.id,
    required this.title,
    required this.messageCount,
    this.lastMessagePreview,
    this.createdAt,
    this.updatedAt,
  });

  factory AiConversationSummaryModel.fromJson(Map<String, Object?> json) {
    return AiConversationSummaryModel(
      id: _asInt(json['id']),
      title: _asString(json['title'], fallback: 'Percakapan AI SOJU'),
      messageCount: _asInt(json['messageCount']),
      lastMessagePreview: _asNullableString(json['lastMessagePreview']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  final int id;
  final String title;
  final int messageCount;
  final String? lastMessagePreview;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AiConversationSummary toEntity() {
    return AiConversationSummary(
      id: id,
      title: title,
      messageCount: messageCount,
      lastMessagePreview: lastMessagePreview,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// DTO detail percakapan (`ConversationDetailDto`).
class AiConversationDetailModel {
  const AiConversationDetailModel({
    required this.id,
    required this.title,
    required this.messages,
    this.createdAt,
    this.updatedAt,
  });

  factory AiConversationDetailModel.fromJson(Map<String, Object?> json) {
    return AiConversationDetailModel(
      id: _asInt(json['id']),
      title: _asString(json['title'], fallback: 'Percakapan AI SOJU'),
      messages: _asMapList(json['messages'])
          .map(AiMessageModel.fromJson)
          .toList(growable: false),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  final int id;
  final String title;
  final List<AiMessageModel> messages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AiConversationDetail toEntity() {
    return AiConversationDetail(
      id: id,
      title: title,
      messages: messages
          .map((AiMessageModel m) => m.toEntity())
          .toList(growable: false),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// DTO balasan `POST /api/v1/ai/chat` (`SendChatMessageResult`).
class AiChatReplyModel {
  const AiChatReplyModel({
    required this.conversationId,
    required this.title,
    required this.routePath,
    required this.reply,
    required this.citations,
    required this.actions,
    this.userMessage,
    this.assistantMessage,
  });

  factory AiChatReplyModel.fromJson(Map<String, Object?> json) {
    final Map<String, Object?> userMap = _asMap(json['userMessage']);
    final Map<String, Object?> assistantMap = _asMap(json['assistantMessage']);

    return AiChatReplyModel(
      conversationId: _asInt(json['conversationId']),
      title: _asString(json['title'], fallback: 'Percakapan AI SOJU'),
      routePath: _asString(json['routePath'], fallback: 'UNKNOWN'),
      reply: _asString(json['reply']),
      citations: _asMapList(json['citations'])
          .map(AiCitationModel.fromJson)
          .toList(growable: false),
      actions: _asMapList(json['actions'])
          .map(AiActionDraftModel.fromJson)
          .toList(growable: false),
      userMessage:
          userMap.isEmpty ? null : AiMessageModel.fromJson(userMap),
      assistantMessage: assistantMap.isEmpty
          ? null
          : AiMessageModel.fromJson(assistantMap),
    );
  }

  final int conversationId;
  final String title;
  final String routePath;
  final String reply;
  final List<AiCitationModel> citations;
  final List<AiActionDraftModel> actions;
  final AiMessageModel? userMessage;
  final AiMessageModel? assistantMessage;

  AiChatReply toEntity() {
    return AiChatReply(
      conversationId: conversationId,
      title: title,
      routePath: AiRoutePath.fromRaw(routePath),
      reply: reply,
      citations: citations
          .map((AiCitationModel c) => c.toEntity())
          .toList(growable: false),
      actions: actions
          .map((AiActionDraftModel a) => a.toEntity())
          .toList(growable: false),
      userMessage: userMessage?.toEntity(),
      assistantMessage: assistantMessage?.toEntity(),
    );
  }
}

/// DTO respons transaksi tersimpan (`POST /api/v1/transactions`).
class AiConfirmedTransactionModel {
  const AiConfirmedTransactionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.nominal,
    this.message,
  });

  factory AiConfirmedTransactionModel.fromJson(
    Map<String, Object?> json, {
    String? message,
  }) {
    return AiConfirmedTransactionModel(
      id: _asInt(json['id']),
      code: _asString(json['kode'] ?? json['code']),
      name: _asString(
        json['namaTransaksi'] ?? json['nama_transaksi'],
        fallback: 'Transaksi AI',
      ),
      nominal: _asInt(json['nominal']),
      message: message,
    );
  }

  final int id;
  final String code;
  final String name;
  final int nominal;
  final String? message;

  AiConfirmedTransaction toEntity() {
    return AiConfirmedTransaction(
      id: id,
      code: code,
      name: name,
      nominal: nominal,
      message: message,
    );
  }
}

/// DTO respons `POST /api/v1/ai/reindex`.
class AiReindexResultModel {
  const AiReindexResultModel({
    required this.documentsProcessed,
    required this.chunksCreated,
    required this.piiRedactedChunks,
    required this.documentsCount,
    required this.productsCount,
    required this.cmsCount,
    this.message,
  });

  factory AiReindexResultModel.fromJson(
    Map<String, Object?> json, {
    String? message,
  }) {
    final Map<String, Object?> sources = _asMap(json['sources']);
    return AiReindexResultModel(
      documentsProcessed: _asInt(json['documentsProcessed']),
      chunksCreated: _asInt(json['chunksCreated']),
      piiRedactedChunks: _asInt(json['piiRedactedChunks']),
      documentsCount: _asInt(sources['documents']),
      productsCount: _asInt(sources['products']),
      cmsCount: _asInt(sources['cms']),
      message: message,
    );
  }

  final int documentsProcessed;
  final int chunksCreated;
  final int piiRedactedChunks;
  final int documentsCount;
  final int productsCount;
  final int cmsCount;
  final String? message;

  AiReindexResult toEntity() {
    return AiReindexResult(
      documentsProcessed: documentsProcessed,
      chunksCreated: chunksCreated,
      piiRedactedChunks: piiRedactedChunks,
      documentsCount: documentsCount,
      productsCount: productsCount,
      cmsCount: cmsCount,
      message: message,
    );
  }
}
