// Unit test: AiChatController (`ChangeNotifier`).

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/ai_chat_entity.dart';
import 'package:soju_fe/domain/repositories/ai_chat_repository.dart';
import 'package:soju_fe/domain/usecases/ai_chat_usecases.dart';
import 'package:soju_fe/presentation/providers/ai/ai_chat_controller.dart';

class _StubAiChatRepository implements AiChatRepository {
  List<AiConversationSummary> conversations = const <AiConversationSummary>[
    AiConversationSummary(
      id: 1,
      title: 'Ringkasan Omzet',
      messageCount: 2,
      lastMessagePreview: 'Total omzet Rp 1.250.000',
    ),
  ];

  AiConversationDetail? detailToReturn;
  AiChatReply? replyToReturn;
  AppFailure? nextFailure;
  int confirmCalls = 0;
  int reindexCalls = 0;

  @override
  Future<Result<List<AiConversationSummary>>> fetchConversations({
    int? limit,
  }) async {
    if (nextFailure != null) {
      return Result<List<AiConversationSummary>>.failure(nextFailure!);
    }
    return Result<List<AiConversationSummary>>.success(conversations);
  }

  @override
  Future<Result<AiConversationDetail>> fetchConversationDetail(
    int conversationId,
  ) async {
    if (nextFailure != null) {
      return Result<AiConversationDetail>.failure(nextFailure!);
    }
    return Result<AiConversationDetail>.success(
      detailToReturn ??
          AiConversationDetail(
            id: conversationId,
            title: 'Ringkasan Omzet',
            messages: const <AiMessage>[
              AiMessage(
                id: 101,
                conversationId: 1,
                author: AiMessageAuthor.user,
                content: 'Berapa omzet hari ini?',
              ),
              AiMessage(
                id: 102,
                conversationId: 1,
                author: AiMessageAuthor.assistant,
                content: 'Omzet hari ini Rp 1.250.000 [SQL-1].',
                routePath: AiRoutePath.sqlTool,
              ),
            ],
          ),
    );
  }

  @override
  Future<Result<AiChatReply>> sendMessage({
    required String message,
    int? conversationId,
  }) async {
    if (nextFailure != null) {
      return Result<AiChatReply>.failure(nextFailure!);
    }
    final int id = conversationId ?? 2;
    return Result<AiChatReply>.success(
      replyToReturn ??
          AiChatReply(
            conversationId: id,
            title: message,
            routePath: AiRoutePath.vectorRag,
            reply: 'Jawaban dari SOP [D1].',
            citations: const <AiCitation>[
              AiCitation(
                id: 'D1',
                title: 'SOP Dapur',
                sourceType: 'SOP',
                excerpt: 'Cuci tangan sebelum memasak.',
              ),
            ],
            actions: const <AiActionDraft>[],
          ),
    );
  }

  @override
  Future<Result<AiConfirmedTransaction>> confirmDraftTransaction(
    AiActionDraft draft,
  ) async {
    confirmCalls++;
    if (nextFailure != null) {
      return Result<AiConfirmedTransaction>.failure(nextFailure!);
    }
    return Result<AiConfirmedTransaction>.success(
      const AiConfirmedTransaction(
        id: 55,
        code: 'PJL055-99999',
        name: 'Penjualan',
        nominal: 150000,
      ),
    );
  }

  @override
  Future<Result<AiReindexResult>> triggerReindex() async {
    reindexCalls++;
    if (nextFailure != null) {
      return Result<AiReindexResult>.failure(nextFailure!);
    }
    return Result<AiReindexResult>.success(
      const AiReindexResult(
        documentsProcessed: 5,
        chunksCreated: 12,
        piiRedactedChunks: 0,
        documentsCount: 2,
        productsCount: 2,
        cmsCount: 1,
      ),
    );
  }
}

AiActionDraft _sampleDraft() {
  return const AiActionDraft(
    id: 'draft-abc',
    type: 'CREATE_TRANSACTION',
    intent: 'PENJUALAN',
    requiresConfirmation: true,
    endpoint: '/api/v1/transactions',
    method: 'POST',
    title: 'Draft Penjualan',
    sheet: 'Transaksi',
    summaryRows: <AiDraftSummaryRow>[],
    total: 'Rp 150.000',
    totalAmount: 150000,
    badge: 'Belum disimpan',
    dateLabel: '25 Nov 2026',
    shiftLabel: 'Shift Siang',
    totalLabel: 'TOTAL PEMASUKAN KASIR',
    breakdownTitle: 'Rincian',
    items: <AiDraftLineItem>[],
    confirmLabel: 'Konfirmasi & Simpan',
    correctLabel: 'Koreksi',
    note: 'Belum disimpan.',
    payload: <String, Object?>{
      'tanggal': '2026-11-25',
      'jenis_transaksi_id': 1,
      'nominal': 150000,
    },
    isReadyToConfirm: true,
    missingFields: <String>[],
  );
}

void main() {
  late _StubAiChatRepository repo;
  late AiChatController controller;

  setUp(() {
    repo = _StubAiChatRepository();
    controller = AiChatController(
      getConversations: GetAiConversations(repo),
      getConversationDetail: GetAiConversationDetail(repo),
      sendChatMessage: SendAiChatMessage(repo),
      confirmDraftTransaction: ConfirmAiDraftTransaction(repo),
      triggerReindex: TriggerAiReindex(repo),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('loadConversations mengisi daftar riwayat', () async {
    await controller.loadConversations();

    expect(controller.state.isLoadingHistory, isFalse);
    expect(controller.state.historyError, isNull);
    expect(controller.state.conversations, hasLength(1));
    expect(controller.state.conversations.first.title, 'Ringkasan Omzet');
  });

  test('openConversation memuat pesan dari backend', () async {
    await controller.loadConversations();
    await controller.openConversation(controller.state.conversations.first);

    expect(controller.state.isInConversation, isTrue);
    expect(controller.state.activeConversationId, 1);
    expect(controller.state.messages, hasLength(2));
    expect(controller.state.messages.last.routePath, AiRoutePath.sqlTool);
  });

  test('sendMessage menambahkan pesan user & asisten dan memperbarui riwayat', () async {
    controller.startNewConversation();
    final bool ok = await controller.sendMessage('Bagaimana SOP dapur?');

    expect(ok, isTrue);
    expect(controller.state.activeConversationId, 2);
    expect(controller.state.messages, hasLength(2));
    expect(controller.state.messages.last.citations.first.id, 'D1');
    expect(controller.state.conversations.first.id, 2);
  });

  test('confirmDraft menyimpan transaksi sekali saja dan menandai tersimpan', () async {
    final AiActionDraft draft = _sampleDraft();
    final Result<AiConfirmedTransaction> first =
        await controller.confirmDraft(draft);
    final Result<AiConfirmedTransaction> second =
        await controller.confirmDraft(draft);

    expect(first.isSuccess, isTrue);
    expect(second.isSuccess, isTrue);
    expect(repo.confirmCalls, 1);
    expect(controller.state.isDraftConfirmed(draft.id), isTrue);
    expect(
      controller.state.confirmedTransactionFor(draft.id)?.code,
      'PJL055-99999',
    );
  });

  test('triggerReindex memanggil usecase reindex dan mengembalikan hasil', () async {
    final Result<AiReindexResult> result = await controller.triggerReindex();

    expect(result.isSuccess, isTrue);
    expect(repo.reindexCalls, 1);
    expect(result.valueOrNull!.documentsProcessed, 5);
    expect(controller.state.isReindexing, isFalse);
  });
}
