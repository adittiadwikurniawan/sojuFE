// Widget test: layar Chatbot Soju (frame 546:3687).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/chatbot/chatbot_screen.dart';
import 'package:soju_fe/presentation/screens/chatbot/models/chat_draft.dart';
import 'package:soju_fe/presentation/screens/chatbot/models/chatbot_view_data.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    VoidCallback? onBack,
    ValueChanged<String>? onSend,
    ValueChanged<ChatDraft>? onConfirm,
    Size size = const Size(430, 932),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ChatbotScreen(
          onBack: onBack,
          onSendMessage: onSend,
          onDraftConfirm: onConfirm,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan salam, alat cepat, dan riwayat awal', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text(ChatbotViewData.sample.greeting), findsOneWidget);
    expect(find.text('Alat Cepat'), findsOneWidget);
    expect(find.text('Catat Sales'), findsOneWidget);
    expect(find.text('Catat Belanja'), findsOneWidget);
    expect(find.text('Kelola Suplier'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Lihat Semua'), findsOneWidget);
    expect(find.text('Input Hasil Penjualan'), findsOneWidget);
    expect(find.text('Catat Pengeluaran'), findsNWidgets(2));
    expect(find.text('Catat Laporan Kas'), findsOneWidget);
    expect(find.text('Cek Stok Menipis'), findsNothing);
    expect(find.text('Tambah Chat'), findsOneWidget);
  });

  testWidgets('lihat semua memperluas riwayat di halaman yang sama', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    expect(find.text('Sembunyikan'), findsOneWidget);
    expect(find.text('Cek Stok Menipis'), findsOneWidget);
    expect(find.text('Input Penjualan QRIS'), findsOneWidget);
    expect(find.text('Ringkasan Laba Mingguan'), findsOneWidget);
    expect(find.text('Alat Cepat'), findsOneWidget);

    await tester.tap(find.text('Sembunyikan'));
    await tester.pumpAndSettle();

    expect(find.text('Cek Stok Menipis'), findsNothing);
    expect(find.text('Lihat Semua'), findsOneWidget);
  });

  testWidgets('alat cepat membuka chat berisi draft belum disimpan', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Catat Sales'));
    await tester.pumpAndSettle();

    expect(find.text('Alat Cepat'), findsNothing);
    expect(find.text('Belum disimpan'), findsOneWidget);
    expect(find.text('TOTAL PEMASUKAN KASIR'), findsOneWidget);
    expect(find.text('+ Rp 1.375.000'), findsOneWidget);
    expect(find.text('Konfirmasi & Simpan'), findsOneWidget);
    expect(find.text('Koreksi Jumlah / Harga'), findsOneWidget);
    expect(find.text(ChatbotViewData.sample.demoNotice), findsOneWidget);
  });

  testWidgets('konfirmasi draft hanya menampilkan pesan mode demo', (
    WidgetTester tester,
  ) async {
    ChatDraft? confirmed;
    await pumpScreen(tester, onConfirm: (ChatDraft draft) {
      confirmed = draft;
    });

    await tester.tap(find.text('Input Hasil Penjualan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konfirmasi & Simpan'));
    await tester.pump();

    expect(confirmed, isNotNull);
    expect(confirmed!.total, 1375000);
    expect(
      find.text(ChatbotViewData.sample.confirmDemoMessage),
      findsOneWidget,
    );
  });

  testWidgets('mengirim pesan menambah gelembung dan balasan mock', (
    WidgetTester tester,
  ) async {
    String? sent;
    await pumpScreen(tester, onSend: (String text) {
      sent = text;
    });

    await tester.tap(find.text('Tambah Chat'));
    await tester.pumpAndSettle();

    expect(find.text(ChatbotViewData.sample.newChatGreeting), findsOneWidget);
    expect(find.text('Coba tanyakan'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Halo Soju');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(sent, 'Halo Soju');
    expect(find.text('Halo Soju'), findsOneWidget);
    expect(find.text(ChatbotViewData.sample.demoReply), findsOneWidget);
    expect(find.text('Coba tanyakan'), findsNothing);
  });

  testWidgets('saran cepat mengirim pesan contoh tanpa backend', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Tambah Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cek stok menipis'));
    await tester.pumpAndSettle();

    expect(find.text('Cek stok menipis'), findsOneWidget);
    expect(
      find.textContaining('belum terhubung ke data stok'),
      findsOneWidget,
    );
  });

  testWidgets('kembali menutup chat lalu memanggil onBack', (
    WidgetTester tester,
  ) async {
    int backCount = 0;
    await pumpScreen(tester, onBack: () {
      backCount++;
    });

    await tester.tap(find.text('Input Hasil Penjualan'));
    await tester.pumpAndSettle();
    expect(find.text('Alat Cepat'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Alat Cepat'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(backCount, 1);
  });

  testWidgets('tata letak aman pada layar sempit', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, size: const Size(360, 800));

    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();
    expect(find.text('Ringkasan Laba Mingguan'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Chat'));
    await tester.pumpAndSettle();

    expect(find.text(ChatbotViewData.sample.newChatGreeting), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
