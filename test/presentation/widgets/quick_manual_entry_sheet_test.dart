// test/presentation/widgets/quick_manual_entry_sheet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/presentation/widgets/quick_manual_entry_sheet.dart';

void main() {
  testWidgets('showQuickManualEntrySheet opens, switches tabs, and submits transaction', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showQuickManualEntrySheet(ctx),
                child: const Text('Open Manual Entry'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open sheet
    await tester.tap(find.text('Open Manual Entry'));
    await tester.pumpAndSettle();

    // Verify header and segments
    expect(find.text('Catat Data Manual'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pendataan'), findsOneWidget);

    // Verify default Pemasukan fields
    expect(find.text('Nominal (Rp)'), findsOneWidget);
    expect(find.text('Penjualan Offline'), findsOneWidget);
    expect(find.text('Tunai (Cash)'), findsOneWidget);

    // Scroll down to submit button and tap with empty amount -> shows error
    final Finder submitBtn = find.byKey(const Key('manual_entry_submit_button'));
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();
    expect(find.text('Nominal harus lebih besar dari Rp 0'), findsOneWidget);

    // Scroll back up to segmented tab 'Pendataan' and tap
    final Finder pendataanTab = find.text('Pendataan');
    await tester.ensureVisible(pendataanTab);
    await tester.tap(pendataanTab);
    await tester.pumpAndSettle();
    expect(find.text('Tabel Bebas & Pendataan'), findsOneWidget);
    expect(find.text('Buka Layar Pendataan Kasir'), findsOneWidget);

    // Scroll up to segmented tab 'Pengeluaran' and tap
    final Finder pengeluaranTab = find.text('Pengeluaran');
    await tester.ensureVisible(pengeluaranTab);
    await tester.tap(pengeluaranTab);
    await tester.pumpAndSettle();
    expect(find.text('Bahan Baku'), findsOneWidget);
    expect(find.text('Gas & Minyak'), findsOneWidget);

    // Enter valid amount in Pengeluaran
    final Finder amountField = find.byKey(const Key('manual_entry_amount_field'));
    await tester.ensureVisible(amountField);
    await tester.enterText(amountField, '50000');
    await tester.pumpAndSettle();

    // Select category 'Bahan Baku'
    final Finder bahanBakuChip = find.text('Bahan Baku');
    await tester.ensureVisible(bahanBakuChip);
    await tester.tap(bahanBakuChip);
    await tester.pumpAndSettle();

    // Ensure submit button is visible and tap
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Sheet should close and SnackBar should appear on the Scaffold
    expect(find.byType(QuickManualEntrySheet), findsNothing);
    expect(find.text('Berhasil Catat Pengeluaran'), findsOneWidget);
  });
}
