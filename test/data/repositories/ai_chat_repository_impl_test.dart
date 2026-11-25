// Unit test: AiChatRepositoryImpl (`/api/v1/ai/*` & `POST /api/v1/transactions`).

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/data/datasources/interfaces/ai_chat_datasource.dart';
import 'package:soju_fe/data/repositories/ai_chat_repository_impl.dart';
import 'package:soju_fe/domain/entities/ai_chat_entity.dart';

class _FakeAiChatDataSource implements AiChatDataSource {
  Map<String, Object?>? lastConfirmPayload;
  String? lastSentMessage;
  int? lastSentConversationId;
  bool reindexCalled = false;

  Map<String, Object?> conversationsResponse = <String, Object?>{
    'success': true,
    'data': <Object?>[
      <String, Object?>{
        'id': 10,
        'title': 'Omzet Hari Ini',
        'messageCount': 2,
        'lastMessagePreview': 'Total omzet hari ini Rp 1.500.000',
        'createdAt': '2026-11-25T03:00:00.000Z',
        'updatedAt': '2026-11-25T03:05:00.000Z',
      },
    ],
  };

  Map<String, Object?> detailResponse = <String, Object?>{
    'success': true,
    'data': <String, Object?>{
      'id': 10,
      'title': 'Omzet Hari Ini',
      'messages': <Object?>[
        <String, Object?>{
          'id': 1,
          'conversationId': 10,
          'role': 'USER',
          'content': 'Berapa omzet hari ini?',
          'citations': <Object?>[],
          'actions': <Object?>[],
        },
        <String, Object?>{
          'id': 2,
          'conversationId': 10,
          'role': 'ASSISTANT',
          'content': 'Total omzet hari ini Rp 1.500.000 [SQL-1].',
          'routePath': 'SQL_TOOL',
          'citations': <Object?>[
            <String, Object?>{
              'id': 'SQL-1',
              'sourceType': 'SQL_TOOL',
              'label': 'Ringkasan Penjualan',
              'querySummary': 'SUM(nominal) hari ini',
            },
          ],
          'actions': <Object?>[],
        },
      ],
    },
  };

  Map<String, Object?> chatResponse = <String, Object?>{
    'success': true,
    'data': <String, Object?>{
      'conversationId': 11,
      'title': 'SOP Dapur',
      'routePath': 'VECTOR_RAG',
      'reply': 'Gunakan sarung tangan saat penyajian [D1].',
      'citations': <Object?>[
        <String, Object?>{
          'id': 'D1',
          'title': 'SOP Kebersihan Dapur',
          'sourceType': 'SOP',
          'snippet': 'Wajib menggunakan sarung tangan food-grade.',
          'score': 0.91,
        },
      ],
      'actions': <Object?>[],
    },
  };

  Map<String, Object?> confirmResponse = <String, Object?>{
    'success': true,
    'message': 'Transaksi berhasil dicatat',
    'data': <String, Object?>{
      'id': 99,
      'kode': 'PJL010-12345',
      'namaTransaksi': 'Penjualan',
      'nominal': 175000,
    },
  };

  Map<String, Object?> reindexResponse = <String, Object?>{
    'success': true,
    'message': 'Reindex basis pengetahuan AI berhasil dijalankan',
    'data': <String, Object?>{
      'documentsProcessed': 8,
      'chunksCreated': 20,
      'piiRedactedChunks': 0,
      'sources': <String, Object?>{'documents': 3, 'products': 4, 'cms': 1},
    },
  };

  AppFailure? nextFailure;

  @override
  Future<Map<String, Object?>> fetchConversationsRaw({int? limit}) async {
    if (nextFailure != null) throw nextFailure!;
    return conversationsResponse;
  }

  @override
  Future<Map<String, Object?>> fetchConversationDetailRaw(
    int conversationId,
  ) async {
    if (nextFailure != null) throw nextFailure!;
    return detailResponse;
  }

  @override
  Future<Map<String, Object?>> sendChatMessageRaw({
    required String message,
    int? conversationId,
  }) async {
    if (nextFailure != null) throw nextFailure!;
    lastSentMessage = message;
    lastSentConversationId = conversationId;
    return chatResponse;
  }

  @override
  Future<Map<String, Object?>> confirmDraftTransactionRaw(
    Map<String, Object?> payload,
  ) async {
    if (nextFailure != null) throw nextFailure!;
    lastConfirmPayload = payload;
    return confirmResponse;
  }

  @override
  Future<Map<String, Object?>> triggerReindexRaw() async {
    if (nextFailure != null) throw nextFailure!;
    reindexCalled = true;
    return reindexResponse;
  }
}

AiActionDraft _readyDraft({bool isReady = true}) {
  return AiActionDraft(
    id: 'draft-1',
    type: 'CREATE_TRANSACTION',
    intent: 'PENJUALAN',
    requiresConfirmation: true,
    endpoint: '/api/v1/transactions',
    method: 'POST',
    title: 'Draft Penjualan',
    sheet: 'Transaksi',
    summaryRows: const <AiDraftSummaryRow>[],
    total: 'Rp 175.000',
    totalAmount: 175000,
    badge: 'Belum disimpan',
    dateLabel: '25 Nov 2026',
    shiftLabel: 'Shift Siang',
    totalLabel: 'TOTAL PEMASUKAN KASIR',
    breakdownTitle: 'Rincian',
    items: const <AiDraftLineItem>[],
    confirmLabel: 'Konfirmasi & Simpan',
    correctLabel: 'Koreksi',
    note: 'Belum disimpan.',
    payload: const <String, Object?>{
      'tanggal': '2026-11-25',
      'jenis_transaksi_id': 1,
      'nominal': 175000,
      'detail': 'Penjualan bento',
    },
    isReadyToConfirm: isReady,
    missingFields: isReady ? const <String>[] : const <String>['nominal'],
  );
}

void main() {
  late _FakeAiChatDataSource dataSource;
  late AiChatRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeAiChatDataSource();
    repository = AiChatRepositoryImpl(dataSource);
  });

  test('fetchConversations mengembalikan daftar riwayat percakapan', () async {
    final Result<List<AiConversationSummary>> result =
        await repository.fetchConversations();

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, hasLength(1));
    expect(result.valueOrNull!.first.title, 'Omzet Hari Ini');
  });

  test('fetchConversationDetail mengembalikan pesan dan sitasi', () async {
    final Result<AiConversationDetail> result =
        await repository.fetchConversationDetail(10);

    expect(result.isSuccess, isTrue);
    final AiConversationDetail detail = result.valueOrNull!;
    expect(detail.messages, hasLength(2));
    expect(detail.messages.last.routePath, AiRoutePath.sqlTool);
    expect(detail.messages.last.citations.first.id, 'SQL-1');
  });

  test('sendMessage menolak pesan kosong tanpa memanggil datasource', () async {
    final Result<AiChatReply> result =
        await repository.sendMessage(message: '   ');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
    expect(dataSource.lastSentMessage, isNull);
  });

  test('sendMessage meneruskan pesan dan conversationId', () async {
    final Result<AiChatReply> result = await repository.sendMessage(
      message: 'Bagaimana SOP dapur?',
      conversationId: 10,
    );

    expect(result.isSuccess, isTrue);
    expect(dataSource.lastSentMessage, 'Bagaimana SOP dapur?');
    expect(dataSource.lastSentConversationId, 10);
    expect(result.valueOrNull!.citations.first.id, 'D1');
  });

  test('confirmDraftTransaction mengirim sumberInput AI saat siap', () async {
    final Result<AiConfirmedTransaction> result =
        await repository.confirmDraftTransaction(_readyDraft());

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull!.code, 'PJL010-12345');
    expect(dataSource.lastConfirmPayload?['sumber_input'], 'AI');
    expect(dataSource.lastConfirmPayload?['sumberInput'], 'AI');
    expect(dataSource.lastConfirmPayload?['nominal'], 175000);
  });

  test('confirmDraftTransaction menolak draft yang belum lengkap', () async {
    final Result<AiConfirmedTransaction> result =
        await repository.confirmDraftTransaction(_readyDraft(isReady: false));

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
    expect(dataSource.lastConfirmPayload, isNull);
  });

  test('triggerReindex memetakan hasil reindex dan meneruskan 403 ServerFailure',
      () async {
    final Result<AiReindexResult> ok = await repository.triggerReindex();
    expect(ok.isSuccess, isTrue);
    expect(dataSource.reindexCalled, isTrue);
    expect(ok.valueOrNull!.documentsProcessed, 8);

    dataSource.nextFailure = const ServerFailure(
      statusCode: 403,
      message: 'Hanya SUPER_ADMIN yang dapat menjalankan reindex.',
    );
    final Result<AiReindexResult> forbidden = await repository.triggerReindex();
    expect(forbidden.isFailure, isTrue);
    expect(forbidden.failureOrNull, isA<ServerFailure>());
    expect((forbidden.failureOrNull! as ServerFailure).statusCode, 403);
  });
}
