// Widget test: layar Hybrid RAG AI Admin SOJU (`TASK-028`).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/domain/entities/ai_chat_entity.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';
import 'package:soju_fe/domain/repositories/ai_chat_repository.dart';
import 'package:soju_fe/domain/usecases/ai_chat_usecases.dart';
import 'package:soju_fe/presentation/providers/ai/ai_chat_controller.dart';
import 'package:soju_fe/presentation/screens/chatbot/chatbot_screen.dart';

class _FakeAiChatRepository implements AiChatRepository {
  List<AiConversationSummary> conversations = const <AiConversationSummary>[
    AiConversationSummary(id: 1, title: 'Input Hasil Penjualan', messageCount: 2),
    AiConversationSummary(id: 2, title: 'SOP Komplain Pelanggan', messageCount: 2),
    AiConversationSummary(id: 3, title: 'Ringkasan Omzet Mingguan', messageCount: 2),
    AiConversationSummary(id: 4, title: 'Catat Belanja Bahan', messageCount: 2),
    AiConversationSummary(id: 5, title: 'Cek Menu Terlaris', messageCount: 2),
  ];

  final Map<int, AiConversationDetail> details = <int, AiConversationDetail>{
    1: const AiConversationDetail(
      id: 1,
      title: 'Input Hasil Penjualan',
      messages: <AiMessage>[
        AiMessage(
          id: 11,
          conversationId: 1,
          author: AiMessageAuthor.user,
          content: 'Catat penjualan bento 5 porsi tunai',
        ),
        AiMessage(
          id: 12,
          conversationId: 1,
          author: AiMessageAuthor.assistant,
          content:
              'Draft transaksi penjualan siap. Silakan periksa lalu konfirmasi.',
          routePath: AiRoutePath.actionDraft,
          actions: <AiActionDraft>[_sampleDraft],
        ),
      ],
    ),
    2: const AiConversationDetail(
      id: 2,
      title: 'SOP Komplain Pelanggan',
      messages: <AiMessage>[
        AiMessage(
          id: 21,
          conversationId: 2,
          author: AiMessageAuthor.user,
          content: 'Bagaimana SOP penanganan komplain?',
        ),
        AiMessage(
          id: 22,
          conversationId: 2,
          author: AiMessageAuthor.assistant,
          content:
              'Tanggapi komplain maksimal 15 menit dan tawarkan penggantian [D1].',
          routePath: AiRoutePath.vectorRag,
          citations: <AiCitation>[
            AiCitation(
              id: 'D1',
              title: 'SOP Penanganan Komplain',
              sourceType: 'SOP',
              excerpt:
                  'Admin wajib menanggapi komplain maksimal 15 menit sejak laporan diterima.',
              score: 0.92,
            ),
          ],
        ),
      ],
    ),
  };

  final List<String> sentMessages = <String>[];
  int confirmCallCount = 0;
  int reindexCallCount = 0;
  AiChatReply? nextReply;

  @override
  Future<Result<List<AiConversationSummary>>> fetchConversations({
    int? limit,
  }) async {
    return Result<List<AiConversationSummary>>.success(conversations);
  }

  @override
  Future<Result<AiConversationDetail>> fetchConversationDetail(
    int conversationId,
  ) async {
    return Result<AiConversationDetail>.success(
      details[conversationId] ??
          AiConversationDetail(
            id: conversationId,
            title: 'Percakapan #$conversationId',
            messages: const <AiMessage>[],
          ),
    );
  }

  @override
  Future<Result<AiChatReply>> sendMessage({
    required String message,
    int? conversationId,
  }) async {
    sentMessages.add(message);
    if (nextReply != null) {
      return Result<AiChatReply>.success(nextReply!);
    }
    return Result<AiChatReply>.success(
      AiChatReply(
        conversationId: conversationId ?? 99,
        title: message,
        routePath: AiRoutePath.refusal,
        reply: 'Informasi tidak ditemukan dalam basis pengetahuan SOJU.',
        citations: const <AiCitation>[],
        actions: const <AiActionDraft>[],
      ),
    );
  }

  @override
  Future<Result<AiConfirmedTransaction>> confirmDraftTransaction(
    AiActionDraft draft,
  ) async {
    confirmCallCount++;
    return Result<AiConfirmedTransaction>.success(
      const AiConfirmedTransaction(
        id: 77,
        code: 'PJL077-54321',
        name: 'Penjualan',
        nominal: 175000,
      ),
    );
  }

  @override
  Future<Result<AiReindexResult>> triggerReindex() async {
    reindexCallCount++;
    return Result<AiReindexResult>.success(
      const AiReindexResult(
        documentsProcessed: 6,
        chunksCreated: 18,
        piiRedactedChunks: 0,
        documentsCount: 2,
        productsCount: 3,
        cmsCount: 1,
      ),
    );
  }
}

const AiActionDraft _sampleDraft = AiActionDraft(
  id: 'draft-sales-1',
  type: 'CREATE_TRANSACTION',
  intent: 'PENJUALAN',
  requiresConfirmation: true,
  endpoint: '/api/v1/transactions',
  method: 'POST',
  title: 'Draft Penjualan Kasir',
  sheet: 'Transaksi',
  summaryRows: <AiDraftSummaryRow>[
    AiDraftSummaryRow(label: 'Metode', value: 'TUNAI'),
  ],
  total: 'Rp 175.000',
  totalAmount: 175000,
  badge: 'Belum disimpan',
  dateLabel: '25 Nov 2026',
  shiftLabel: 'Shift Siang',
  totalLabel: 'TOTAL PEMASUKAN KASIR',
  breakdownTitle: 'Rincian Menu Terjual',
  items: <AiDraftLineItem>[
    AiDraftLineItem(
      produkId: 1,
      name: 'Bento Ayam Bakar',
      quantity: 5,
      unit: 'porsi',
      unitPrice: 35000,
      subtotal: 175000,
      method: 'CASH',
    ),
  ],
  confirmLabel: 'Konfirmasi & Simpan',
  correctLabel: 'Koreksi Jumlah / Harga',
  note: 'Draft ini belum disimpan ke pembukuan.',
  payload: <String, Object?>{
    'tanggal': '2026-11-25',
    'jenis_transaksi_id': 1,
    'nominal': 175000,
    'sumber_input': 'AI',
  },
  isReadyToConfirm: true,
  missingFields: <String>[],
);

AiChatController _buildController(_FakeAiChatRepository repo) {
  return AiChatController(
    getConversations: GetAiConversations(repo),
    getConversationDetail: GetAiConversationDetail(repo),
    sendChatMessage: SendAiChatMessage(repo),
    confirmDraftTransaction: ConfirmAiDraftTransaction(repo),
    triggerReindex: TriggerAiReindex(repo),
  );
}

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required _FakeAiChatRepository repo,
    AuthUser? currentUser,
    VoidCallback? onBack,
    Size size = const Size(430, 932),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ChatbotScreen(
          controllerFactory: () => _buildController(repo),
          currentUser: currentUser,
          onBack: onBack,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan riwayat live dan memperluas lewat Lihat Semua', (
    WidgetTester tester,
  ) async {
    final _FakeAiChatRepository repo = _FakeAiChatRepository();
    await pumpScreen(tester, repo: repo);

    expect(find.text(ChatbotScreen.greeting), findsOneWidget);
    expect(find.text('Alat Cepat'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Input Hasil Penjualan'), findsOneWidget);
    expect(find.text('Cek Menu Terlaris'), findsNothing);
    expect(find.text('Lihat Semua'), findsOneWidget);

    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    expect(find.text('Sembunyikan'), findsOneWidget);
    expect(find.text('Cek Menu Terlaris'), findsOneWidget);
  });

  testWidgets('chip sitasi membuka Citations Bottom Sheet dengan judul & cuplikan',
      (WidgetTester tester) async {
    final _FakeAiChatRepository repo = _FakeAiChatRepository();
    await pumpScreen(tester, repo: repo);

    await tester.tap(find.text('SOP Komplain Pelanggan'));
    await tester.pumpAndSettle();

    final Finder chip = find.byKey(const Key('ai_citation_chip_D1'));
    expect(chip, findsOneWidget);

    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai_citations_sheet')), findsOneWidget);
    expect(find.text('Sumber Referensi'), findsOneWidget);
    expect(find.text('SOP Penanganan Komplain'), findsOneWidget);
    expect(
      find.textContaining('maksimal 15 menit sejak laporan diterima'),
      findsOneWidget,
    );
  });

  testWidgets(
      'kartu draft tidak auto-commit dan hanya menyimpan setelah tap konfirmasi',
      (WidgetTester tester) async {
    final _FakeAiChatRepository repo = _FakeAiChatRepository();
    await pumpScreen(tester, repo: repo);

    await tester.tap(find.text('Input Hasil Penjualan'));
    await tester.pumpAndSettle();

    // Sebelum tap konfirmasi: belum ada pemanggilan POST /api/v1/transactions
    expect(repo.confirmCallCount, 0);
    expect(find.text('Belum disimpan'), findsOneWidget);
    expect(find.text('+ Rp 175.000'), findsOneWidget);
    expect(find.text('Konfirmasi & Simpan'), findsOneWidget);

    await tester.tap(find.text('Konfirmasi & Simpan'));
    await tester.pumpAndSettle();

    expect(repo.confirmCallCount, 1);
    expect(find.text('Tersimpan'), findsWidgets);
    expect(
      find.text('Transaksi berhasil disimpan (PJL077-54321).'),
      findsOneWidget,
    );
  });

  testWidgets('tombol reindex hanya tampil untuk SUPER_ADMIN dan tersembunyi untuk ADMIN',
      (WidgetTester tester) async {
    final _FakeAiChatRepository repo = _FakeAiChatRepository();

    // ADMIN biasa: tidak melihat tombol reindex
    await pumpScreen(
      tester,
      repo: repo,
      currentUser: const AuthUser(
        id: 2,
        email: 'admin@soju.id',
        name: 'Admin Biasa',
        role: UserRole.admin,
      ),
    );
    expect(find.byKey(const Key('ai_reindex_button')), findsNothing);

    // SUPER_ADMIN: melihat tombol reindex dan bisa menjalankannya lewat dialog
    await pumpScreen(
      tester,
      repo: repo,
      currentUser: const AuthUser(
        id: 1,
        email: 'super@soju.id',
        name: 'Super Admin',
        role: UserRole.superAdmin,
      ),
    );
    final Finder reindexButton = find.byKey(const Key('ai_reindex_button'));
    expect(reindexButton, findsOneWidget);

    await tester.tap(reindexButton);
    await tester.pumpAndSettle();

    expect(find.text('Perbarui Indeks AI?'), findsOneWidget);
    await tester.tap(find.text('Jalankan Reindex'));
    await tester.pumpAndSettle();

    expect(repo.reindexCallCount, 1);
    expect(
      find.text('Reindex selesai: 6 dokumen (18 potongan teks) diperbarui.'),
      findsOneWidget,
    );
  });

  testWidgets('mengirim pesan live menampilkan balasan penolakan Bahasa Indonesia',
      (WidgetTester tester) async {
    final _FakeAiChatRepository repo = _FakeAiChatRepository();
    await pumpScreen(tester, repo: repo);

    await tester.tap(find.text('Tambah Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Coba tanyakan'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Siapa presiden Mars?');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(repo.sentMessages, <String>['Siapa presiden Mars?']);
    expect(
      find.text('Informasi tidak ditemukan dalam basis pengetahuan SOJU.'),
      findsOneWidget,
    );
    expect(find.text('Di Luar Dokumen'), findsOneWidget);
  });

  testWidgets('composer chat ringkas dan navigasi kembali berjalan benar', (
    WidgetTester tester,
  ) async {
    final _FakeAiChatRepository repo = _FakeAiChatRepository();
    int backCount = 0;
    await pumpScreen(tester, repo: repo, onBack: () => backCount++);

    await tester.tap(find.text('Tambah Chat'));
    await tester.pumpAndSettle();

    final Finder composer = find.byKey(const Key('chat_composer'));
    expect(composer, findsOneWidget);
    expect(tester.getSize(composer).height, lessThanOrEqualTo(90));

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Alat Cepat'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(backCount, 1);
  });
}
