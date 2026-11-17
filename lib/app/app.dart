import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/themes/app_theme.dart';
import 'routes/app_routes.dart';

/// Root widget aplikasi Soju.
///
/// Menyusun tema dan router (GoRouter). Dependency injection (Riverpod) akan
/// ditambahkan saat slicing fitur data dimulai. Lihat `ARCHITECTURE.md` §2.4.
class SojuApp extends StatefulWidget {
  const SojuApp({super.key});

  @override
  State<SojuApp> createState() => _SojuAppState();
}

class _SojuAppState extends State<SojuApp> {
  late final GoRouter _router = AppRouter.create();

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
