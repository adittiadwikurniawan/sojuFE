// Widget test: layar prototype chat input penjualan harian/shift.
//
// Fokus pada label demo, draft contoh, validasi, koreksi lokal, dan simulasi
// konfirmasi. Tidak ada request jaringan pada seluruh test ini.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/data/datasources/mock/sales_chat_mock_datasource.dart';
import 'package:soju_fe/domain/entities/sales_chat_entity.dart';
import 'package:soju_fe/domain/repositories/sales_chat_repository.dart';
import 'package:soju_fe/domain/usecases/sales_chat_usecases.dart';
import 'package:soju_fe/presentation/providers/sales_chat/sales_chat_controller.dart';
import 'package:soju_fe/presentation/screens/prototype/sales_chat/sales_chat_prototype_screen.dart';

class _FakeSalesChatRepository implements SalesChatRepository {
  _FakeSalesChatRepository(this.draft);

  final SalesChatDraft? draft;
  int calls = 0;

  @override
  Future<Result<SalesChatDraft?>> parseRecap(String input) async {
    calls++;
    return Result<SalesChatDraft?>.success(draft);
  }
}

Future<_FakeSalesChatRepository> _pumpPrototype(
  WidgetTester tester, {
  SalesChatDraft? initialDraft,
  bool seedDraft = true,
  SalesChatDraft? parsedDraft,
  bool parseDraft = true,
}) async {
  final _FakeSalesChatRepository repository = _FakeSalesChatRepository(
    parseDraft ? (parsedDraft ?? SalesChatMockDataSource.sampleDraft) : null,
  );
  final SalesChatDraft? seed =
      seedDraft ? (initialDraft ?? SalesChatMockDataSource.sampleDraft) : null;
  await tester.pumpWidget(
    MaterialApp(
      home: SalesChatPrototypeScreen(
        controllerFactory: () => SalesChatController(
          parseRecap: ParseSalesChatRecap(repository),
          initialDraft: seed,
          now: () => DateTime(2026, 11, 19, 14, 8),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('menampilkan identitas Soju, badge Pratinjau, dan mode demo', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPrototype(tester);

    expect(find.text('Penjualan Harian/Shift'), findsOneWidget);
    expect(find.text('Pratinjau'), findsOneWidget);
    expect(find.text('Soju'), findsWidgets);
    expect(find.text('Mode demo — data tidak disimpan'), findsOneWidget);
    expect(
      find.text(
        'Percakapan dan draft di layar ini adalah contoh. Tidak ada '
        'request ke AI dan tidak ada transaksi yang masuk ke pembukuan.',
      ),
      findsOneWidget,
    );
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
    expect(find.byIcon(Icons.more_horiz), findsNothing);
  });

  testWidgets('composer tetap ringkas dan memakai placeholder yang diminta', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPrototype(tester);

    expect(
      find.text('Tempel rekap penjualan atau chat pesanan WhatsApp'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('sales_chat_composer'))).height,
      lessThan(100),
    );
  });

  testWidgets('layout sempit 360 px tetap tanpa overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPrototype(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Penjualan Harian/Shift'), findsOneWidget);
    expect(find.byKey(const Key('sales_chat_composer')), findsOneWidget);
  });

  testWidgets('composer tetap di atas keyboard', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);

    await _pumpPrototype(tester);
    final double devicePixelRatio = tester.view.devicePixelRatio;
    tester.view.viewInsets = FakeViewPadding(
      bottom: 300 * devicePixelRatio,
    );
    await tester.pumpAndSettle();

    final Rect composer = tester.getRect(
      find.byKey(const Key('sales_chat_composer')),
    );
    expect(composer.bottom, lessThanOrEqualTo(932 - 300 + 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('draft lengkap menampilkan total dan rincian pembayaran', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPrototype(tester);

    expect(find.text('Draft — belum disimpan'), findsOneWidget);
    expect(find.text('Rp 1.375.000'), findsWidgets);
    expect(find.text('Bento Ayam Bakar'), findsOneWidget);
    expect(find.text('Sosis Keju'), findsOneWidget);
    expect(find.text('Es Teh Manis'), findsOneWidget);
    expect(find.text('QRIS'), findsWidgets);
    expect(find.text('Tunai'), findsWidgets);
    expect(find.text('Perlu dilengkapi'), findsNothing);
    expect(find.text('Draft siap disimulasikan'), findsOneWidget);
  });

  testWidgets('konfirmasi draft lengkap hanya menampilkan simulasi', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPrototype(tester);

    final Finder confirm = find.byKey(const Key('sales_draft_confirm'));
    await tester.ensureVisible(confirm);
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(
      find.text('Simulasi selesai — tidak masuk ke pembukuan.'),
      findsWidgets,
    );
    expect(find.text('Simulasi selesai'), findsOneWidget);
    expect(find.text('Draft — belum disimpan'), findsOneWidget);
  });

  testWidgets(
      'draft belum lengkap tidak bisa dikonfirmasi dan tidak mengarang nilai', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPrototype(
      tester,
      initialDraft: SalesChatMockDataSource.incompleteSampleDraft,
    );

    expect(find.text('Perlu dilengkapi'), findsOneWidget);
    expect(find.text('Metode pembayaran'), findsOneWidget);
    expect(find.text('Shift'), findsOneWidget);
    expect(find.text('Belum diisi'), findsWidgets);

    final Finder confirm = find.byKey(const Key('sales_draft_confirm'));
    await tester.ensureVisible(confirm);
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(
      find.text('Simulasi selesai — tidak masuk ke pembukuan.'),
      findsNothing,
    );
    expect(find.text('Simulasi selesai'), findsNothing);
  });

  testWidgets('koreksi shift mengubah draft lokal tanpa memanggil parser', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final _FakeSalesChatRepository repository = await _pumpPrototype(tester);

    final Finder correct = find.byKey(const Key('sales_draft_correct'));
    await tester.ensureVisible(correct);
    await tester.pumpAndSettle();
    await tester.tap(correct);
    await tester.pumpAndSettle();

    expect(find.text('Koreksi draft'), findsOneWidget);
    expect(find.text('Perubahan hanya di sesi prototype'), findsOneWidget);

    final Finder shiftField = find.descendant(
      of: find.byKey(const Key('draft_editor_shift')),
      matching: find.byType(TextField),
    );
    await tester.enterText(shiftField, 'Malam');
    await tester.tap(find.byKey(const Key('draft_editor_save')));
    await tester.pumpAndSettle();

    expect(find.text('Shift Malam'), findsOneWidget);
    expect(find.text('Koreksi draft'), findsNothing);
    expect(repository.calls, 0);
  });

  testWidgets('sheet koreksi tetap muat di layar 360 px', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPrototype(tester);

    final Finder correct = find.byKey(const Key('sales_draft_correct'));
    await tester.ensureVisible(correct);
    await tester.pumpAndSettle();
    await tester.tap(correct);
    await tester.pumpAndSettle();

    expect(find.text('Koreksi draft'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final Finder shiftField = find.descendant(
      of: find.byKey(const Key('draft_editor_shift')),
      matching: find.byType(TextField),
    );
    await tester.enterText(shiftField, 'Malam');
    await tester.tap(find.byKey(const Key('draft_editor_save')));
    await tester.pumpAndSettle();

    expect(find.text('Shift Malam'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mengirim rekap contoh menambahkan balasan dan draft baru', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final _FakeSalesChatRepository repository = await _pumpPrototype(
      tester,
      seedDraft: false,
    );

    await tester.enterText(
      find.byKey(const Key('sales_chat_input')),
      SalesChatController.sampleRecapInput,
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('sales_chat_send')));
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(
      find.text(
        'Ini draft contoh dari data demo. Periksa dan lengkapi sebelum '
        'konfirmasi simulasi.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('sales_draft_card')), findsOneWidget);
  });

  testWidgets('input bebas tidak dipaksa menjadi draft', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPrototype(
      tester,
      seedDraft: false,
      parseDraft: false,
    );

    await tester.enterText(
      find.byKey(const Key('sales_chat_input')),
      'Halo, ini bukan rekap penjualan.',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('sales_chat_send')));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('rekap ini belum bisa dibaca'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('sales_draft_card')), findsNothing);
  });
}
