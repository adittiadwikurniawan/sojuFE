// Widget test: layar Analytics (frame 546:2937).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/analytics/analytics_screen.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_export_request.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_view_data.dart';
import 'package:soju_fe/presentation/screens/analytics/widgets/analytics_filter_chips.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    Future<void> Function(AnalyticsExportRequest request)? onExport,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: AnalyticsScreen(onExportExcel: onExport),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder chip(String label) => find.descendant(
        of: find.byType(AnalyticsFilterChips),
        matching: find.text(label),
      );

  Future<void> tapChip(WidgetTester tester, String label) async {
    final Finder target = chip(label);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan ringkasan, grafik, rincian, dan daftar transaksi', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Total Pemasukan'), findsOneWidget);
    expect(find.text('Total Pengeluaran'), findsOneWidget);
    expect(find.text('Keuntungan Bersih'), findsOneWidget);
    expect(find.text('Rp 15.000.000'), findsWidgets);
    expect(find.text('Rp 5.000.000'), findsWidgets);
    expect(find.text('Semua (12)'), findsOneWidget);

    expect(find.text('Oktober 2026'), findsWidgets);
    expect(find.text('Proporsi Arus Kas'), findsOneWidget);
    expect(find.text('Tren Arus Kas Harian'), findsOneWidget);
    expect(find.text('Rincian Transaksi'), findsOneWidget);
    expect(find.text('4 Kategori Aktif'), findsOneWidget);
    expect(find.text('Sumber Pengeluaran'), findsOneWidget);
    expect(find.text('Sumber Pemasukan'), findsOneWidget);

    expect(find.text('12 Transaksi'), findsOneWidget);
    expect(find.text('Penjualan Sosis Solo'), findsOneWidget);
    expect(find.text('12 Transaksi'), findsOneWidget);
  });

  testWidgets('chip Pemasukan memfilter seluruh angka turunan', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(chip('Pemasukan'));
    await tester.pumpAndSettle();

    expect(find.text('Semua (7)'), findsOneWidget);
    expect(find.text('7 Transaksi'), findsOneWidget);
    expect(find.text('Rp 0'), findsWidgets);
    expect(find.text('Rp 15.000.000'), findsWidgets);
    expect(find.text('Penjualan Sosis Solo'), findsOneWidget);
  });

  testWidgets('pencarian menyaring daftar transaksi', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'frozen');
    await tester.pumpAndSettle();

    expect(find.text('Semua (3)'), findsOneWidget);
    expect(find.text('3 Transaksi'), findsOneWidget);
    expect(find.text('Frozen Food Restock'), findsOneWidget);
    expect(find.text('Penjualan Sosis Solo'), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Semua (12)'), findsOneWidget);
  });

  testWidgets('kartu tanggal memfilter satu hari dan bisa dihapus', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.byKey(const Key('date_filter_card')), findsOneWidget);
    await tester.tap(find.byKey(const Key('date_filter_card')));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Tanggal'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('soju_calendar_day_2026_10_26')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('Semua (2)'), findsOneWidget);
    expect(find.text('2 Transaksi'), findsOneWidget);
    expect(find.text('- Rp 1.800.000'), findsWidgets);

    await tester.tap(find.byKey(const Key('date_filter_card')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('12 Transaksi'), findsOneWidget);
  });

  testWidgets('pindah bulan memuat periode lain dan menampilkan keadaan kosong',
      (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Bulan berikutnya'));
    await tester.pumpAndSettle();

    expect(find.text('November 2026'), findsWidgets);
    expect(find.text('Semua (0)'), findsOneWidget);
    expect(find.text('Belum ada transaksi pada filter ini'), findsOneWidget);
  });

  testWidgets('chip Kategori membuka pilihan dan menerapkan filter', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tapChip(tester, 'Kategori');

    expect(find.text('Filter kategori'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Frozen Food'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kategori: Frozen Food'), findsOneWidget);
    expect(find.text('3 Transaksi'), findsOneWidget);
  });

  testWidgets('kartu tanggal membuka kalender dan Semua mereset tanggal', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const Key('date_filter_card')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('soju_calendar_day_2026_10_5')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('0 Transaksi'), findsOneWidget);
    expect(find.text('Semua (0)'), findsOneWidget);

    await tester.tap(chip('Semua (0)'));
    await tester.pumpAndSettle();

    expect(find.text('12 Transaksi'), findsOneWidget);
    expect(find.text('Semua (12)'), findsOneWidget);
  });

  testWidgets('ekspor meneruskan transaksi terfilter ke callback', (
    WidgetTester tester,
  ) async {
    AnalyticsExportRequest? captured;
    await pumpScreen(
      tester,
      onExport: (AnalyticsExportRequest request) async {
        captured = request;
      },
    );

    await tester.tap(find.byTooltip('Ekspor Excel'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.transactions.length, 12);
    expect(captured!.summary.income, 15000000);
    expect(captured!.range, monthRangeOf(DateTime(2026, 10)));
    expect(captured!.fileName, contains('2026-10-01'));
    expect(find.text('Ekspor Excel siap diunduh.'), findsOneWidget);
  });

  testWidgets('ekspor memberi tahu saat belum tersambung ke API', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Ekspor Excel'));
    await tester.pumpAndSettle();

    expect(find.text('Ekspor Excel belum tersambung ke API.'), findsOneWidget);
  });

  testWidgets('kegagalan ekspor ditampilkan sebagai pesan galat', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      onExport: (AnalyticsExportRequest request) async {
        throw StateError('offline');
      },
    );

    await tester.tap(find.byTooltip('Ekspor Excel'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal mengekspor Excel'), findsOneWidget);
  });
}
