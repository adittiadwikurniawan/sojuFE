import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Layar penjaga saat feature flag prototype tidak aktif.
///
/// Halaman ini tidak muncul di navigasi produksi. Deep link hanya akan
/// menemukan layar penjelasan ini sampai flag diaktifkan untuk demo.
class SalesChatPrototypeDisabledScreen extends StatelessWidget {
  const SalesChatPrototypeDisabledScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: SojuColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SojuColors.hairline),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: SojuColors.demoSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.science_outlined,
                        color: SojuColors.demoInk,
                        size: 27,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Prototype belum aktif',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: SojuColors.notificationTitle,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Chat input penjualan harian/shift adalah prototype di '
                      'luar cakupan APK baca-saja. Aktifkan hanya untuk demo '
                      'lokal dengan:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12,
                        height: 1.5,
                        color: SojuColors.analyticsMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: SojuColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Text(
                        'flutter run \\\n'
                        '  --dart-define=ENABLE_SALES_CHAT_PROTOTYPE=true',
                        style: TextStyle(
                          fontFamily: AppTypography.wordmarkFamily,
                          fontSize: 10.5,
                          height: 1.5,
                          color: SojuColors.notificationTitle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('sales_chat_prototype_back'),
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.primary,
                        minimumSize: const Size(0, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
