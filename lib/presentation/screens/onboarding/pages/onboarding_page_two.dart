import 'package:flutter/material.dart';

import '../widgets/onboarding_page_content.dart';

/// Halaman onboarding 2 — daftar fitur pada kartu ilustrasi.
class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageContent(
      scale: scale,
      illustrationWidth: 246 * scale,
      illustration: Image.asset(
        'assets/images/onboarding_2_illustration.png',
        fit: BoxFit.contain,
      ),
      title: 'Stok Aman & Terkendali',
      description:
          'Sinkronkan data fisik dan sistem dengan tingkat akurasi tinggi. '
          'Cegah selisih barang dan pantau pergerakan inventaris dengan aman.',
    );
  }
}
