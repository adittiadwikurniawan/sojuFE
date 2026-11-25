import 'package:flutter/material.dart';

import '../widgets/buku_kita_wordmark.dart';
import '../widgets/onboarding_page_content.dart';

/// Halaman onboarding 1 — "Kelola Keuangan Lebih Mudah".
class OnboardingPageOne extends StatelessWidget {
  const OnboardingPageOne({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageContent(
      scale: scale,
      illustrationWidth: 222 * scale,
      illustration: BukuKitaWordmark(scale: scale),
      title: 'Kelola Keuangan Lebih Mudah',
      description:
          'Catat setiap pemasukan dan pengeluaran bisnismu secara instan. '
          'Asisten AI kami bantu kelola arus kas harianmu dalam hitungan detik.',
    );
  }
}
