import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'soju_colors.dart';

/// Tema tunggal aplikasi mobile Soju (lihat `ARCHITECTURE.md` §2.12).
///
/// Token warna/tipografi diambil dari Figma (`soju_colors.dart`,
/// `app_typography.dart`).
class AppTheme {
  const AppTheme._();

  /// Tema terang aplikasi (selaras dengan prototype HTML SOJU `#1E3A8A` / `#F8FAFC`).
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: SojuColors.brandNavy,
    ).copyWith(
      primary: SojuColors.brandNavy,
      secondary: SojuColors.brandEmerald,
      surface: SojuColors.surface,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SojuColors.canvas,
      fontFamily: AppTypography.family,
    );

    return base.copyWith(
      dividerColor: SojuColors.cardBorder,
      textTheme: base.textTheme.apply(
        fontFamily: AppTypography.family,
        bodyColor: SojuColors.ink,
        displayColor: SojuColors.ink,
      ),
    );
  }
}
