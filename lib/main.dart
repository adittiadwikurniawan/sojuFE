import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'data/data_providers.dart';
import 'data/datasources/remote/http_api_client.dart';
import 'data/datasources/remote/secure_token_storage.dart';
import 'presentation/providers/auth/auth_controller.dart';

/// Entry point aplikasi Soju.
///
/// Composition root: membuat adapter HTTP/token storage, mengonfigurasi
/// `DataProviders`, lalu menyerahkan `AuthController` ke router.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugPrint('[config] API_BASE_URL=${AppConfig.apiBaseUrl}');
  }

  final SecureTokenStorage tokenStorage = SecureTokenStorage();
  final HttpApiClient apiClient = HttpApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStorage: tokenStorage,
  );

  DataProviders.configure(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
    apiOrigin: AppConfig.apiOrigin,
  );

  final AuthController authController = AuthController(
    login: DataProviders.login(),
    register: DataProviders.register(),
    requestPasswordReset: DataProviders.requestPasswordReset(),
    resetPassword: DataProviders.resetPassword(),
    restoreSession: DataProviders.restoreSession(),
    logout: DataProviders.logout(),
  );

  // Validasi token tersimpan di latar belakang; router menampilkan splash
  // selama status `checking`.
  authController.bootstrap();

  runApp(SojuApp(authController: authController));
}
