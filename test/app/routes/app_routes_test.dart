// Widget test: GoRouter sadar-peran (CUSTOMER, ADMIN, SUPER_ADMIN),
// Dual ShellRoute 5-tab, Admin Drawer gating, dan rute drill-down.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:soju_fe/app/routes/app_routes.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/core/themes/app_theme.dart';
import 'package:soju_fe/core/themes/soju_colors.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/domain/repositories/auth_repository.dart';
import 'package:soju_fe/domain/repositories/storefront_repository.dart';
import 'package:soju_fe/domain/usecases/auth_usecases.dart';
import 'package:soju_fe/domain/usecases/storefront_usecases.dart';
import 'package:soju_fe/presentation/providers/auth/auth_controller.dart';
import 'package:soju_fe/presentation/providers/storefront/customer_cart_controller.dart';
import 'package:soju_fe/presentation/screens/activities/activities_screen.dart';
import 'package:soju_fe/presentation/screens/analytics/analytics_screen.dart';
import 'package:soju_fe/presentation/screens/analytics/widgets/analytics_top_bar.dart';
import 'package:soju_fe/presentation/screens/audit/audit_screen.dart';
import 'package:soju_fe/presentation/screens/audit/widgets/audit_top_bar.dart';
import 'package:soju_fe/presentation/screens/chatbot/chatbot_screen.dart';
import 'package:soju_fe/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:soju_fe/presentation/screens/free_tables/free_table_category_screen.dart';
import 'package:soju_fe/presentation/screens/notifications/notifications_screen.dart';
import 'package:soju_fe/presentation/screens/profile/change_password_screen.dart';
import 'package:soju_fe/presentation/screens/profile/help_detail_screen.dart';
import 'package:soju_fe/presentation/screens/profile/help_topics_screen.dart';
import 'package:soju_fe/presentation/screens/profile/notification_preferences_screen.dart';
import 'package:soju_fe/presentation/screens/profile/profile_account_screen.dart';
import 'package:soju_fe/presentation/screens/profile/profile_screen.dart';
import 'package:soju_fe/presentation/screens/profile/profile_settings_screen.dart';
import 'package:soju_fe/presentation/screens/profile/terms_screen.dart';
import 'package:soju_fe/presentation/widgets/admin_drawer.dart';
import 'package:soju_fe/presentation/widgets/bottom_nav_bar.dart';
import 'package:soju_fe/presentation/widgets/customer_bottom_nav_bar.dart';
import 'package:soju_fe/presentation/widgets/profile/profile_top_bar.dart';

class _FakeRouteAuthRepository implements AuthRepository {
  _FakeRouteAuthRepository({this.restoredUser});

  AuthUser? restoredUser;
  AuthSession? loginSession;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    final AuthSession? session = loginSession;
    if (session == null) {
      return Result<AuthSession>.failure(
        const UnauthorizedFailure(message: 'Email atau password salah.'),
      );
    }
    return Result<AuthSession>.success(session);
  }

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    bool promotionAllowed = false,
  }) async {
    return Result<AuthSession>.success(
      AuthSession(
        token: 'customer-token',
        user: AuthUser(
          id: 99,
          name: name,
          email: email,
          role: UserRole.customer,
          phone: phone,
          address: address,
          promotionAllowed: promotionAllowed,
        ),
      ),
    );
  }

  @override
  Future<Result<String>> requestPasswordReset({
    required String email,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    return Result<String>.success(
      'Jika email terdaftar, tautan reset password telah dikirim.',
    );
  }

  @override
  Future<Result<String>> resetPassword({
    required String token,
    required String newPassword,
    AuthPortal portal = AuthPortal.admin,
  }) async {
    return Result<String>.success('Password berhasil diatur ulang.');
  }

  @override
  Future<Result<AuthUser>> me({UserRole? role}) async {
    final AuthUser? user = restoredUser;
    if (user == null) {
      return Result<AuthUser>.failure(const UnauthorizedFailure());
    }
    return Result<AuthUser>.success(user);
  }

  @override
  Future<Result<AuthUser>> restoreSession() async {
    final AuthUser? user = restoredUser;
    if (user == null) {
      return Result<AuthUser>.failure(const UnauthorizedFailure());
    }
    return Result<AuthUser>.success(user);
  }

  @override
  Future<Result<void>> logout() async {
    restoredUser = null;
    return Result<void>.success(null);
  }
}

Future<AuthController> _createBootstrappedAuth({AuthUser? user}) async {
  final _FakeRouteAuthRepository repo = _FakeRouteAuthRepository(
    restoredUser: user,
  );
  final AuthController controller = AuthController(
    login: Login(repo),
    register: Register(repo),
    requestPasswordReset: RequestPasswordReset(repo),
    resetPassword: ResetPassword(repo),
    restoreSession: RestoreSession(repo),
    logout: Logout(repo),
  );
  await controller.bootstrap();
  return controller;
}

const AuthUser _customerUser = AuthUser(
  id: 10,
  name: 'Siti Rahma',
  email: 'siti@pelanggan.id',
  role: UserRole.customer,
  phone: '081234567890',
  address: 'Jl. Dago No. 12, Bandung',
);

const AuthUser _adminUser = AuthUser(
  id: 2,
  name: 'Raka Operasional',
  email: 'raka@sojucorp.com',
  role: UserRole.admin,
);

const AuthUser _superAdminUser = AuthUser(
  id: 1,
  name: 'Dea Super Admin',
  email: 'dea@sojucorp.com',
  role: UserRole.superAdmin,
);

void main() {
  testWidgets('lokasi root diarahkan ke Beranda Tamu SOJU, bukan layar kosong', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(initialLocation: '/');
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer_home_screen')), findsOneWidget);
    expect(find.text('Menu Unggulan ★'), findsOneWidget);
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
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alat Cepat'), findsOneWidget);
    expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);
    expect(find.byKey(const Key('bottom_glass_overlay')), findsNothing);
    expect(find.byKey(const Key('bottom_nav_glass')), findsNothing);

    tester.widget<ChatbotScreen>(find.byType(ChatbotScreen)).onBack!();
    await tester.pumpAndSettle();

    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Alat Cepat'), findsNothing);
    expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);
    expect(find.byKey(const Key('bottom_glass_overlay')), findsOneWidget);
    expect(find.byKey(const Key('bottom_nav_glass')), findsOneWidget);
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
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AuditScreen), findsOneWidget);
    expect(find.text('Audit & Stok'), findsWidgets);
    expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);

    tester.widget<AuditTopBar>(find.byType(AuditTopBar)).onBack!();
    await tester.pumpAndSettle();

    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.byType(AuditTopBar), findsNothing);
    expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);
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
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
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
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
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

  testWidgets('Lihat Semua aktivitas dari Data/Analytics membuka daftar', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.data,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Lihat Semua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);
  });

  testWidgets('tombol tambah Analytics membuka popup tanpa pindah rute', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.analytics,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(AnalyticsTopBar),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsOneWidget);
    expect(
      find.text('Atur pos pembukuan pemasukan & custom field'),
      findsOneWidget,
    );
    expect(router.state.uri.path, AppRoutes.analytics);

    await tester.tap(find.byKey(const Key('free_table_save_button')));
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsNothing);
    expect(router.state.uri.path, AppRoutes.analytics);
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
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsOneWidget);
    expect(find.text('Buat Kategori Baru'), findsOneWidget);
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
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FreeTableCategoryScreen), findsOneWidget);
    expect(
      find.text('Atur pos pembukuan pemasukan & custom field'),
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
    expect(find.text('Aktivitas'), findsOneWidget);
  });

  final Map<String, String> adminTabRoutes = <String, String>{
    AppRoutes.dashboard: 'Home',
    AppRoutes.analytics: 'Analytics',
    AppRoutes.chatbot: 'Ai Asistant',
    AppRoutes.audit: 'Audit & Stok',
  };
  for (final MapEntry<String, String> entry in adminTabRoutes.entries) {
    testWidgets(
      'Shell Admin menandai tab ${entry.value} sebagai aktif pada navbar Figma',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final GoRouter router = AppRouter.create(
          initialLocation: entry.key,
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
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
        expect(activeLabel.style?.color, SojuColors.brandNavy);
      },
    );
  }

  final Map<String, String> customerTabRoutes = <String, String>{
    AppRoutes.customerHome: 'Beranda',
    AppRoutes.customerMenu: 'Menu',
    AppRoutes.customerCart: 'Keranjang',
    AppRoutes.customerOrders: 'Pesanan',
    AppRoutes.customerAccount: 'Akun',
  };
  for (final MapEntry<String, String> entry in customerTabRoutes.entries) {
    testWidgets(
      'Shell Pelanggan menandai tab ${entry.value} sebagai aktif (5-tab)',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final AuthController auth = await _createBootstrappedAuth(
          user: _customerUser,
        );
        addTearDown(auth.dispose);

        final GoRouter router = AppRouter.create(
          initialLocation: entry.key,
          authController: auth,
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        final Finder nav = find.byType(CustomerBottomNavBar);
        expect(nav, findsOneWidget);
        expect(find.byType(BukuDapurBottomNavBar), findsNothing);

        final Iterable<Text> labels = tester.widgetList<Text>(
          find.descendant(of: nav, matching: find.byType(Text)),
        );
        expect(
          labels.map((Text text) => text.data).toList(),
          <String?>['Beranda', 'Menu', 'Keranjang', 'Pesanan', 'Akun'],
        );

        final Text activeLabel = tester.widget<Text>(
          find.descendant(of: nav, matching: find.text(entry.value)),
        );
        expect(activeLabel.style?.color, SojuColors.brandNavy);
      },
    );
  }

  testWidgets('mengetuk tab navbar Figma Shell Admin berpindah rute dengan mulus', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.dashboard,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    final Finder nav = find.byType(BukuDapurBottomNavBar);
    final Scaffold shell = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(shell.backgroundColor, SojuColors.homeBackground);
    expect(shell.extendBody, isTrue);
    expect(find.byKey(const Key('bottom_glass_overlay')), findsOneWidget);
    expect(tester.getSize(nav).height, lessThan(200));
    expect(
      tester.getSize(find.byType(DashboardScreen)).height,
      greaterThan(0),
    );

    await tester.tap(find.descendant(of: nav, matching: find.text('Analytics')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.analytics);
    expect(find.byType(AnalyticsScreen), findsOneWidget);

    await tester.tap(
      find.descendant(of: nav, matching: find.text('Ai Asistant')),
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.chatbot);
    expect(find.text('Alat Cepat'), findsOneWidget);

    await tester.tap(
      find.descendant(of: nav, matching: find.text('Audit & Stok')),
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.audit);
    expect(find.byType(AuditScreen), findsOneWidget);

    await tester.tap(find.descendant(of: nav, matching: find.text('Home')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.dashboard);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('prototype chat penjualan tidak muncul di navigasi produksi', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.dashboard,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);
    expect(find.text('Penjualan Harian/Shift'), findsNothing);
    expect(find.text('Pratinjau'), findsNothing);
  });

  testWidgets('avatar Beranda membuka menu profil, lalu detail Profil', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.dashboard,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);

    await tester.tap(find.byKey(const Key('dashboard_avatar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_menu_card')), findsOneWidget);
    expect(find.text('Lihat Profil'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.dashboard);

    await tester.tap(find.byKey(const Key('profile_view_profile')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);
    expect(find.text('Akun Saya'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Pusat Bantuan'), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.profile);
  });

  testWidgets('tombol kembali Analytics membuka Beranda, bukan Profil', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.analytics,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('analytics_back')), findsOneWidget);
    expect(find.byKey(const Key('analytics_avatar')), findsNothing);

    await tester.tap(find.byKey(const Key('analytics_back')));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(router.state.uri.path, AppRoutes.dashboard);
  });

  testWidgets('menu profil membuka Akun Saya, Pengaturan, dan Pusat Bantuan', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.profile,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_account_menu')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileAccountScreen), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('No Telepon'), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.profileAccount);

    tester.widget<ProfileTopBar>(find.byType(ProfileTopBar)).onBack!();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_settings_menu')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSettingsScreen), findsOneWidget);
    expect(find.text('Ganti Password'), findsOneWidget);
    expect(find.text('Pemberitahuan'), findsOneWidget);
    expect(find.text('Syarat & Ketentuan'), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.profileSettings);

    await tester.tap(find.byKey(const Key('profile_change_password')));
    await tester.pumpAndSettle();
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.profileChangePassword);

    tester.widget<ProfileTopBar>(find.byType(ProfileTopBar)).onBack!();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_notifications')));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationPreferencesScreen), findsOneWidget);
    expect(find.text('Stok Menipis'), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.profileNotifications);

    tester.widget<ProfileTopBar>(find.byType(ProfileTopBar)).onBack!();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_terms')));
    await tester.pumpAndSettle();
    expect(find.byType(TermsScreen), findsOneWidget);
    expect(find.text('1. Penggunaan Aplikasi'), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.profileTerms);

    tester.widget<ProfileTopBar>(find.byType(ProfileTopBar)).onBack!();
    await tester.pumpAndSettle();

    tester.widget<ProfileTopBar>(find.byType(ProfileTopBar)).onBack!();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_help_menu')));
    await tester.pumpAndSettle();

    expect(find.byType(HelpTopicsScreen), findsOneWidget);
    expect(find.text('Topik'), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.profileHelp);

    await tester.tap(
      find.byKey(const Key('help_featured_topic_topik-transaksi')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HelpDetailScreen), findsOneWidget);
    expect(find.text('Topik Detail'), findsOneWidget);
    expect(
      router.state.uri.path,
      AppRoutes.profileHelpArticle('topik-transaksi'),
    );
  });

  testWidgets('perubahan Akun Saya terlihat lagi di layar Profil', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.profile,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_account_menu')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('profile_name_field')),
      'Soju Corp',
    );
    await tester.ensureVisible(find.byKey(const Key('profile_save_button')));
    await tester.tap(find.byKey(const Key('profile_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Profil berhasil disimpan.'), findsOneWidget);

    tester.widget<ProfileTopBar>(find.byType(ProfileTopBar)).onBack!();
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Soju Corp'), findsOneWidget);
    expect(find.text('adittia@sojucorp.com'), findsOneWidget);
  });

  testWidgets('rute detail bantuan membaca articleId dari path', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GoRouter router = AppRouter.create(
      initialLocation: AppRoutes.profileHelpArticle('topik-order'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HelpDetailScreen), findsOneWidget);
    expect(
      find.textContaining('Bagaimana cara mencatat order atau penjualan?'),
      findsOneWidget,
    );
    expect(find.byType(BukuDapurBottomNavBar), findsNothing);
  });

  // ===========================================================================
  // PENGUJIAN ROLE-AWARE GOROUTER, DUAL SHELLS & GATING (TASK-023)
  // ===========================================================================
  group('Role-Aware GoRouter & Dual Navigation Shells (TASK-023)', () {
    testWidgets(
      'akses tanpa autentikasi ke rute Admin, Super Admin, dan Pelanggan diarahkan ke /login',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final AuthController auth = await _createBootstrappedAuth();
        addTearDown(auth.dispose);

        final GoRouter router = AppRouter.create(
          initialLocation: AppRoutes.dashboard,
          authController: auth,
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(router.state.uri.path, AppRoutes.login);

        for (final String protectedRoute in <String>[
          AppRoutes.adminOrders,
          AppRoutes.data,
          AppRoutes.chatbot,
          AppRoutes.adminAccount,
          AppRoutes.audit,
          AppRoutes.adminUsers,
          AppRoutes.adminCms,
          AppRoutes.adminCrm,
          AppRoutes.customerCart,
          AppRoutes.customerCheckout,
          AppRoutes.customerOrders,
          AppRoutes.customerAccount,
        ]) {
          router.go(protectedRoute);
          await tester.pumpAndSettle();
          expect(
            router.state.uri.path,
            AppRoutes.login,
            reason: 'Rute $protectedRoute wajib diblokir saat belum login.',
          );
        }

        // Guest dapat mengakses Beranda & Katalog Menu tanpa login terlebih dahulu.
        for (final String guestRoute in <String>[
          AppRoutes.customerHome,
          AppRoutes.customerMenu,
        ]) {
          router.go(guestRoute);
          await tester.pumpAndSettle();
          expect(
            router.state.uri.path,
            guestRoute,
            reason: 'Rute publik $guestRoute seharusnya dapat dibuka tamu.',
          );
        }
      },
    );

    testWidgets(
      'CUSTOMER diarahkan ke Shell 5-tab Pelanggan dan diblokir dari rute Admin/Super Admin',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final AuthController auth = await _createBootstrappedAuth(
          user: _customerUser,
        );
        addTearDown(auth.dispose);

        final GoRouter router = AppRouter.create(
          initialLocation: AppRoutes.login,
          authController: auth,
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        // Otomatis diarahkan ke Beranda Pelanggan 5-tab.
        expect(router.state.uri.path, AppRoutes.customerHome);
        expect(find.byType(CustomerBottomNavBar), findsOneWidget);
        expect(find.byType(BukuDapurBottomNavBar), findsNothing);
        expect(find.textContaining('Halo, Siti Rahma!'), findsOneWidget);

        final Finder nav = find.byType(CustomerBottomNavBar);
        await tester.tap(find.descendant(of: nav, matching: find.text('Menu')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.customerMenu);

        await tester.tap(
          find.descendant(of: nav, matching: find.text('Keranjang')),
        );
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.customerCart);

        // Pelanggan dapat membuka Checkout lalu kembali.
        await tester.tap(find.byKey(const Key('customer_checkout_button')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.customerCheckout);
        expect(find.text('Checkout Pesanan'), findsOneWidget);

        await tester.tap(find.byKey(const Key('customer_checkout_back')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.customerCart);

        // Percobaan akses lintas peran ke Admin & Super Admin wajib diblokir.
        for (final String forbiddenRoute in <String>[
          AppRoutes.dashboard,
          AppRoutes.adminOrders,
          AppRoutes.data,
          AppRoutes.chatbot,
          AppRoutes.audit,
          AppRoutes.adminUsers,
          AppRoutes.adminCms,
          AppRoutes.adminCrm,
          AppRoutes.profile,
        ]) {
          router.go(forbiddenRoute);
          await tester.pumpAndSettle();
          expect(
            router.state.uri.path,
            AppRoutes.customerHome,
            reason:
                'Pelanggan tidak boleh mengakses rute Admin $forbiddenRoute.',
          );
        }

        // Logout dari tab Akun Pelanggan mengarahkan kembali ke /login.
        await tester.tap(find.descendant(of: nav, matching: find.text('Akun')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.customerAccount);

        await tester.tap(find.byKey(const Key('customer_logout_button')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.login);
      },
    );

    testWidgets(
      'ADMIN melihat Audit di Drawer tetapi tidak melihat dan ditolak dari Users, CMS, CRM, serta rute Pelanggan',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final AuthController auth = await _createBootstrappedAuth(
          user: _adminUser,
        );
        addTearDown(auth.dispose);

        final GoRouter router = AppRouter.create(
          initialLocation: AppRoutes.login,
          authController: auth,
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(router.state.uri.path, AppRoutes.dashboard);
        expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);
        expect(find.byType(CustomerBottomNavBar), findsNothing);

        // Buka Admin Drawer melalui tombol menu bilah atas.
        await tester.tap(find.byKey(const Key('admin_drawer_button')));
        await tester.pumpAndSettle();

        expect(find.byType(AdminDrawer), findsOneWidget);
        expect(find.text('Raka Operasional'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('admin_drawer_role_badge')),
            matching: find.text('Admin'),
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('admin_drawer_orders')), findsOneWidget);
        expect(find.byKey(const Key('admin_drawer_audit')), findsOneWidget);
        expect(find.text('Log Audit'), findsOneWidget);

        // Menu eksklusif SUPER_ADMIN wajib disembunyikan dari ADMIN.
        expect(find.byKey(const Key('admin_drawer_users')), findsNothing);
        expect(find.byKey(const Key('admin_drawer_cms')), findsNothing);
        expect(find.byKey(const Key('admin_drawer_crm')), findsNothing);
        expect(find.text('Kelola Pengguna'), findsNothing);
        expect(find.text('Konten CMS & Produk'), findsNothing);
        expect(find.text('Pelanggan & CRM'), findsNothing);

        // ADMIN dapat membuka Log Audit dari Drawer.
        await tester.tap(find.byKey(const Key('admin_drawer_audit')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.audit);
        expect(find.byType(AuditScreen), findsOneWidget);

        // Navigasi paksa ke rute SUPER_ADMIN maupun Pelanggan wajib diblokir.
        for (final String forbiddenRoute in <String>[
          AppRoutes.adminUsers,
          AppRoutes.adminCms,
          AppRoutes.adminCrm,
          AppRoutes.customerHome,
          AppRoutes.customerCart,
          AppRoutes.customerCheckout,
        ]) {
          router.go(forbiddenRoute);
          await tester.pumpAndSettle();
          expect(
            router.state.uri.path,
            AppRoutes.dashboard,
            reason: 'ADMIN wajib ditolak dari rute $forbiddenRoute.',
          );
        }
      },
    );

    testWidgets(
      'SUPER_ADMIN memiliki akses penuh ke Drawer (Audit, Users, CMS, CRM) namun tetap terisolasi dari rute Pelanggan',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final AuthController auth = await _createBootstrappedAuth(
          user: _superAdminUser,
        );
        addTearDown(auth.dispose);

        final GoRouter router = AppRouter.create(
          initialLocation: AppRoutes.splash,
          authController: auth,
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(router.state.uri.path, AppRoutes.dashboard);
        expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);

        // Buka Admin Drawer sebagai SUPER_ADMIN.
        await tester.tap(find.byKey(const Key('admin_drawer_button')));
        await tester.pumpAndSettle();

        expect(find.byType(AdminDrawer), findsOneWidget);
        expect(find.text('Dea Super Admin'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('admin_drawer_role_badge')),
            matching: find.text('Super Admin'),
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('admin_drawer_audit')), findsOneWidget);
        expect(find.byKey(const Key('admin_drawer_users')), findsOneWidget);
        expect(find.byKey(const Key('admin_drawer_cms')), findsOneWidget);
        expect(find.byKey(const Key('admin_drawer_crm')), findsOneWidget);

        // Buka halaman Users (SUPER_ADMIN).
        await tester.tap(find.byKey(const Key('admin_drawer_users')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.adminUsers);
        expect(find.byKey(const Key('admin_users_screen')), findsOneWidget);
        await tester.tap(find.byKey(const Key('super_admin_module_back')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.dashboard);

        // Buka halaman CMS (SUPER_ADMIN).
        await tester.tap(find.byKey(const Key('admin_drawer_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('admin_drawer_cms')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.adminCms);
        expect(find.byKey(const Key('admin_cms_screen')), findsOneWidget);
        await tester.tap(find.byKey(const Key('super_admin_module_back')));
        await tester.pumpAndSettle();

        // Buka halaman CRM (SUPER_ADMIN).
        await tester.tap(find.byKey(const Key('admin_drawer_button')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('admin_drawer_crm')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('admin_drawer_crm')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.adminCrm);
        expect(find.byKey(const Key('admin_crm_screen')), findsOneWidget);
        await tester.tap(find.byKey(const Key('super_admin_module_back')));
        await tester.pumpAndSettle();

        // Isolasi lintas peran tetap berlaku: SUPER_ADMIN tidak masuk ke Shell Pelanggan.
        for (final String customerRoute in <String>[
          AppRoutes.customerHome,
          AppRoutes.customerCheckout,
        ]) {
          router.go(customerRoute);
          await tester.pumpAndSettle();
          expect(router.state.uri.path, AppRoutes.dashboard);
        }
      },
    );

    testWidgets(
      'submit form Masuk mengarahkan Pelanggan ke /customer dan Admin ke /dashboard',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final _FakeRouteAuthRepository repo = _FakeRouteAuthRepository()
          ..loginSession = const AuthSession(
            token: 'cust-jwt',
            user: _customerUser,
          );
        final AuthController auth = AuthController(
          login: Login(repo),
          register: Register(repo),
          requestPasswordReset: RequestPasswordReset(repo),
          resetPassword: ResetPassword(repo),
          restoreSession: RestoreSession(repo),
          logout: Logout(repo),
        );
        addTearDown(auth.dispose);
        await auth.bootstrap();

        final GoRouter router = AppRouter.create(
          initialLocation: AppRoutes.login,
          authController: auth,
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('auth_portal_customer')));
        await tester.pump();
        await tester.enterText(
          find.byType(TextFormField).hitTestable().at(0),
          'siti@pelanggan.id',
        );
        await tester.enterText(
          find.byType(TextFormField).hitTestable().at(1),
          'rahasia123',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, AppRoutes.customerHome);
        expect(find.byType(CustomerBottomNavBar), findsOneWidget);

        await auth.logout();
        await tester.pumpAndSettle();
        // Setelah logout di Beranda Pelanggan, pengguna tetap dapat melihat etalase sebagai Tamu.
        expect(router.state.uri.path, AppRoutes.customerHome);

        router.go(AppRoutes.login);
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.login);

        repo.loginSession = const AuthSession(
          token: 'admin-jwt',
          user: _adminUser,
        );
        await tester.tap(find.byKey(const Key('auth_portal_admin')));
        await tester.pump();
        await tester.enterText(
          find.byType(TextFormField).hitTestable().at(0),
          'raka@sojucorp.com',
        );
        await tester.enterText(
          find.byType(TextFormField).hitTestable().at(1),
          'rahasia123',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, AppRoutes.dashboard);
        expect(find.byType(BukuDapurBottomNavBar), findsOneWidget);
      },
    );

    testWidgets(
      'Shell Pelanggan menampilkan badge keranjang live dari CustomerCartController bersama, sinkron antar rute, dan reset saat logout',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final _FakeShellStorefrontRepository cartRepo =
            _FakeShellStorefrontRepository();
        final CustomerCartController cartController = CustomerCartController(
          getCart: GetCart(cartRepo),
          saveCart: SaveCart(cartRepo),
        );
        addTearDown(cartController.dispose);

        final AuthController auth = await _createBootstrappedAuth(
          user: _customerUser,
        );
        addTearDown(auth.dispose);

        final GoRouter router = AppRouter.create(
          initialLocation: AppRoutes.customerMenu,
          authController: auth,
          cartController: cartController,
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        // 1. Initial: badge tidak tampil saat keranjang kosong (totalQuantity == 0)
        expect(find.byKey(const Key('customer_cart_badge')), findsNothing);

        // 2. Tambah produk: badge navbar muncul dengan angka live
        const CatalogProduct sample = CatalogProduct(
          id: 1,
          code: 'MN-1',
          name: 'Soju Peach',
          variants: <String>[],
          unit: 'Botol',
          price: 45000,
        );
        await cartController.addProduct(sample, quantity: 2);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('customer_cart_badge')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('customer_cart_badge')),
            matching: find.text('2'),
          ),
          findsOneWidget,
        );

        // 3. Pindah rute ke Keranjang via navbar: badge tetap sinkron dan item tampil
        await tester.tap(find.byKey(const Key('customer_nav_keranjang')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, AppRoutes.customerCart);
        expect(find.byKey(const Key('customer_cart_badge')), findsOneWidget);
        expect(find.byKey(const Key('customer_cart_item_0')), findsOneWidget);

        // 4. Hapus item di layar keranjang: badge navbar langsung hilang (0)
        await tester.tap(find.byKey(const Key('customer_cart_remove_0')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('customer_cart_badge')), findsNothing);
        expect(cartController.totalQuantity, 0);

        // 5. Tambah item lagi lalu logout: badge dan keranjang di-reset
        await cartController.addProduct(sample, quantity: 3);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('customer_cart_badge')), findsOneWidget);

        await auth.logout();
        await tester.pumpAndSettle();

        expect(router.state.uri.path, AppRoutes.login);
        expect(cartController.totalQuantity, 0);
        expect(cartController.isEmpty, isTrue);
        expect(find.byKey(const Key('customer_cart_badge')), findsNothing);
      },
    );
  });
}

class _FakeShellStorefrontRepository implements StorefrontRepository {
  List<CartItem> savedItems = <CartItem>[];

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search}) async =>
      Result<List<CatalogProduct>>.success(<CatalogProduct>[]);

  @override
  Future<Result<List<CartItem>>> fetchCart() async =>
      Result<List<CartItem>>.success(savedItems);

  @override
  Future<Result<int>> saveCart(List<CartItem> items) async {
    savedItems = List<CartItem>.of(items);
    return Result<int>.success(
      items.fold(0, (int sum, CartItem i) => sum + i.quantity),
    );
  }
}
