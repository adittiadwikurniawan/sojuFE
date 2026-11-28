// test/presentation/widgets/quick_manual_entry_sheet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/presentation/widgets/quick_manual_entry_sheet.dart';

void main() {
  testWidgets(
      'showQuickManualEntrySheet supports custom categories and submits transaction', (
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

    // Verify default Pemasukan starter categories
    expect(find.text('Penjualan'), findsOneWidget);
    expect(find.text('Modal'), findsOneWidget);

    // Tap submit with empty amount -> shows error
    final Finder submitBtn = find.byKey(const Key('manual_entry_submit_button'));
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();
    expect(find.text('Nominal harus lebih besar dari Rp 0'), findsOneWidget);

    // Switch to Pendataan
    final Finder pendataanTab = find.text('Pendataan');
    await tester.ensureVisible(pendataanTab);
    await tester.tap(pendataanTab);
    await tester.pumpAndSettle();
    expect(find.text('Tabel Bebas & Pendataan'), findsOneWidget);

    // Switch to Pengeluaran
    final Finder pengeluaranTab = find.text('Pengeluaran');
    await tester.ensureVisible(pengeluaranTab);
    await tester.tap(pengeluaranTab);
    await tester.pumpAndSettle();
    expect(find.text('Bahan Baku'), findsOneWidget);

    // Add a custom category by user
    final Finder addCatToggle =
        find.byKey(const Key('manual_entry_add_category_toggle'));
    await tester.ensureVisible(addCatToggle);
    await tester.tap(addCatToggle);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('manual_entry_custom_category_field')),
      'Beli Saus Pedas',
    );
    await tester.tap(find.byKey(const Key('manual_entry_save_category_button')));
    await tester.pumpAndSettle();

    // Custom category now appears as a chip
    expect(find.text('Beli Saus Pedas'), findsOneWidget);

    // Enter valid amount
    final Finder amountField = find.byKey(const Key('manual_entry_amount_field'));
    await tester.ensureVisible(amountField);
    await tester.enterText(amountField, '50000');
    await tester.pumpAndSettle();

    // Submit
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Sheet closes and SnackBar shows the user's custom category
    expect(find.byType(QuickManualEntrySheet), findsNothing);
    expect(find.text('Berhasil Catat Pengeluaran'), findsOneWidget);
    expect(find.textContaining('Beli Saus Pedas'), findsOneWidget);
  });
}
