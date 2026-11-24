// lib/data/data_providers.dart
//
// Titik pemilihan sumber data (mock Phase A / REST Phase B).
//
// Presentation hanya memakai usecase dari file ini. Saat backend tersedia,
// ganti `FreeTableMockDataSource` dengan datasource remote tanpa mengubah
// screen, provider, atau entity.

import '../core/services/api_client/api_client.dart';
import '../core/services/token_storage/token_storage.dart';
import '../domain/entities/sales_chat_entity.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/free_table_usecases.dart';
import '../domain/usecases/help_usecases.dart';
import '../domain/usecases/profile_usecases.dart';
import '../domain/usecases/sales_chat_usecases.dart';
import 'datasources/mock/free_table_mock_datasource.dart';
import 'datasources/mock/help_mock_datasource.dart';
import 'datasources/mock/profile_mock_datasource.dart';
import 'datasources/mock/sales_chat_mock_datasource.dart';
import 'datasources/mock/storefront_mock_datasource.dart';
import 'datasources/remote/auth_remote_datasource.dart';
import 'datasources/remote/storefront_remote_datasource.dart';
import 'repositories/storefront_repository_impl.dart';
import '../domain/repositories/storefront_repository.dart';
import '../domain/usecases/storefront_usecases.dart';
import '../presentation/providers/storefront/customer_cart_controller.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/free_table_repository_impl.dart';
import 'repositories/help_repository_impl.dart';
import 'repositories/profile_repository_impl.dart';
import 'repositories/sales_chat_repository_impl.dart';

/// Factory dependency data tingkat aplikasi.
abstract final class DataProviders {
  static AuthRepository? _authRepository;
  static StorefrontRepository? _storefrontRepository;

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

  /// Usecase baca keranjang `GET /api/customer/keranjang`.
  static GetCart getCart() => GetCart(_storefront);

  /// Usecase simpan keranjang `PUT /api/customer/keranjang`.
  static SaveCart saveCart() => SaveCart(_storefront);

  /// Menghapus konfigurasi auth dan etalase (dipakai test).
  static void resetAuth() {
    _authRepository = null;
    _storefrontRepository = null;
    resetCartController();
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
