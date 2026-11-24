import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/soju_colors.dart';
import '../../data/data_providers.dart';
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
import '../../presentation/screens/profile/models/profile_view_data.dart';
import '../../presentation/screens/profile/notification_preferences_screen.dart';
import '../../presentation/screens/profile/profile_account_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/profile_settings_screen.dart';
import '../../presentation/screens/profile/terms_screen.dart';
import '../../presentation/screens/prototype/sales_chat/sales_chat_prototype_disabled_screen.dart';
import '../../presentation/screens/prototype/sales_chat/sales_chat_prototype_screen.dart';
import '../../presentation/widgets/admin_drawer.dart';
import '../../presentation/widgets/bottom_glass_overlay.dart';
import '../../presentation/widgets/bottom_nav_bar.dart';
import '../../presentation/widgets/customer_bottom_nav_bar.dart';
import '../../presentation/widgets/role_shell_screens.dart';
import '../config/app_features.dart';

/// Segment rute aplikasi SOJU lintas peran (`AD-08`, `AD-11`).
abstract final class AppRoutes {
  // --- Publik & Autentikasi ---

  /// Layar splash / sambutan.
  static const String splash = '/splash';

  /// Carousel onboarding.
  static const String onboarding = '/onboarding';

  /// Masuk ke akun Admin/Super Admin atau Pelanggan.
  static const String login = '/login';

  /// Pendaftaran akun Pelanggan baru.
  static const String register = '/register';

  /// Permintaan tautan reset password.
  static const String forgotPassword = '/forgot-password';

  /// Pengaturan ulang password menggunakan token satu kali pakai.
  static const String resetPassword = '/reset-password';

  // --- Shell Pelanggan (`UserRole.customer`, 5 Tab + Checkout) ---

  /// Tab 1 Pelanggan: Beranda.
  static const String customerHome = '/customer';

  /// Tab 2 Pelanggan: Menu katalog publik.
  static const String customerMenu = '/customer/menu';

  /// Tab 3 Pelanggan: Keranjang belanja.
  static const String customerCart = '/customer/keranjang';

  /// Tab 4 Pelanggan: Riwayat pesanan pelanggan.
  static const String customerOrders = '/customer/pesanan';

  /// Tab 5 Pelanggan: Akun & profil pelanggan.
  static const String customerAccount = '/customer/akun';

  /// Halaman Checkout pengiriman pelanggan (khusus `CUSTOMER`).
  static const String customerCheckout = '/customer/checkout';

  // --- Shell Admin & Super Admin (`ADMIN` + `SUPER_ADMIN`, 5 Tab) ---

  /// Tab 1 Admin: Home / ringkasan dashboard.
  static const String dashboard = '/dashboard';

  /// Tab 2 Admin: Pengelola pesanan pelanggan.
  static const String adminOrders = '/orders';

  /// Tab 3 Admin: Data & transaksi operasional.
  static const String data = '/data';

  /// Alias rute analitik/transaksi lama di dalam Shell Admin.
  static const String analytics = '/analytics';

  /// Tab 4 Admin: Asisten AI Hybrid RAG.
  static const String chatbot = '/chatbot';

  /// Alias semantik tab AI Admin.
  static const String ai = chatbot;

  /// Tab 5 Admin: Akun pengelola di dalam Shell Admin.
  static const String adminAccount = '/account';

  // --- Admin Drawer (`Audit` untuk keduanya; `Users`, `CMS`, `CRM` khusus `SUPER_ADMIN`) ---

  /// Drawer Admin & Super Admin: Log Audit & Stok.
  static const String audit = '/audit';

  /// Drawer khusus `SUPER_ADMIN`: Manajemen multi-user Admin.
  static const String adminUsers = '/admin/users';

  /// Drawer khusus `SUPER_ADMIN`: Konten CMS publik.
  static const String adminCms = '/admin/cms';

  /// Drawer khusus `SUPER_ADMIN`: Ringkasan Pelanggan & CRM.
  static const String adminCrm = '/admin/crm';

  // --- Drill-down & Utilitas Admin (di luar navbar bawah) ---

  /// Menu Profil penuh tanpa navbar bawah (frame `546:5561`).
  static const String profile = '/profile';

  /// Edit data akun dan foto profil (frame `546:5592`).
  static const String profileAccount = '/profile/account';

  /// Pengaturan akun (frame `546:5611`).
  static const String profileSettings = '/profile/settings';

  /// Form ganti password.
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

  /// Deep link form Buat Kategori Baru (frame `546:5430`).
  static const String categoryCreate = '/categories/create';

  /// Prototype chat input penjualan harian/shift (di luar shell produksi).
  static const String salesChatPrototype = '/prototype/sales-chat';
}

/// Menampilkan form Buat Kategori Baru sebagai popup tanpa mengubah rute.
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

/// Konfigurasi GoRouter sadar-peran (`AD-08`, `AD-11`, `TASK-023`).
abstract final class AppRouter {
  /// Membuat instance [GoRouter] dengan pemisahan ketat dua ShellRoute
  /// (Pelanggan vs Admin/Super Admin) dan guard lintas peran.
  ///
  /// Bila [authController] bernilai `null` (khusus widget test terisolasi),
  /// rute dapat dirender langsung tanpa redirect sesi agar test komponen lama
  /// tetap terfokus pada layar masing-masing.
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
        GoRoute(
          path: '/',
          redirect: (BuildContext context, GoRouterState state) {
            if (authController != null &&
                authController.state.isAuthenticated &&
                authController.state.user != null) {
              return homeRouteForRole(authController.state.role);
            }
            return AppRoutes.splash;
          },
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

        // =====================================================================
        // SHELL 1: PELANGGAN (`UserRole.customer`)
        // 5 Tab: Beranda | Menu | Keranjang | Pesanan | Akun
        // =====================================================================
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return _CustomerShell(
              activeTab: customerNavTabFor(state.uri.path),
              child: child,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.customerHome,
              builder: (BuildContext context, GoRouterState state) =>
                  _AuthUserBuilder(
                controller: authController,
                builder: (BuildContext context, AuthUser? user) =>
                    CustomerHomeShellScreen(
                  user: user,
                  onBrowseMenu: () => context.go(AppRoutes.customerMenu),
                  onViewOrders: () => context.go(AppRoutes.customerOrders),
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.customerMenu,
              builder: (BuildContext context, GoRouterState state) =>
                  CustomerMenuShellScreen(
                onOpenCart: () => context.go(AppRoutes.customerCart),
              ),
            ),
            GoRoute(
              path: AppRoutes.customerCart,
              builder: (BuildContext context, GoRouterState state) =>
                  CustomerCartShellScreen(
                onCheckout: () => context.push(AppRoutes.customerCheckout),
                onBrowseMenu: () => context.go(AppRoutes.customerMenu),
              ),
            ),
            GoRoute(
              path: AppRoutes.customerOrders,
              builder: (BuildContext context, GoRouterState state) =>
                  CustomerOrdersShellScreen(
                onBrowseMenu: () => context.go(AppRoutes.customerMenu),
              ),
            ),
            GoRoute(
              path: AppRoutes.customerAccount,
              builder: (BuildContext context, GoRouterState state) =>
                  _AuthUserBuilder(
                controller: authController,
                builder: (BuildContext context, AuthUser? user) =>
                    CustomerAccountShellScreen(
                  user: user,
                  onLogout: () async {
                    await authController?.logout();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.customerCheckout,
          builder: (BuildContext context, GoRouterState state) =>
              CustomerCheckoutShellScreen(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.customerCart);
              }
            },
            onViewOrders: () => context.go(AppRoutes.customerOrders),
          ),
        ),

        // =====================================================================
        // SHELL 2: ADMIN & SUPER ADMIN (`UserRole.admin` | `UserRole.superAdmin`)
        // 5 Tab: Home | Pesanan | Data | AI | Akun + Admin Drawer
        // =====================================================================
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return _AdminShell(
              activeTab: adminNavTabFor(state.uri.path),
              currentPath: state.uri.path,
              authController: authController,
              child: child,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (BuildContext context, GoRouterState state) =>
                  _AuthUserBuilder(
                controller: authController,
                builder: (BuildContext context, AuthUser? user) {
                  final ProfileViewData profileData = user == null
                      ? ProfileViewData.sample
                      : ProfileViewData(
                          name: user.name,
                          email: user.email,
                          role: user.role.label,
                          avatarAsset: ProfileViewData.sample.avatarAsset,
                          phone: user.phone ?? ProfileViewData.sample.phone,
                        );

                  return DashboardScreen(
                    profile: profileData,
                    onMenuTap: () => _AdminShellScope.openDrawerOf(context),
                    onViewProfile: () => context.push(AppRoutes.profile),
                    onSeeAllActivities: () =>
                        context.push(AppRoutes.activities),
                    onAnalyticsTap: () => context.go(AppRoutes.data),
                    onNotificationTap: () =>
                        context.push(AppRoutes.notifications),
                    onQuickCommand: (_) => context.go(AppRoutes.chatbot),
                    onSendCommand: (_) => context.go(AppRoutes.chatbot),
                    onLogout: () async {
                      await authController?.logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                  );
                },
              ),
            ),
            GoRoute(
              path: AppRoutes.adminOrders,
              builder: (BuildContext context, GoRouterState state) =>
                  AdminOrdersShellScreen(
                onMenuTap: () => _AdminShellScope.openDrawerOf(context),
                onNotificationTap: () => context.push(AppRoutes.notifications),
              ),
            ),
            GoRoute(
              path: AppRoutes.data,
              builder: (BuildContext context, GoRouterState state) =>
                  _buildAdminDataScreen(context),
            ),
            GoRoute(
              path: AppRoutes.analytics,
              builder: (BuildContext context, GoRouterState state) =>
                  _buildAdminDataScreen(context),
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
              path: AppRoutes.adminAccount,
              builder: (BuildContext context, GoRouterState state) =>
                  ProfileScreen(
                onBack: () => context.go(AppRoutes.dashboard),
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
              ),
            ),
          ],
        ),

        // =====================================================================
        // RUTE DRAWER ADMIN & SUPER ADMIN
        // =====================================================================
        GoRoute(
          path: AppRoutes.audit,
          builder: (BuildContext context, GoRouterState state) => AuditScreen(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboard);
              }
            },
            controllerFactory: () => AuditLogController(
              getAuditLogs: GetAuditLogs(
                AuditRepositoryImpl(AuditMockDataSource()),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.adminUsers,
          builder: (BuildContext context, GoRouterState state) =>
              SuperAdminModuleScreen(
            key: const Key('admin_users_screen'),
            title: 'Kelola Pengguna',
            subtitle:
                'Manajemen akun Admin & Super Admin beserta status akses.',
            cardTitle: 'Daftar Pengelola Sistem',
            cardDescription:
                'Tambah akun pengelola baru, perbarui peran, nonaktifkan akses, '
                'atau kirim tautan atur ulang password.',
            icon: Icons.manage_accounts_outlined,
            onBack: () => _popOrDashboard(context),
          ),
        ),
        GoRoute(
          path: AppRoutes.adminCms,
          builder: (BuildContext context, GoRouterState state) =>
              SuperAdminModuleScreen(
            key: const Key('admin_cms_screen'),
            title: 'Konten CMS',
            subtitle:
                'Pengelolaan konten halaman publik & informasi brand SOJU.',
            cardTitle: 'Manajemen Konten Publik',
            cardDescription:
                'Tinjau dan kelola konten publik toko yang tampil pada kanal '
                'pelanggan SOJU.',
            icon: Icons.web_outlined,
            onBack: () => _popOrDashboard(context),
          ),
        ),
        GoRoute(
          path: AppRoutes.adminCrm,
          builder: (BuildContext context, GoRouterState state) =>
              SuperAdminModuleScreen(
            key: const Key('admin_crm_screen'),
            title: 'Pelanggan & CRM',
            subtitle:
                'Ringkasan data pelanggan terdaftar dan preferensi promosi.',
            cardTitle: 'Ikhtisar Pelanggan & CRM',
            cardDescription:
                'Pantau ringkasan pelanggan aktif dan segmentasi promosi toko '
                'secara aman.',
            icon: Icons.groups_outlined,
            onBack: () => _popOrDashboard(context),
          ),
        ),

        // =====================================================================
        // RUTE DRILL-DOWN & MODAL ADMIN (DI LUAR SHELL)
        // =====================================================================
        GoRoute(
          path: AppRoutes.notifications,
          builder: (BuildContext context, GoRouterState state) =>
              NotificationsScreen(
            onBack: () => _popOrDashboard(context),
            onReconcile: () => context.go(AppRoutes.analytics),
          ),
        ),
        GoRoute(
          path: AppRoutes.activities,
          builder: (BuildContext context, GoRouterState state) =>
              ActivitiesScreen(
            onBack: () => _popOrDashboard(context),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (BuildContext context, GoRouterState state) {
            return ProfileScreen(
              onBack: () => _popOrDashboard(context),
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
        GoRoute(
          path: AppRoutes.salesChatPrototype,
          builder: (BuildContext context, GoRouterState state) {
            if (!features.salesChatPrototype) {
              return SalesChatPrototypeDisabledScreen(
                onBack: () => _popOrDashboard(context),
              );
            }
            return SalesChatPrototypeScreen(
              onBack: () => _popOrDashboard(context),
              controllerFactory: () => SalesChatController(
                parseRecap: DataProviders.parseSalesChatRecap(),
                initialDraft: DataProviders.salesChatSampleDraft(),
                initialUserText: SalesChatController.sampleRecapInput,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.freeTableCreate,
          builder: (BuildContext context, GoRouterState state) =>
              FreeTableCategoryScreen(
            onClose: () => _popOrDashboard(context),
            controllerFactory: () => FreeTableCategoryController(
              createCategory: DataProviders.createFreeTableCategory(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.categoryCreate,
          builder: (BuildContext context, GoRouterState state) =>
              FreeTableCategoryScreen(
            onClose: () => _popOrDashboard(context),
            controllerFactory: () => FreeTableCategoryController(
              createCategory: DataProviders.createFreeTableCategory(),
              initialState: const FreeTableCategoryState.incomeExample(),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildAdminDataScreen(BuildContext context) {
    return AnalyticsScreen(
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
    );
  }

  static void _popOrDashboard(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  /// Rute beranda utama berdasarkan [role] pengguna yang sedang login.
  static String homeRouteForRole(UserRole? role) {
    return role == UserRole.customer
        ? AppRoutes.customerHome
        : AppRoutes.dashboard;
  }

  /// Menentukan tab aktif pada navbar 5-tab Admin dari path URI.
  static AdminNavTab adminNavTabFor(String path) {
    final String location = _normalizePath(path);
    return switch (location) {
      AppRoutes.adminOrders => AdminNavTab.orders,
      AppRoutes.data || AppRoutes.analytics => AdminNavTab.data,
      AppRoutes.chatbot => AdminNavTab.ai,
      AppRoutes.adminAccount => AdminNavTab.account,
      _ => AdminNavTab.home,
    };
  }

  /// Rute tujuan untuk setiap tab pada navbar 5-tab Admin.
  static String pathForAdminTab(AdminNavTab tab) => switch (tab) {
        AdminNavTab.home => AppRoutes.dashboard,
        AdminNavTab.orders => AppRoutes.adminOrders,
        AdminNavTab.data => AppRoutes.data,
        AdminNavTab.ai => AppRoutes.chatbot,
        AdminNavTab.account => AppRoutes.adminAccount,
      };

  /// Menentukan tab aktif pada navbar 5-tab Pelanggan dari path URI.
  static CustomerNavTab customerNavTabFor(String path) {
    final String location = _normalizePath(path);
    return switch (location) {
      AppRoutes.customerMenu => CustomerNavTab.menu,
      AppRoutes.customerCart ||
      AppRoutes.customerCheckout =>
        CustomerNavTab.keranjang,
      AppRoutes.customerOrders => CustomerNavTab.pesanan,
      AppRoutes.customerAccount => CustomerNavTab.akun,
      _ => CustomerNavTab.beranda,
    };
  }

  /// Rute tujuan untuk setiap tab pada navbar 5-tab Pelanggan.
  static String pathForCustomerTab(CustomerNavTab tab) => switch (tab) {
        CustomerNavTab.beranda => AppRoutes.customerHome,
        CustomerNavTab.menu => AppRoutes.customerMenu,
        CustomerNavTab.keranjang => AppRoutes.customerCart,
        CustomerNavTab.pesanan => AppRoutes.customerOrders,
        CustomerNavTab.akun => AppRoutes.customerAccount,
      };

  /// Rute tujuan untuk setiap item [AdminDrawerItem].
  static String pathForAdminDrawer(AdminDrawerItem item) => switch (item) {
        AdminDrawerItem.audit => AppRoutes.audit,
        AdminDrawerItem.users => AppRoutes.adminUsers,
        AdminDrawerItem.cms => AppRoutes.adminCms,
        AdminDrawerItem.crm => AppRoutes.adminCrm,
      };

  /// Menentukan item Drawer yang cocok dengan path saat ini (bila ada).
  static AdminDrawerItem? adminDrawerItemFor(String path) {
    final String location = _normalizePath(path);
    return switch (location) {
      AppRoutes.audit => AdminDrawerItem.audit,
      AppRoutes.adminUsers => AdminDrawerItem.users,
      AppRoutes.adminCms => AdminDrawerItem.cms,
      AppRoutes.adminCrm => AdminDrawerItem.crm,
      _ => null,
    };
  }

  static String _normalizePath(String path) {
    if (path.isEmpty) {
      return '/';
    }
    return path.length > 1 && path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
  }

  /// Rute publik/auth yang dapat diakses tanpa sesi login.
  static const Set<String> _publicAuthLocations = <String>{
    '/',
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
  };

  /// Apakah [location] termasuk ruang rute Pelanggan (`/customer` & `/customer/*`).
  static bool _isCustomerRoute(String location) {
    return location == AppRoutes.customerHome ||
        location.startsWith('${AppRoutes.customerHome}/');
  }

  /// Apakah [location] dikunci khusus untuk `SUPER_ADMIN` (`Users`, `CMS`, `CRM`).
  static bool _isSuperAdminOnlyRoute(String location) {
    return location == AppRoutes.adminUsers ||
        location.startsWith('${AppRoutes.adminUsers}/') ||
        location == AppRoutes.adminCms ||
        location.startsWith('${AppRoutes.adminCms}/') ||
        location == AppRoutes.adminCrm ||
        location.startsWith('${AppRoutes.adminCrm}/');
  }

  static String? _authRedirect(
    AuthController controller,
    GoRouterState state,
  ) {
    final AuthStatus status = controller.state.status;
    final String rawLocation =
        state.matchedLocation.isEmpty ? state.uri.path : state.matchedLocation;
    final String location = _normalizePath(rawLocation);
    final bool isPublicAuth = _publicAuthLocations.contains(location);

    // Tahan perpindahan saat bootstrap sedang memvalidasi token tersimpan,
    // namun jangan biarkan rute terlindung dirender sebelum sesi selesai dicek.
    if (status == AuthStatus.checking) {
      return isPublicAuth ? null : AppRoutes.splash;
    }

    final AuthUser? user = controller.state.user;
    if (status == AuthStatus.authenticated && user != null) {
      final UserRole role = user.role;
      final String roleHome = homeRouteForRole(role);

      if (isPublicAuth) {
        return roleHome;
      }

      // Isolasi Pelanggan: hanya boleh mengakses rute `/customer` & `/customer/*`.
      if (role.isCustomer) {
        return _isCustomerRoute(location) ? null : AppRoutes.customerHome;
      }

      // Isolasi Admin & Super Admin: tidak boleh mengakses rute Pelanggan.
      if (_isCustomerRoute(location)) {
        return AppRoutes.dashboard;
      }

      // Gating ketat `SUPER_ADMIN`: `ADMIN` biasa ditolak dari Users, CMS, CRM.
      if (!role.isSuperAdmin && _isSuperAdminOnlyRoute(location)) {
        return AppRoutes.dashboard;
      }

      return null;
    }

    if (!isPublicAuth) {
      return AppRoutes.login;
    }

    return null;
  }
}

/// Helper reaktif yang membangun ulang anak saat user di [AuthController] berubah.
class _AuthUserBuilder extends StatelessWidget {
  const _AuthUserBuilder({
    required this.builder,
    this.controller,
  });

  final AuthController? controller;
  final Widget Function(BuildContext context, AuthUser? user) builder;

  @override
  Widget build(BuildContext context) {
    final AuthController? auth = controller;
    if (auth == null) {
      return builder(context, null);
    }
    return ListenableBuilder(
      listenable: auth,
      builder: (BuildContext context, Widget? _) =>
          builder(context, auth.state.user),
    );
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
        // Fallback khusus test terisolasi tanpa composition root.
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
              context.go(AppRouter.homeRouteForRole(auth.state.role));
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
              context.go(AppRouter.homeRouteForRole(auth.state.role));
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

/// Scope pembuka [AdminDrawer] bagi layar di dalam [_AdminShell] yang memiliki
/// `Scaffold` internal sendiri.
class _AdminShellScope extends InheritedWidget {
  const _AdminShellScope({
    required this.openDrawer,
    required super.child,
  });

  final VoidCallback openDrawer;

  static void openDrawerOf(BuildContext context) {
    final _AdminShellScope? scope =
        context.dependOnInheritedWidgetOfExactType<_AdminShellScope>();
    if (scope != null) {
      scope.openDrawer();
      return;
    }
    Scaffold.maybeOf(context)?.openDrawer();
  }

  @override
  bool updateShouldNotify(_AdminShellScope oldWidget) =>
      oldWidget.openDrawer != openDrawer;
}

/// Shell 5-tab untuk `ADMIN` dan `SUPER_ADMIN` lengkap dengan [AdminDrawer].
class _AdminShell extends StatefulWidget {
  const _AdminShell({
    required this.activeTab,
    required this.currentPath,
    required this.child,
    this.authController,
  });

  final AdminNavTab activeTab;
  final String currentPath;
  final AuthController? authController;
  final Widget child;

  @override
  State<_AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<_AdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double scale = (width > 480 ? 480 : width) / 430;
    final bool glassEnabled = widget.activeTab != AdminNavTab.ai;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: SojuColors.homeBackground,
      extendBody: glassEnabled,
      drawer: _AuthUserBuilder(
        controller: widget.authController,
        builder: (BuildContext context, AuthUser? user) {
          final UserRole effectiveRole = user?.role ?? UserRole.admin;
          return AdminDrawer(
            role: effectiveRole,
            userName: user?.name ?? ProfileViewData.sample.name,
            userEmail: user?.email ?? ProfileViewData.sample.email,
            selectedItem: AppRouter.adminDrawerItemFor(widget.currentPath),
            onSelectItem: (AdminDrawerItem item) {
              Navigator.of(context).pop();
              context.push(AppRouter.pathForAdminDrawer(item));
            },
            onLogout: () async {
              Navigator.of(context).pop();
              await widget.authController?.logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          );
        },
      ),
      body: _AdminShellScope(
        openDrawer: _openDrawer,
        child: Stack(
          key: const Key('admin_shell_body'),
          children: <Widget>[
            Positioned.fill(child: widget.child),
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
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AdminBottomNavBar(
            activeTab: widget.activeTab,
            glassEnabled: glassEnabled,
            onTabSelected: (AdminNavTab tab) {
              context.go(AppRouter.pathForAdminTab(tab));
            },
          ),
        ),
      ),
    );
  }
}

/// Shell 5-tab untuk Pelanggan (`UserRole.customer`):
/// `Beranda | Menu | Keranjang | Pesanan | Akun`.
class _CustomerShell extends StatelessWidget {
  const _CustomerShell({
    required this.activeTab,
    required this.child,
  });

  final CustomerNavTab activeTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('customer_shell_scaffold'),
      backgroundColor: SojuColors.homeBackground,
      body: child,
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: CustomerBottomNavBar(
            activeTab: activeTab,
            onTabSelected: (CustomerNavTab tab) {
              context.go(AppRouter.pathForCustomerTab(tab));
            },
          ),
        ),
      ),
    );
  }
}
