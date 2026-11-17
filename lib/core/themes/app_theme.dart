import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'soju_colors.dart';

/// Tema tunggal aplikasi mobile Soju (lihat `ARCHITECTURE.md` §2.12).
///
/// Token warna/tipografi diambil dari Figma (`soju_colors.dart`,
/// `app_typography.dart`).
class AppTheme {
  const AppTheme._();

  /// Tema terang aplikasi.
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: SojuColors.primary,
    ).copyWith(
      primary: SojuColors.primary,
      surface: SojuColors.surface,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SojuColors.surface,
      fontFamily: AppTypography.family,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: AppTypography.family,
        bodyColor: SojuColors.ink,
        displayColor: SojuColors.ink,
      ),
    );
  }
}
