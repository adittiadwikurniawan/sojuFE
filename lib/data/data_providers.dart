// lib/data/data_providers.dart
//
// Titik pemilihan sumber data (mock Phase A / REST Phase B).
//
// Presentation hanya memakai usecase dari file ini. Saat backend tersedia,
// ganti datasource mock dengan datasource remote tanpa mengubah
// screen, provider, atau entity.

import '../core/services/api_client/api_client.dart';
import '../core/services/token_storage/token_storage.dart';
import '../domain/entities/sales_chat_entity.dart';
import '../domain/repositories/admin_order_repository.dart';
import '../domain/repositories/admin_users_repository.dart';
import '../domain/repositories/ai_chat_repository.dart';
import '../domain/repositories/audit_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/customer_order_repository.dart';
import '../domain/repositories/customer_profile_repository.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../domain/repositories/storefront_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/admin_order_usecases.dart';
import '../domain/usecases/admin_users_usecases.dart';
import '../domain/usecases/ai_chat_usecases.dart';
import '../domain/usecases/audit_usecases.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/customer_order_usecases.dart';
import '../domain/usecases/customer_profile_usecases.dart';
import '../domain/usecases/dashboard_usecases.dart';
import '../domain/usecases/free_table_usecases.dart';
import '../domain/usecases/help_usecases.dart';
import '../domain/usecases/profile_usecases.dart';
import '../domain/usecases/sales_chat_usecases.dart';
import '../domain/usecases/storefront_usecases.dart';
import '../domain/usecases/transaction_usecases.dart';
import '../presentation/providers/admin_orders/admin_orders_controller.dart';
import '../presentation/providers/admin_users/admin_users_controller.dart';
import '../presentation/providers/ai/ai_chat_controller.dart';
import '../presentation/providers/audit/audit_log_controller.dart';
import '../presentation/providers/dashboard/dashboard_controller.dart';
import '../presentation/providers/storefront/customer_cart_controller.dart';
import '../presentation/providers/transactions/transactions_controller.dart';
import 'datasources/mock/admin_order_mock_datasource.dart';
import 'datasources/mock/admin_users_mock_datasource.dart';
import 'datasources/mock/ai_chat_mock_datasource.dart';
import 'datasources/mock/audit_mock_datasource.dart';
import 'datasources/mock/customer_order_mock_datasource.dart';
import 'datasources/mock/customer_profile_mock_datasource.dart';
import 'datasources/mock/free_table_mock_datasource.dart';
import 'datasources/mock/help_mock_datasource.dart';
import 'datasources/mock/profile_mock_datasource.dart';
import 'datasources/mock/sales_chat_mock_datasource.dart';
import 'datasources/mock/storefront_mock_datasource.dart';
import 'datasources/remote/admin_order_remote_datasource.dart';
import 'datasources/remote/admin_users_remote_datasource.dart';
import 'datasources/remote/ai_chat_remote_datasource.dart';
import 'datasources/remote/audit_remote_datasource.dart';
import 'datasources/remote/auth_remote_datasource.dart';
import 'datasources/remote/customer_order_remote_datasource.dart';
import 'datasources/remote/customer_profile_remote_datasource.dart';
import 'datasources/remote/dashboard_remote_datasource.dart';
import 'datasources/remote/storefront_remote_datasource.dart';
import 'datasources/remote/transaction_remote_datasource.dart';
import 'repositories/admin_order_repository_impl.dart';
import 'repositories/admin_users_repository_impl.dart';
import 'repositories/ai_chat_repository_impl.dart';
import 'repositories/audit_repository_impl.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/customer_order_repository_impl.dart';
import 'repositories/customer_profile_repository_impl.dart';
import 'repositories/dashboard_repository_impl.dart';
import 'repositories/free_table_repository_impl.dart';
import 'repositories/help_repository_impl.dart';
import 'repositories/profile_repository_impl.dart';
import 'repositories/sales_chat_repository_impl.dart';
import 'repositories/storefront_repository_impl.dart';
import 'repositories/transaction_repository_impl.dart';

/// Factory dependency data tingkat aplikasi.
abstract final class DataProviders {
  static AuthRepository? _authRepository;
  static StorefrontRepository? _storefrontRepository;
  static CustomerOrderRepository? _customerOrderRepository;
  static CustomerProfileRepository? _customerProfileRepository;

  // Repositories untuk admin operasional live REST (TASK-026, TASK-027, TASK-028)
  static DashboardRepository? _dashboardRepository;
  static TransactionRepository? _transactionRepository;
  static AuditLogRepository? _auditLogRepository;
  static AdminOrderRepository? _adminOrderRepository;
  static AdminUsersRepository? _adminUsersRepository;
  static AiChatRepository? _aiChatRepository;

  /// Mengonfigurasi dependency remote dari composition root (`main.dart`).
  ///
  /// Data layer tidak mengimpor `app/config`; base URL dan token storage
  /// di-inject agar Phase A (mock) dan Phase B (REST) memakai titik yang sama.
  static void configure({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
    String apiOrigin = '',
  }) {
    _authRepository = AuthRepositoryImpl(
      AuthRemoteDataSource(apiClient),
      tokenStorage,
    );
    _storefrontRepository = StorefrontRepositoryImpl(
      StorefrontRemoteDataSource(apiClient),
      apiOrigin: apiOrigin,
    );
    _customerOrderRepository = CustomerOrderRepositoryImpl(
      CustomerOrderRemoteDataSource(apiClient),
    );
    _customerProfileRepository = CustomerProfileRepositoryImpl(
      CustomerProfileRemoteDataSource(apiClient),
    );

    // REST data providers untuk Admin operasional (TASK-026)
    _dashboardRepository = DashboardRepositoryImpl(
      DashboardRemoteDataSource(apiClient),
    );
    _transactionRepository = TransactionRepositoryImpl(
      TransactionRemoteDataSource(apiClient),
    );
    _auditLogRepository = AuditRepositoryImpl(
      AuditRemoteDataSource(apiClient),
    );
    _adminOrderRepository = AdminOrderRepositoryImpl(
      AdminOrderRemoteDataSource(apiClient),
    );
    _adminUsersRepository = AdminUsersRepositoryImpl(
      AdminUsersRemoteDataSource(apiClient),
    );
    _aiChatRepository = AiChatRepositoryImpl(
      AiChatRemoteDataSource(apiClient),
    );

    resetCartController();
  }

  /// Apakah repository etalase Pelanggan (TASK-024) sudah dikonfigurasi.
  static bool get hasStorefront => _storefrontRepository != null;

  static final StorefrontMockDataSource _storefrontMockDataSource =
      StorefrontMockDataSource();

  static StorefrontRepository get _storefront {
    return _storefrontRepository ??
        StorefrontRepositoryImpl(_storefrontMockDataSource);
  }

  static CustomerCartController? _customerCartController;

  /// Mengambil atau mengonfigurasi controller keranjang Pelanggan bersama.
  static CustomerCartController customerCartController({
    CustomerCartController? custom,
  }) {
    if (custom != null) {
      _customerCartController = custom;
      return custom;
    }
    return _customerCartController ??= CustomerCartController(
      getCart: getCart(),
      saveCart: saveCart(),
    );
  }

  /// Mereset dan membuang controller keranjang bersama.
  static void resetCartController() {
    _customerCartController?.reset();
    _customerCartController?.dispose();
    _customerCartController = null;
  }

  /// Usecase katalog produk publik `/api/public/products`.
  static GetCatalogProducts getCatalogProducts() =>
      GetCatalogProducts(_storefront);

  /// Usecase keranjang lokal/sinkronisasi.
  static GetCart getCart() => GetCart(_storefront);
  static SaveCart saveCart() => SaveCart(_storefront);

  static final CustomerOrderMockDataSource _customerOrderMockDataSource =
      CustomerOrderMockDataSource();

  static CustomerOrderRepository get _customerOrder {
    return _customerOrderRepository ??
        CustomerOrderRepositoryImpl(_customerOrderMockDataSource);
  }

  static final CustomerProfileMockDataSource _customerProfileMockDataSource =
      CustomerProfileMockDataSource();

  static CustomerProfileRepository get _customerProfile {
    return _customerProfileRepository ??
        CustomerProfileRepositoryImpl(_customerProfileMockDataSource);
  }

  /// Usecase checkout pesanan pelanggan `POST /api/customer/checkout`.
  static CheckoutCustomerOrder checkoutCustomerOrder() =>
      CheckoutCustomerOrder(_customerOrder);

  /// Usecase daftar riwayat pesanan pelanggan `GET /api/customer/pesanan`.
  static GetCustomerOrders getCustomerOrders() =>
      GetCustomerOrders(_customerOrder);

  /// Usecase detail pesanan pelanggan `GET /api/customer/pesanan/:id`.
  static GetCustomerOrderDetail getCustomerOrderDetail() =>
      GetCustomerOrderDetail(_customerOrder);

  /// Usecase ambil profil pelanggan `GET /api/customer/profil`.
  static GetCustomerProfile getCustomerProfile() =>
      GetCustomerProfile(_customerProfile);

  /// Usecase perbarui profil pelanggan `PATCH /api/customer/profil`.
  static UpdateCustomerProfile updateCustomerProfile() =>
      UpdateCustomerProfile(_customerProfile);

  /// Usecase ganti password pelanggan `POST /api/customer/ubah-password`.
  static ChangeCustomerPassword changeCustomerPassword() =>
      ChangeCustomerPassword(_customerProfile);

  // --- Admin Operational Live Data Providers (TASK-026) ---

  static final AuditMockDataSource _auditMockDataSource =
      AuditMockDataSource();

  static AuditLogRepository get _auditLog {
    return _auditLogRepository ?? AuditRepositoryImpl(_auditMockDataSource);
  }

  /// Usecase daftar log audit `GET /api/v1/audit-log`.
  static GetAuditLogs getAuditLogs() => GetAuditLogs(_auditLog);

  /// Apakah repository dashboard sudah dikonfigurasi.
  static bool get hasDashboard => _dashboardRepository != null;

  static DashboardRepository get _dashboard {
    final DashboardRepository? repo = _dashboardRepository;
    if (repo == null) {
      throw StateError('DataProviders.configure belum dipanggil untuk dashboard.');
    }
    return repo;
  }

  /// Usecase ringkasan dashboard `GET /api/v1/dashboard/*`.
  static GetDashboardSummary getDashboardSummary() =>
      GetDashboardSummary(_dashboard);

  /// Apakah repository transaksi operasional sudah dikonfigurasi.
  static bool get hasTransaction => _transactionRepository != null;

  static TransactionRepository get _transaction {
    final TransactionRepository? repo = _transactionRepository;
    if (repo == null) {
      throw StateError('DataProviders.configure belum dipanggil untuk transaksi.');
    }
    return repo;
  }

  /// Usecase daftar transaksi operasional `GET /api/v1/transactions`.
  static GetTransactions getTransactions() => GetTransactions(_transaction);

  static final AdminOrderMockDataSource _adminOrderMockDataSource =
      AdminOrderMockDataSource();

  static AdminOrderRepository get _adminOrder {
    return _adminOrderRepository ?? AdminOrderRepositoryImpl(_adminOrderMockDataSource);
  }

  /// Usecase pesanan admin `GET /api/v1/customer-orders`.
  static GetAdminOrders getAdminOrders() => GetAdminOrders(_adminOrder);

  /// Usecase pembaruan status pesanan admin `PATCH /api/v1/customer-orders/:id/status`.
  static UpdateAdminOrderStatus updateAdminOrderStatus() =>
      UpdateAdminOrderStatus(_adminOrder);

  /// Factory controller Admin Orders.
  static AdminOrdersController createAdminOrdersController() {
    return AdminOrdersController(
      getAdminOrders: getAdminOrders(),
      updateAdminOrderStatus: updateAdminOrderStatus(),
    );
  }

  /// Factory controller Dashboard Operasional.
  static DashboardController createDashboardController() {
    return DashboardController(
      getDashboardSummary: getDashboardSummary(),
    );
  }

  /// Factory controller Transaksi / Data Operasional.
  static TransactionsController createTransactionsController() {
    return TransactionsController(
      getTransactions: getTransactions(),
    );
  }

  /// Factory controller Log Audit.
  static AuditLogController createAuditLogController() {
    return AuditLogController(
      getAuditLogs: getAuditLogs(),
    );
  }

  // --- SUPER_ADMIN Multi-User Management Providers (TASK-027) ---

  static final AdminUsersMockDataSource _adminUsersMockDataSource =
      AdminUsersMockDataSource();

  static AdminUsersRepository get _adminUsers {
    return _adminUsersRepository ??
        AdminUsersRepositoryImpl(_adminUsersMockDataSource);
  }

  /// Usecase daftar akun admin `GET /api/v1/users`.
  static GetAdminUsers getAdminUsers() => GetAdminUsers(_adminUsers);

  /// Usecase pembuatan akun admin baru `POST /api/v1/users`.
  static CreateAdminUser createAdminUser() => CreateAdminUser(_adminUsers);

  /// Usecase pembaruan data akun admin `PATCH /api/v1/users/:id`.
  static UpdateAdminUser updateAdminUser() => UpdateAdminUser(_adminUsers);

  /// Usecase pembaruan status aktif akun admin `PATCH /api/v1/users/:id/status`.
  static UpdateAdminUserStatus updateAdminUserStatus() =>
      UpdateAdminUserStatus(_adminUsers);

  /// Usecase nonaktifkan akun admin secara lunak `DELETE /api/v1/users/:id`.
  static SoftDisableAdminUser softDisableAdminUser() =>
      SoftDisableAdminUser(_adminUsers);

  /// Usecase pemicuan email reset password `POST /api/v1/users/:id/reset-password`.
  static TriggerAdminUserPasswordReset triggerAdminUserPasswordReset() =>
      TriggerAdminUserPasswordReset(_adminUsers);

  /// Factory controller Manajemen Multi-User Admin (`SUPER_ADMIN` only).
  static AdminUsersController createAdminUsersController() {
    return AdminUsersController(
      getAdminUsers: getAdminUsers(),
      createAdminUser: createAdminUser(),
      updateAdminUser: updateAdminUser(),
      updateAdminUserStatus: updateAdminUserStatus(),
      softDisableAdminUser: softDisableAdminUser(),
      triggerPasswordReset: triggerAdminUserPasswordReset(),
    );
  }

  // --- Hybrid RAG AI Admin Providers (TASK-028) ---

  static const AiChatMockDataSource _aiChatMockDataSource =
      AiChatMockDataSource();

  static AiChatRepository get _aiChat {
    return _aiChatRepository ??
        const AiChatRepositoryImpl(_aiChatMockDataSource);
  }

  /// Usecase daftar riwayat percakapan AI `GET /api/v1/ai/conversations`.
  static GetAiConversations getAiConversations() =>
      GetAiConversations(_aiChat);

  /// Usecase detail percakapan AI `GET /api/v1/ai/conversations/:id`.
  static GetAiConversationDetail getAiConversationDetail() =>
      GetAiConversationDetail(_aiChat);

  /// Usecase kirim pesan chat Hybrid RAG `POST /api/v1/ai/chat`.
  static SendAiChatMessage sendAiChatMessage() => SendAiChatMessage(_aiChat);

  /// Usecase konfirmasi draft transaksi `POST /api/v1/transactions`.
  static ConfirmAiDraftTransaction confirmAiDraftTransaction() =>
      ConfirmAiDraftTransaction(_aiChat);

  /// Usecase reindex basis pengetahuan AI `POST /api/v1/ai/reindex` (`SUPER_ADMIN`).
  static TriggerAiReindex triggerAiReindex() => TriggerAiReindex(_aiChat);

  /// Factory controller Hybrid RAG AI Admin.
  static AiChatController createAiChatController() {
    return AiChatController(
      getConversations: getAiConversations(),
      getConversationDetail: getAiConversationDetail(),
      sendChatMessage: sendAiChatMessage(),
      confirmDraftTransaction: confirmAiDraftTransaction(),
      triggerReindex: triggerAiReindex(),
    );
  }

  /// Menghapus konfigurasi auth, etalase, pesanan, dan admin repos (dipakai test).
  static void resetAuth() {
    _authRepository = null;
    _storefrontRepository = null;
    _customerOrderRepository = null;
    _customerProfileRepository = null;
    _dashboardRepository = null;
    _transactionRepository = null;
    _auditLogRepository = null;
    _adminOrderRepository = null;
    _adminUsersRepository = null;
    _aiChatRepository = null;
    resetCartController();
  }

  /// Setter untuk testing repository admin secara eksplisit.
  static void setAdminRepositoriesForTest({
    DashboardRepository? dashboard,
    TransactionRepository? transaction,
    AuditLogRepository? audit,
    AdminOrderRepository? adminOrder,
    AdminUsersRepository? adminUsers,
    AiChatRepository? aiChat,
  }) {
    if (dashboard != null) _dashboardRepository = dashboard;
    if (transaction != null) _transactionRepository = transaction;
    if (audit != null) _auditLogRepository = audit;
    if (adminOrder != null) _adminOrderRepository = adminOrder;
    if (adminUsers != null) _adminUsersRepository = adminUsers;
    if (aiChat != null) _aiChatRepository = aiChat;
  }

  static bool get hasAuth => _authRepository != null;

  static AuthRepository get _auth {
    final AuthRepository? repository = _authRepository;
    if (repository == null) {
      throw StateError(
        'DataProviders.configure belum dipanggil untuk auth.',
      );
    }
    return repository;
  }

  /// Usecase login email/password lintas peran.
  static Login login() => Login(_auth);

  /// Usecase pendaftaran akun pelanggan.
  static Register register() => Register(_auth);

  /// Usecase permintaan tautan reset password.
  static RequestPasswordReset requestPasswordReset() =>
      RequestPasswordReset(_auth);

  /// Usecase pengaturan ulang password dengan token.
  static ResetPassword resetPassword() => ResetPassword(_auth);

  /// Usecase pemulihan sesi dari token dan peran tersimpan.
  static RestoreSession restoreSession() => RestoreSession(_auth);

  /// Usecase logout lokal.
  static Logout logout() => Logout(_auth);

  /// Mock profil dibagi antar-route agar perubahan foto/data tetap terlihat
  /// saat pengguna berpindah layar. Phase B: ganti dengan datasource remote.
  static final ProfileMockDataSource _profileDataSource =
      ProfileMockDataSource();

  static const HelpMockDataSource _helpDataSource = HelpMockDataSource();

  /// Usecase pembuatan kategori Tabel Bebas (Phase A: mock).
  static CreateFreeTableCategory createFreeTableCategory() {
    return const CreateFreeTableCategory(
      FreeTableRepositoryImpl(FreeTableMockDataSource()),
    );
  }

  /// Usecase penyusunan draft prototype chat penjualan (Phase A: mock).
  ///
  /// Tidak ada endpoint AI yang dipanggil. Saat kontrak backend tersedia,
  /// ganti datasource mock di sini tanpa mengubah UI atau controller.
  static ParseSalesChatRecap parseSalesChatRecap() {
    return const ParseSalesChatRecap(
      SalesChatRepositoryImpl(SalesChatMockDataSource()),
    );
  }

  /// Draft contoh untuk percakapan awal prototype.
  static SalesChatDraft salesChatSampleDraft() {
    return SalesChatMockDataSource.sampleDraft;
  }

  /// Usecase pengambilan profil akun (Phase A: mock).
  static GetProfile getProfile() {
    return GetProfile(ProfileRepositoryImpl(_profileDataSource));
  }

  /// Usecase penyimpanan data profil (Phase A: mock).
  static UpdateProfile updateProfile() {
    return UpdateProfile(ProfileRepositoryImpl(_profileDataSource));
  }

  /// Usecase penggantian foto profil (Phase A: mock).
  static UpdateProfilePhoto updateProfilePhoto() {
    return UpdateProfilePhoto(ProfileRepositoryImpl(_profileDataSource));
  }

  /// Usecase perubahan password (Phase A: mock).
  static ChangePassword changePassword() {
    return ChangePassword(ProfileRepositoryImpl(_profileDataSource));
  }

  /// Usecase pengambilan preferensi notifikasi (Phase A: mock).
  static GetNotificationPreferences getNotificationPreferences() {
    return GetNotificationPreferences(
      ProfileRepositoryImpl(_profileDataSource),
    );
  }

  /// Usecase penyimpanan preferensi notifikasi (Phase A: mock).
  static UpdateNotificationPreferences updateNotificationPreferences() {
    return UpdateNotificationPreferences(
      ProfileRepositoryImpl(_profileDataSource),
    );
  }

  /// Usecase daftar topik bantuan (Phase A: mock).
  static GetHelpTopics getHelpTopics() {
    return const GetHelpTopics(HelpRepositoryImpl(_helpDataSource));
  }

  /// Usecase detail artikel bantuan (Phase A: mock).
  static GetHelpArticle getHelpArticle() {
    return const GetHelpArticle(HelpRepositoryImpl(_helpDataSource));
  }
}
