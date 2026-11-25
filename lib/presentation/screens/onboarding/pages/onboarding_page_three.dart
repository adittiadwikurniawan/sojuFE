import 'package:flutter/material.dart';

import '../widgets/onboarding_page_content.dart';

/// Halaman onboarding 3 — ilustrasi gambar penuh.
class OnboardingPageThree extends StatelessWidget {
  const OnboardingPageThree({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageContent(
      scale: scale,
      illustrationWidth: 415 * scale,
      illustration: Image.asset(
        'assets/images/onboarding_3_illustration.png',
        fit: BoxFit.contain,
      ),
      title: 'Stok Aman & Terkendali',
      description:
          'Sinkronkan data fisik dan sistem dengan tingkat akurasi tinggi. '
          'Cegah selisih barang dan pantau pergerakan inventaris dengan aman.',
    );
  }
}
