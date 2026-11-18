import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/soju_colors.dart';
import '../../data/data_providers.dart';
import '../../data/datasources/mock/audit_mock_datasource.dart';
import '../../data/repositories/audit_repository_impl.dart';
import '../../domain/usecases/audit_usecases.dart';
import '../../presentation/providers/audit/audit_log_controller.dart';
import '../../presentation/providers/free_tables/free_table_category_controller.dart';
import '../../presentation/screens/activities/activities_screen.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';
import '../../presentation/screens/audit/audit_screen.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/widgets/auth_header.dart';
import '../../presentation/screens/chatbot/chatbot_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/free_tables/free_table_category_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/splash_screen.dart';
import '../../presentation/widgets/bottom_glass_overlay.dart';
import '../../presentation/widgets/bottom_nav_bar.dart';

/// Segment rute aplikasi.
abstract final class AppRoutes {
  /// Layar splash / sambutan.
  static const String splash = '/splash';

  /// Carousel onboarding.
  static const String onboarding = '/onboarding';

  /// Masuk ke akun yang sudah ada.
  static const String login = '/login';

  /// Pendaftaran akun baru.
  static const String register = '/register';

  /// Permintaan tautan reset password.
  static const String forgotPassword = '/forgot-password';

  /// Beranda (ringkasan dashboard) setelah pendaftaran.
  static const String dashboard = '/dashboard';

  /// Analitik arus kas: ditampilkan pada tab Analytics (mock, tanpa API).
  static const String analytics = '/analytics';

  /// Chatbot Soju: tab "Ai Asistant" pada navbar Figma (mock, tanpa API).
  static const String chatbot = '/chatbot';

  /// Audit & Stok: log aktivitas baca-saja (mock Phase A).
  static const String audit = '/audit';

  /// Daftar notifikasi (frame `546:1841`), di luar shell tanpa navbar.
  static const String notifications = '/notifications';

  /// Daftar lengkap aktivitas dari tautan "Lihat Semua".
  static const String activities = '/activities';

  /// Modal form Buat Kategori Baru Tabel Bebas (frame `546:5163`).
  static const String freeTableCreate = '/free-tables/create';

  /// Modal form Buat Kategori Baru dari tombol `+` navbar (frame `546:5430`).
  static const String categoryCreate = '/categories/create';
}

/// Konfigurasi GoRouter aplikasi (lihat `ARCHITECTURE.md` §2.4).
///
/// Redirect auth-aware belum dipasang; akan ditambahkan saat slicing auth.
abstract final class AppRouter {
  /// Membuat instance [GoRouter].
  ///
  /// [initialLocation] dapat diubah untuk deep link maupun pengujian.
  static GoRouter create({String initialLocation = AppRoutes.splash}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        // Path root dipakai browser/web dan beberapa platform saat aplikasi
        // dibuka pertama kali. Tanpa redirect ini GoRouter tidak punya rute
        // yang cocok dan layar tampil kosong.
        GoRoute(
          path: '/',
          redirect: (BuildContext context, GoRouterState state) =>
              AppRoutes.splash,
        ),
        GoRoute(
          path: AppRoutes.splash,
          builder: (BuildContext context, GoRouterState state) =>
              const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (BuildContext context, GoRouterState state) =>
              const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (BuildContext context, GoRouterState state) =>
              _authScreen(context, AuthTab.login),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (BuildContext context, GoRouterState state) =>
              _authScreen(context, AuthTab.register),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (BuildContext context, GoRouterState state) =>
              ForgotPasswordScreen(
            onCancel: () => context.go(AppRoutes.login),
            onBackToLogin: () => context.go(AppRoutes.login),
            // onSendResetLink diisi saat lapisan data tersedia.
          ),
        ),
        // Notifikasi di luar shell: frame Figma `546:1841` tidak memuat
        // navbar, hanya header dengan tombol kembali.
        GoRoute(
          path: AppRoutes.notifications,
          builder: (BuildContext context, GoRouterState state) =>
              NotificationsScreen(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboard);
              }
            },
            // Aksi rekonsiliasi membuka Analytics.
            onReconcile: () => context.go(AppRoutes.analytics),
          ),
        ),
        // Daftar aktivitas "Lihat Semua": halaman drill-down di luar shell,
        // sehingga tidak ada navbar dan tombol kembali selalu tersedia.
        GoRoute(
          path: AppRoutes.activities,
          builder: (BuildContext context, GoRouterState state) =>
              ActivitiesScreen(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboard);
              }
            },
          ),
        ),
        // Modal Tabel Bebas di luar shell: tidak memakai navbar dan boleh
        // dibuka dari layar mana pun saat entry point tersedia.
        GoRoute(
          path: AppRoutes.freeTableCreate,
          builder: (BuildContext context, GoRouterState state) =>
              FreeTableCategoryScreen(
            onClose: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboard);
              }
            },
            // Phase A: mock. Phase B: ganti factory di DataProviders.
            controllerFactory: () => FreeTableCategoryController(
              createCategory: DataProviders.createFreeTableCategory(),
            ),
          ),
        ),
        // Modal Buat Kategori Baru dari tombol `+` navbar (frame `546:5430`).
        // Phase A tetap mock: tidak ada endpoint mutasi yang dipanggil.
        GoRoute(
          path: AppRoutes.categoryCreate,
          builder: (BuildContext context, GoRouterState state) =>
              FreeTableCategoryScreen(
            onClose: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboard);
              }
            },
            controllerFactory: () => FreeTableCategoryController(
              createCategory: DataProviders.createFreeTableCategory(),
              initialState: const FreeTableCategoryState.incomeExample(),
            ),
          ),
        ),
        // Navbar Figma `801:4265`: Home, Analytics, +, Ai Asistant, Audit & Stok.
        // Empat tab berlabel memakai satu shell internal (ARCHITECTURE.md §2.4);
        // splash dan auth tetap di luar shell (layar penuh).
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return _BukuDapurShell(
              activeTab: _bottomNavTabFor(state.uri.path),
              child: child,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (BuildContext context, GoRouterState state) =>
                  DashboardScreen(
                onSeeAllActivities: () => context.push(AppRoutes.activities),
                onAnalyticsTap: () => context.go(AppRoutes.analytics),
                onNotificationTap: () => context.push(AppRoutes.notifications),
                onQuickCommand: (_) {
                  context.push(AppRoutes.chatbot);
                },
                onSendCommand: (_) {
                  context.push(AppRoutes.chatbot);
                },
                onLogout: () => context.go(AppRoutes.login),
              ),
            ),
            GoRoute(
              path: AppRoutes.analytics,
              builder: (BuildContext context, GoRouterState state) =>
                  AnalyticsScreen(
                onNotificationTap: () => context.push(AppRoutes.notifications),
                onAddTap: () => context.push(AppRoutes.categoryCreate),
                onSeeAllActivities: () => context.push(AppRoutes.activities),
                onLogout: () => context.go(AppRoutes.login),
              ),
            ),
            GoRoute(
              path: AppRoutes.chatbot,
              builder: (BuildContext context, GoRouterState state) =>
                  ChatbotScreen(
                onBack: () => context.go(AppRoutes.dashboard),
                onNotificationTap: () => context.push(AppRoutes.notifications),
              ),
            ),
            GoRoute(
              path: AppRoutes.audit,
              builder: (BuildContext context, GoRouterState state) =>
                  AuditScreen(
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.dashboard);
                  }
                },
                // Phase A: data mock. Phase B: ganti hanya factory ini ke
                // repository REST — UI, usecase, dan entity tidak berubah.
                controllerFactory: () => AuditLogController(
                  getAuditLogs: GetAuditLogs(
                    AuditRepositoryImpl(AuditMockDataSource()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Menentukan tab navbar aktif dari lokasi URI saat ini.
  static BottomNavTab _bottomNavTabFor(String path) {
    final String location = path.length > 1 && path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    return switch (location) {
      AppRoutes.analytics => BottomNavTab.analytics,
      AppRoutes.chatbot => BottomNavTab.aiAssistant,
      AppRoutes.audit => BottomNavTab.audit,
      _ => BottomNavTab.home,
    };
  }

  /// Rute tujuan untuk setiap tab navbar.
  static String _pathFor(BottomNavTab tab) => switch (tab) {
        BottomNavTab.home => AppRoutes.dashboard,
        BottomNavTab.analytics => AppRoutes.analytics,
        BottomNavTab.aiAssistant => AppRoutes.chatbot,
        BottomNavTab.audit => AppRoutes.audit,
      };

  /// Layar auth berisi tab Masuk dan Daftar; [initialTab] menentukan tab awal.
  static Widget _authScreen(BuildContext context, AuthTab initialTab) {
    return AuthScreen(
      initialTab: initialTab,
      // Masuk/daftar berhasil -> buka beranda.
      onLoginSubmit: (_) => context.go(AppRoutes.dashboard),
      onRegisterSubmit: (_) => context.go(AppRoutes.dashboard),
      onForgotPassword: () => context.go(AppRoutes.forgotPassword),
    );
  }
}

/// Shell internal yang memasang navbar Figma `801:4265`.
///
/// Navbar berada di `bottomNavigationBar` Scaffold sehingga selalu menempel
/// di bawah layar; lebar dibatasi 480px dan dirata-tengah seperti konten
/// layar lainnya. Safe area ditangani oleh [BukuDapurBottomNavBar].
class _BukuDapurShell extends StatelessWidget {
  const _BukuDapurShell({required this.activeTab, required this.child});

  final BottomNavTab activeTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double scale = (width > 480 ? 480 : width) / 430;

    return Scaffold(
      // Navbar punya area transparan 30 px di atas bar putih. Samakan dengan
      // latar layar agar tidak muncul strip putih kosong di atas navbar.
      backgroundColor: SojuColors.homeBackground,
      // Body ikut turun di belakang navbar supaya lapisan kaca dapat
      // memblur konten yang sedang digulir.
      extendBody: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: child),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: BottomGlassOverlay(scale: scale),
            ),
          ),
        ],
      ),
      // `Center(heightFactor: 1)` penting: `Align` tanpa heightFactor akan
      // mengembang setinggi Scaffold dan membuat body berukuran 0 px.
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: BukuDapurBottomNavBar(
            activeTab: activeTab,
            onTabSelected: (BottomNavTab tab) {
              context.go(AppRouter._pathFor(tab));
            },
            // Tombol "+" membuka form kategori Phase A (frame `546:5430`).
            // Form hanya mengirim draf ke datasource mock; belum ada HTTP.
            onAddTap: () => context.push(AppRoutes.categoryCreate),
          ),
        ),
      ),
    );
  }
}
