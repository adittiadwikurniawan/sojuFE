import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/themes/app_theme.dart';
import '../presentation/providers/auth/auth_controller.dart';
import 'config/app_features.dart';
import 'routes/app_routes.dart';

/// Root widget aplikasi Soju.
///
/// Menyusun tema dan router (GoRouter). Dependency injection auth dibuat di
/// composition root (`main.dart`) dan di-inject lewat [authController].
class SojuApp extends StatefulWidget {
  const SojuApp({
    super.key,
    this.authController,
  });

  /// Controller auth dari composition root.
  ///
  /// `null` dipakai widget test lama yang tidak membutuhkan jaringan.
  final AuthController? authController;

  @override
  State<SojuApp> createState() => _SojuAppState();
}

class _SojuAppState extends State<SojuApp> {
  late final GoRouter _router = AppRouter.create(
    features: AppFeatures.fromEnvironment,
    authController: widget.authController,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Soju',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
