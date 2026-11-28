// test/presentation/screens/analytics/widgets/pendataan_tab_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/presentation/screens/analytics/widgets/pendataan_tab_view.dart';

void main() {
  testWidgets(
      'PendataanTabView validates empty table name, empty column name, and dropdown options', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: PendataanTabView(scale: 1.0),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open inline create table card
    await tester.tap(find.byKey(const Key('pendataan_create_table_button')));
    await tester.pumpAndSettle();

    // 1. Tap "+ Tambah Kolom" with empty column name -> shows explicit error
    final Finder addColBtn =
        find.byKey(const Key('pendataan_add_column_button'));
    await tester.ensureVisible(addColBtn);
    await tester.tap(addColBtn);
    await tester.pumpAndSettle();
    expect(
      find.text('Nama kolom wajib diisi sebelum menambah kolom.'),
      findsOneWidget,
    );

    // 2. Tap "Simpan Tabel" with empty table name -> shows explicit error
    final Finder saveTableBtn = find.text('Simpan Tabel');
    await tester.ensureVisible(saveTableBtn);
    await tester.tap(saveTableBtn);
    await tester.pumpAndSettle();
    expect(find.text('Nama tabel wajib diisi.'), findsOneWidget);

    // 3. Fill table name and add valid text column -> saves cleanly
    await tester.enterText(
      find.byKey(const Key('pendataan_table_name_field')),
      'Stok Sosis Frozen',
    );
    await tester.enterText(
      find.byKey(const Key('pendataan_col_name_field')),
      'Catatan',
    );
    await tester.ensureVisible(addColBtn);
    await tester.tap(addColBtn);
    await tester.pumpAndSettle();

    expect(find.text('Catatan (Teks)'), findsOneWidget);

    await tester.ensureVisible(saveTableBtn);
    await tester.tap(saveTableBtn);
    await tester.pumpAndSettle();

    expect(find.text('Stok Sosis Frozen'), findsOneWidget);
  });
}
