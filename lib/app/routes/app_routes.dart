import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/soju_colors.dart';
import '../../data/data_providers.dart';
import '../config/app_features.dart';
import '../../data/datasources/mock/audit_mock_datasource.dart';
import '../../data/repositories/audit_repository_impl.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/usecases/audit_usecases.dart';
import '../../presentation/providers/audit/audit_log_controller.dart';
import '../../presentation/providers/auth/auth_controller.dart';
import '../../presentation/providers/free_tables/free_table_category_controller.dart';
import '../../presentation/providers/profile/change_password_controller.dart';
import '../../presentation/providers/profile/help_detail_controller.dart';
import '../../presentation/providers/profile/help_topics_controller.dart';
import '../../presentation/providers/profile/notification_preferences_controller.dart';
import '../../presentation/providers/profile/profile_controller.dart';
import '../../presentation/providers/sales_chat/sales_chat_controller.dart';
import '../../presentation/screens/activities/activities_screen.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';
import '../../presentation/screens/audit/audit_screen.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/models/login_form_data.dart';
import '../../presentation/screens/auth/models/register_form_data.dart';
import '../../presentation/screens/auth/models/reset_password_form_data.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';
import '../../presentation/screens/auth/widgets/auth_header.dart';
import '../../presentation/screens/chatbot/chatbot_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/free_tables/free_table_category_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/splash_screen.dart';
import '../../presentation/screens/profile/change_password_screen.dart';
import '../../presentation/screens/profile/help_detail_screen.dart';
import '../../presentation/screens/profile/help_topics_screen.dart';
import '../../presentation/screens/profile/notification_preferences_screen.dart';
import '../../presentation/screens/profile/profile_account_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/profile_settings_screen.dart';
import '../../presentation/screens/profile/terms_screen.dart';
import '../../presentation/screens/prototype/sales_chat/sales_chat_prototype_disabled_screen.dart';
import '../../presentation/screens/prototype/sales_chat/sales_chat_prototype_screen.dart';
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

  /// Pengaturan ulang password menggunakan token satu kali pakai.
  static const String resetPassword = '/reset-password';

  /// Beranda (ringkasan dashboard) setelah pendaftaran.
  static const String dashboard = '/dashboard';

  /// Analitik arus kas: ditampilkan pada tab Analytics (mock, tanpa API).
  static const String analytics = '/analytics';

  /// Chatbot Soju: tab "Ai Asistant" pada navbar Figma (mock, tanpa API).
  static const String chatbot = '/chatbot';

  /// Audit & Stok: log aktivitas baca-saja (mock Phase A).
  static const String audit = '/audit';

  /// Menu Profil (frame `546:5561`), di luar shell tanpa navbar.
  static const String profile = '/profile';

  /// Edit data akun dan foto profil (frame `546:5592`).
  static const String profileAccount = '/profile/account';

  /// Pengaturan akun (frame `546:5611`).
  static const String profileSettings = '/profile/settings';

  /// Form ganti password (mengikuti pola form auth).
  static const String profileChangePassword = '/profile/settings/password';

  /// Preferensi notifikasi (frame `546:5634`).
  static const String profileNotifications = '/profile/settings/notifications';

  /// Syarat & Ketentuan statis.
  static const String profileTerms = '/profile/settings/terms';

  /// Daftar topik Pusat Bantuan (frame `546:5647`).
  static const String profileHelp = '/profile/help';

  /// Detail artikel bantuan (frame `546:5686`).
  static const String profileHelpDetail = '/profile/help/:articleId';

  /// Rute detail artikel untuk [articleId].
  static String profileHelpArticle(String articleId) =>
      '$profileHelp/$articleId';

  /// Daftar notifikasi (frame `546:1841`), di luar shell tanpa navbar.
  static const String notifications = '/notifications';

  /// Daftar lengkap aktivitas dari tautan "Lihat Semua".
  static const String activities = '/activities';

  /// Modal form Buat Kategori Baru Tabel Bebas (frame `546:5163`).
  static const String freeTableCreate = '/free-tables/create';

  /// Deep link form Buat Kategori Baru (frame `546:5430`). Tombol `+` navbar
  /// membuka form yang sama sebagai popup tanpa berpindah rute.
  static const String categoryCreate = '/categories/create';

  /// Prototype chat input penjualan harian/shift (di luar shell produksi).
  /// Default nonaktif; lihat `AppFeatures.salesChatPrototype`.
  static const String salesChatPrototype = '/prototype/sales-chat';
}

/// Menampilkan form Buat Kategori Baru sebagai popup tanpa mengubah rute.
///
/// Popup memakai bottom sheet terbatas tinggi agar tidak menutupi seluruh
/// layar. Form tetap memakai [FreeTableCategoryScreen] yang sudah berbentuk
/// sheet, dan otomatis ditutup setelah penyimpanan berhasil. Rute
/// [AppRoutes.categoryCreate] tetap tersedia untuk deep link langsung.
Future<void> _showCategoryCreatePopup(BuildContext context) {
  final double maxHeight = MediaQuery.sizeOf(context).height * 0.78;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x4D0F172A),
    elevation: 0,
    enableDrag: true,
    isDismissible: true,
    constraints: BoxConstraints(maxHeight: maxHeight),
    builder: (BuildContext sheetContext) {
      void close() => Navigator.of(sheetContext).pop();

      return FreeTableCategoryScreen(
        backgroundColor: Colors.transparent,
        applyTopInset: false,
        onClose: close,
        onSaved: close,
        controllerFactory: () => FreeTableCategoryController(
          createCategory: DataProviders.createFreeTableCategory(),
          initialState: const FreeTableCategoryState.incomeExample(),
        ),
      );
    },
  );
}

/// Konfigurasi GoRouter aplikasi (lihat `ARCHITECTURE.md` §2.4).
abstract final class AppRouter {
  /// Membuat instance [GoRouter].
  ///
  /// [initialLocation] dapat diubah untuk deep link maupun pengujian.
  ///
  /// [authController] di-inject dari composition root. Bila `null` (mis. pada
  /// widget test lama), auth memakai perilaku navigasi lama tanpa guard agar
  /// test yang sudah ada tetap fokus pada layar masing-masing.
  static GoRouter create({
    String initialLocation = AppRoutes.splash,
    AppFeatures features = const AppFeatures(),
    AuthController? authController,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: authController,
      redirect: authController == null
          ? null
          : (BuildContext context, GoRouterState state) {
              return _authRedirect(authController, state);
            },
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
          builder: (BuildContext context, GoRouterState state) => _AuthRoute(
            controller: authController,
            initialTab: AuthTab.login,
            initialPortal: AuthPortal.fromQuery(
              state.uri.queryParameters['peran'],
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (BuildContext context, GoRouterState state) => _AuthRoute(
            controller: authController,
            initialTab: AuthTab.register,
          ),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (BuildContext context, GoRouterState state) {
            final AuthPortal initialPortal = AuthPortal.fromQuery(
              state.uri.queryParameters['peran'],
            );
            return ForgotPasswordScreen(
              initialPortal: initialPortal,
              onCancel: () => context.go(AppRoutes.login),
              onBackToLogin: () => context.go(AppRoutes.login),
              onOpenResetPassword: (AuthPortal portal) => context.go(
                '${AppRoutes.resetPassword}?peran=${portal.name}',
              ),
              onRequestReset: authController == null
                  ? null
                  : (String email, AuthPortal portal) async {
                      final bool ok = await authController.requestPasswordReset(
                        email: email,
                        portal: portal,
                      );
                      if (!ok) {
                        throw Exception(
                          authController.state.errorMessage ??
                              'Gagal mengirim tautan reset password.',
                        );
                      }
                    },
            );
          },
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (BuildContext context, GoRouterState state) {
            final AuthPortal initialPortal = AuthPortal.fromQuery(
              state.uri.queryParameters['peran'],
            );
            final String initialToken =
                state.uri.queryParameters['token'] ?? '';
            return ResetPasswordScreen(
              initialPortal: initialPortal,
              initialToken: initialToken,
              onCancel: () => context.go(AppRoutes.login),
              onBackToLoginWithPortal: (AuthPortal portal) => context.go(
                '${AppRoutes.login}?peran=${portal.name}',
              ),
              onSubmit: authController == null
                  ? null
                  : (ResetPasswordFormData data) async {
                      final bool ok = await authController.resetPassword(
                        token: data.token,
                        newPassword: data.newPassword,
                        portal: data.portal,
                      );
                      if (!ok) {
                        throw Exception(
                          authController.state.errorMessage ??
                              'Gagal mengatur ulang password.',
                        );
                      }
                    },
            );
          },
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
        // Menu Profil dan turunannya. Semua berada di luar shell agar
        // memakai header sendiri tanpa navbar, sesuai frame Figma.
        GoRoute(
          path: AppRoutes.profile,
          builder: (BuildContext context, GoRouterState state) {
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboard);
              }
            }

            return ProfileScreen(
              onBack: back,
              onAccount: () async {
                await context.push(AppRoutes.profileAccount);
              },
              onSettings: () => context.push(AppRoutes.profileSettings),
              onHelp: () => context.push(AppRoutes.profileHelp),
              controllerFactory: () => ProfileController(
                getProfile: DataProviders.getProfile(),
                updateProfile: DataProviders.updateProfile(),
                updateProfilePhoto: DataProviders.updateProfilePhoto(),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profileAccount,
          builder: (BuildContext context, GoRouterState state) {
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profile);
              }
            }

            return ProfileAccountScreen(
              onBack: back,
              controllerFactory: () => ProfileController(
                getProfile: DataProviders.getProfile(),
                updateProfile: DataProviders.updateProfile(),
                updateProfilePhoto: DataProviders.updateProfilePhoto(),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profileSettings,
          builder: (BuildContext context, GoRouterState state) {
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profile);
              }
            }

            return ProfileSettingsScreen(
              onBack: back,
              onChangePassword: () =>
                  context.push(AppRoutes.profileChangePassword),
              onNotifications: () =>
                  context.push(AppRoutes.profileNotifications),
              onTerms: () => context.push(AppRoutes.profileTerms),
              onLogout: () async {
                await authController?.logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profileChangePassword,
          builder: (BuildContext context, GoRouterState state) {
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profileSettings);
              }
            }

            return ChangePasswordScreen(
              onBack: back,
              onDone: () => context.go(AppRoutes.profileSettings),
              controllerFactory: () => ChangePasswordController(
                changePassword: DataProviders.changePassword(),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profileNotifications,
          builder: (BuildContext context, GoRouterState state) {
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profileSettings);
              }
            }

            return NotificationPreferencesScreen(
              onBack: back,
              controllerFactory: () => NotificationPreferencesController(
                getPreferences: DataProviders.getNotificationPreferences(),
                updatePreferences:
                    DataProviders.updateNotificationPreferences(),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profileTerms,
          builder: (BuildContext context, GoRouterState state) {
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profileSettings);
              }
            }

            return TermsScreen(onBack: back);
          },
        ),
        GoRoute(
          path: AppRoutes.profileHelp,
          builder: (BuildContext context, GoRouterState state) {
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profile);
              }
            }

            return HelpTopicsScreen(
              onBack: back,
              onArticleTap: (String id) =>
                  context.push(AppRoutes.profileHelpArticle(id)),
              controllerFactory: () => HelpTopicsController(
                getTopics: DataProviders.getHelpTopics(),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profileHelpDetail,
          builder: (BuildContext context, GoRouterState state) {
            final String articleId =
                state.pathParameters['articleId'] ?? 'topik-transaksi';
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profileHelp);
              }
            }

            return HelpDetailScreen(
              onBack: back,
              controllerFactory: () => HelpDetailController(
                getArticle: DataProviders.getHelpArticle(),
                articleId: articleId,
              ),
            );
          },
        ),
        // Prototype chat input penjualan harian/shift. Halaman ini berada
        // di luar shell dan tidak muncul di navbar produksi. Flag default
        // `false`; aktifkan hanya untuk demo lokal.
        GoRoute(
          path: AppRoutes.salesChatPrototype,
          builder: (BuildContext context, GoRouterState state) {
            void back() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboard);
              }
            }

            if (!features.salesChatPrototype) {
              return SalesChatPrototypeDisabledScreen(onBack: back);
            }
            return SalesChatPrototypeScreen(
              onBack: back,
              controllerFactory: () => SalesChatController(
                parseRecap: DataProviders.parseSalesChatRecap(),
                initialDraft: DataProviders.salesChatSampleDraft(),
                initialUserText: SalesChatController.sampleRecapInput,
              ),
            );
          },
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
        // Deep link Buat Kategori Baru (frame `546:5430`). Tombol `+` navbar
        // memakai popup; rute ini tetap ada untuk akses langsung.
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
                onViewProfile: () => context.push(AppRoutes.profile),
                onSeeAllActivities: () => context.push(AppRoutes.activities),
                onAnalyticsTap: () => context.go(AppRoutes.analytics),
                onNotificationTap: () => context.push(AppRoutes.notifications),
                onQuickCommand: (_) {
                  context.push(AppRoutes.chatbot);
                },
                onSendCommand: (_) {
                  context.push(AppRoutes.chatbot);
                },
                onLogout: () async {
                  await authController?.logout();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
              ),
            ),
            GoRoute(
              path: AppRoutes.analytics,
              builder: (BuildContext context, GoRouterState state) =>
                  AnalyticsScreen(
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.dashboard);
                  }
                },
                onNotificationTap: () => context.push(AppRoutes.notifications),
                onAddTap: () => _showCategoryCreatePopup(context),
                onSeeAllActivities: () => context.push(AppRoutes.activities),
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

  /// Rute yang boleh diakses tanpa sesi.
  static const Set<String> _publicLocations = <String>{
    '/',
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
  };

  static String? _authRedirect(
    AuthController controller,
    GoRouterState state,
  ) {
    final AuthStatus status = controller.state.status;
    final String location = state.matchedLocation;
    final bool isPublic = _publicLocations.contains(location) ||
        location.startsWith('/prototype/');

    // Jangan memindahkan layar saat token sedang divalidasi.
    if (status == AuthStatus.checking) {
      return null;
    }

    if (status == AuthStatus.authenticated) {
      if (location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.splash ||
          location == AppRoutes.onboarding) {
        return AppRoutes.dashboard;
      }
      return null;
    }

    if (!isPublic) {
      return AppRoutes.login;
    }

    return null;
  }
}

/// Layar auth yang mendengarkan [AuthController] dan meneruskan aksi ke API.
class _AuthRoute extends StatelessWidget {
  const _AuthRoute({
    required this.initialTab,
    this.initialPortal = AuthPortal.admin,
    this.controller,
  });

  final AuthTab initialTab;
  final AuthPortal initialPortal;
  final AuthController? controller;

  @override
  Widget build(BuildContext context) {
    final AuthController? auth = controller;

    if (auth == null) {
      return AuthScreen(
        key: ValueKey<String>('${initialTab.name}_${initialPortal.name}'),
        initialTab: initialTab,
        initialPortal: initialPortal,
        // Fallback khusus test/route lama tanpa composition root.
        onLoginSubmit: (_) => context.go(AppRoutes.dashboard),
        onRegisterSubmit: (_) => context.go(AppRoutes.dashboard),
        onForgotPasswordWithPortal: (AuthPortal portal) => context.go(
          '${AppRoutes.forgotPassword}?peran=${portal.name}',
        ),
      );
    }

    return ListenableBuilder(
      listenable: auth,
      builder: (BuildContext context, Widget? child) {
        final AuthState state = auth.state;
        final bool isAuthenticating = state.status == AuthStatus.authenticating;

        return AuthScreen(
          key: ValueKey<String>('${initialTab.name}_${initialPortal.name}'),
          initialTab: initialTab,
          initialPortal: initialPortal,
          isLoginLoading: isAuthenticating,
          loginError: state.errorMessage,
          isRegisterLoading: isAuthenticating,
          registerError: state.errorMessage,
          onLoginSubmit: (LoginFormData data) async {
            final bool success = await auth.login(
              email: data.email,
              password: data.password,
              portal: data.portal,
            );
            if (success && context.mounted) {
              context.go(AppRoutes.dashboard);
            }
          },
          onRegisterSubmit: (RegisterFormData data) async {
            final bool success = await auth.register(
              name: data.name,
              email: data.email,
              phone: data.phone,
              address: data.address,
              password: data.password,
              promotionAllowed: data.promotionAllowed,
            );
            if (success && context.mounted) {
              context.go(AppRoutes.dashboard);
            }
          },
          onForgotPasswordWithPortal: (AuthPortal portal) => context.go(
            '${AppRoutes.forgotPassword}?peran=${portal.name}',
          ),
          onTabChanged: auth.clearError,
          onFieldChanged: auth.clearError,
        );
      },
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

    // Area chat Ai Asistant tidak memakai glassmorphism agar composer dan
    // navbar tetap solid saat mengetik atau mengirim pesan.
    final bool glassEnabled = activeTab != BottomNavTab.aiAssistant;

    return Scaffold(
      // Navbar punya area transparan 30 px di atas bar putih. Samakan dengan
      // latar layar agar tidak muncul strip putih kosong di atas navbar.
      backgroundColor: SojuColors.homeBackground,
      // Body ikut turun di belakang navbar supaya lapisan kaca dapat
      // memblur konten yang sedang digulir.
      // Pada tab chat, body tidak melewati navbar. Ini membuat composer
      // menempel tepat di atas navbar tanpa celah putih kosong.
      extendBody: glassEnabled,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: child),
          if (glassEnabled)
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
            glassEnabled: glassEnabled,
            onTabSelected: (BottomNavTab tab) {
              context.go(AppRouter._pathFor(tab));
            },
            // Tombol "+" membuka form kategori Phase A (frame `546:5430`)
            // sebagai popup, bukan perpindahan rute.
            // Form hanya mengirim draf ke datasource mock; belum ada HTTP.
            onAddTap: () => _showCategoryCreatePopup(context),
          ),
        ),
      ),
    );
  }
}
