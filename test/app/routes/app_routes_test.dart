// Widget test: navbar Figma `801:4265` dan perilaku rute ShellRoute.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:soju_fe/app/routes/app_routes.dart';
import 'package:soju_fe/core/themes/soju_colors.dart';
import 'package:soju_fe/presentation/screens/activities/activities_screen.dart';
import 'package:soju_fe/presentation/screens/audit/widgets/audit_top_bar.dart';
import 'package:soju_fe/presentation/screens/chatbot/chatbot_screen.dart';
import 'package:soju_fe/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:soju_fe/presentation/screens/free_tables/free_table_category_screen.dart';
import 'package:soju_fe/presentation/screens/notifications/notifications_screen.dart';
import 'package:soju_fe/presentation/screens/onboarding/splash_screen.dart';
import 'package:soju_fe/presentation/widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('lokasi root diarahkan ke splash, bukan layar kosong', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(initialLocation: '/');
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });

  testWidgets('tombol kembali chatbot membuka Beranda saat tanpa riwayat', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.chatbot,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alat Cepat'), findsOneWidget);
    // "Ai Asistant" adalah tab navbar Figma, jadi navbar tetap terlihat.
    expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);

    // Panggil callback rute langsung agar test fokus pada wiring, bukan
    // hit-test bilah atas yang sedang bertransisi.
    tester.widget<ChatbotScreen>(find.byType(ChatbotScreen)).onBack!();
    await tester.pumpAndSettle();

    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Alat Cepat'), findsNothing);
    expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);
  });

  testWidgets('tombol kembali audit membuka Beranda saat tanpa riwayat', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.audit,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    // Label navbar dan judul halaman sama-sama memakai "Audit & Stok".
    expect(find.text('Audit & Stok'), findsNWidgets(2));
    // Memanggil callback langsung: yang diuji adalah wiring rute tombol kembali,
    // bukan mekanika hit-test GestureDetector pada bilah atas.
    tester.widget<AuditTopBar>(find.byType(AuditTopBar)).onBack!();
    await tester.pumpAndSettle();

    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.byType(AuditTopBar), findsNothing);
    // Label navbar tetap ada, tetapi halaman audit sudah tidak terbuka.
    expect(find.text('Audit & Stok'), findsOneWidget);
  });

  testWidgets('tombol notifikasi membuka halaman notifikasi tanpa navbar', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.dashboard,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('HARI INI'), findsOneWidget);
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);
    expect(find.byKey(const Key('bottom_glass_overlay')), findsNothing);

    await tester.tap(find.byKey(const Key('notifications_back')));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('Lihat Semua aktivitas membuka daftar tanpa navbar', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.dashboard,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Lihat Semua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.text('Semua Aktivitas'), findsOneWidget);
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);
    expect(find.byKey(const Key('bottom_glass_overlay')), findsNothing);

    await tester.tap(find.byKey(const Key('activities_back')));
    await tester.pumpAndSettle();

    expect(find.byType(ActivitiesScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('Lihat Semua aktivitas dari Analytics membuka daftar', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.analytics,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Lihat Semua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);
  });

  testWidgets('rute Tabel Bebas membuka modal tanpa navbar', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.freeTableCreate,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsOneWidget);
    expect(find.text('Buat Kategori Baru'), findsOneWidget);
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);

    // Tanpa riwayat, tombol tutup modal kembali ke Beranda.
    tester
        .widget<FreeTableCategoryScreen>(
          find.byType(FreeTableCategoryScreen),
        )
        .onClose!();
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsNothing);
    expect(find.text('Aktivitas'), findsOneWidget);
  });

  testWidgets('rute kategori pemasukan memakai form frame 546:5430', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.categoryCreate,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsOneWidget);
    expect(
      find.text('Atur pos pembukuan pemasukan & custom field'),
      findsOneWidget,
    );
    expect(find.text('Nama Klien / Pemesan'), findsOneWidget);
    expect(find.text('Metode Pembayaran'), findsOneWidget);
    expect(find.text('(Pilihan: BCA, QRIS, Tunai)'), findsOneWidget);
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);

    tester
        .widget<FreeTableCategoryScreen>(
          find.byType(FreeTableCategoryScreen),
        )
        .onClose!();
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsNothing);
    expect(find.text('Aktivitas'), findsOneWidget);
  });

  final Map<String, String> tabRoutes = <String, String>{
    AppRoutes.dashboard: 'Home',
    AppRoutes.analytics: 'Analytics',
    AppRoutes.chatbot: 'Ai Asistant',
    AppRoutes.audit: 'Audit & Stok',
  };
  for (final MapEntry<String, String> entry in tabRoutes.entries) {
    testWidgets('navbar menandai tab ${entry.value} sebagai aktif', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final GoRouter router = AppRouter.create(
        initialLocation: entry.key,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      final Finder nav = find.byType(BukuDapurBottomNavBar);
      expect(nav, findsOneWidget);

      final Iterable<Text> labels = tester.widgetList<Text>(
        find.descendant(of: nav, matching: find.byType(Text)),
      );
      expect(
        labels.map((Text text) => text.data).toList(),
        <String?>['Home', 'Analytics', 'Ai Asistant', 'Audit & Stok'],
      );

      final Text activeLabel = tester.widget<Text>(
        find.descendant(of: nav, matching: find.text(entry.value)),
      );
      expect(activeLabel.style?.color, SojuColors.primary);
      expect(
        find.descendant(of: nav, matching: find.byIcon(Icons.add)),
        findsOneWidget,
      );
    });
  }

  testWidgets('mengetuk tab navbar berpindah rute dan tombol tambah aman', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.dashboard,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    final Finder nav = find.byType(BukuDapurBottomNavBar);
    expect(find.text('Aktivitas'), findsOneWidget);
    // Shell tidak boleh memakai background putih default: area transparan
    // navbar akan terlihat sebagai strip putih kosong.
    final Scaffold shell = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(shell.backgroundColor, SojuColors.homeBackground);
    expect(shell.extendBody, isTrue);
    expect(find.byKey(const Key('bottom_glass_overlay')), findsOneWidget);
    expect(find.byType(BackdropFilter), findsWidgets);
    // Regresi: navbar tidak boleh mengembang memenuhi layar dan membuat body
    // Beranda setinggi 0 px (tampilan blank).
    expect(tester.getSize(nav).height, lessThan(200));
    expect(
      tester.getSize(find.byType(DashboardScreen)).height,
      greaterThan(0),
    );

    await tester.tap(
      find.descendant(of: nav, matching: find.text('Ai Asistant')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alat Cepat'), findsOneWidget);

    await tester.tap(
      find.descendant(of: nav, matching: find.text('Audit & Stok')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Log Aktivitas'), findsOneWidget);

    await tester.tap(find.descendant(of: nav, matching: find.text('Home')));
    await tester.pumpAndSettle();
    expect(find.text('Aktivitas'), findsOneWidget);

    // Tombol "+" membuka form kategori Phase A (frame `546:5430`).
    await tester.tap(find.byKey(const Key('bottom_nav_add')));
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsOneWidget);
    expect(
      find.text('Atur pos pembukuan pemasukan & custom field'),
      findsOneWidget,
    );
    expect(find.text('Rekomendasi Akun / Tagar'), findsOneWidget);
    expect(
      find.text('Simpan & Gunakan Kategori Pemasukan'),
      findsOneWidget,
    );
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);

    tester
        .widget<FreeTableCategoryScreen>(
          find.byType(FreeTableCategoryScreen),
        )
        .onClose!();
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
