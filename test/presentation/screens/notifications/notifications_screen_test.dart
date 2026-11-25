// Widget test: layar Notifikasi (frame Figma `546:1841`).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/notifications/models/notifications_view_data.dart';
import 'package:soju_fe/presentation/screens/notifications/notifications_screen.dart';
import 'package:soju_fe/presentation/screens/notifications/widgets/notification_card.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    VoidCallback? onBack,
    VoidCallback? onReconcile,
    void Function(
      AppNotificationData notification,
      NotificationActionData action,
    )? onAction,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsScreen(
          onBack: onBack,
          onReconcile: onReconcile,
          onAction: onAction,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan banner, jumlah belum dibaca, dan tiga kartu', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('2 Tindakan Butuh Perhatian Segera'), findsOneWidget);
    expect(find.text('KRITIS'), findsOneWidget);
    expect(find.text('HARI INI'), findsOneWidget);
    expect(find.text('3 Belum Dibaca'), findsOneWidget);
    expect(find.byType(NotificationCard), findsNWidgets(3));

    expect(
      find.text('Peringatan Stok Kritis: Daging Ayam Fillet'),
      findsOneWidget,
    );
    expect(find.text('Selisih Kasir Shift Pagi Ditemukan'), findsOneWidget);
    expect(
      find.text('Jatuh Tempo Besok: Tagihan CV Subur Gas'),
      findsOneWidget,
    );
    expect(find.text('Abaikan'), findsOneWidget);
    expect(find.text('Pesan ke Supplier'), findsOneWidget);
    expect(find.text('Periksa & Sesuaikan'), findsOneWidget);
    expect(find.text('Bayar & Catat Kas'), findsOneWidget);
  });

  testWidgets('Abaikan menurunkan jumlah belum dibaca', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    final Finder dismiss = find.text('Abaikan');
    await tester.ensureVisible(dismiss);
    await tester.pumpAndSettle();
    await tester.tap(dismiss);
    await tester.pumpAndSettle();

    expect(find.text('2 Belum Dibaca'), findsOneWidget);
    expect(
      find.byKey(const Key('notification_unread_stock-critical')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('notification_unread_cash-difference')),
      findsOneWidget,
    );
  });

  testWidgets('aksi rekonsiliasi meneruskan callback', (
    WidgetTester tester,
  ) async {
    int reconcileCount = 0;
    await pumpScreen(
      tester,
      onReconcile: () => reconcileCount++,
    );

    await tester.tap(find.byKey(const Key('urgent_alert_action')));
    await tester.pumpAndSettle();
    expect(reconcileCount, 1);

    final Finder check = find.text('Periksa & Sesuaikan');
    await tester.ensureVisible(check);
    await tester.pumpAndSettle();
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(reconcileCount, 2);
  });

  testWidgets('aksi tanpa integrasi menampilkan pesan mode demo', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    final Finder supplier = find.text('Pesan ke Supplier');
    await tester.ensureVisible(supplier);
    await tester.pumpAndSettle();
    await tester.tap(supplier);
    await tester.pump();

    expect(
      find.text('Aksi "Pesan ke Supplier" belum tersambung ke API.'),
      findsOneWidget,
    );
  });

  testWidgets('tombol kembali memanggil callback', (
    WidgetTester tester,
  ) async {
    int backCount = 0;
    await pumpScreen(tester, onBack: () => backCount++);

    await tester.tap(find.byKey(const Key('notifications_back')));
    await tester.pump();

    expect(backCount, 1);
  });
}
