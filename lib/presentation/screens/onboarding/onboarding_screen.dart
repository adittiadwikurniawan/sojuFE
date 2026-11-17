import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import 'pages/onboarding_page_one.dart';
import 'pages/onboarding_page_three.dart';
import 'pages/onboarding_page_two.dart';
import 'widgets/circle_back_button.dart';
import 'widgets/onboarding_background.dart';
import 'widgets/onboarding_card.dart';
import 'widgets/onboarding_footer.dart';

/// Carousel onboarding (3 langkah) hasil slicing Figma `On Boarding 1–3`.
///
/// Struktur: latar gradien + glow, kartu putih (statis), konten halaman
/// (ilustrasi + judul + deskripsi) yang dapat digeser, lalu footer navigasi
/// (indikator langkah + tombol + lewati) yang juga statis.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 3;
  static const Duration _pageTransition = Duration(milliseconds: 380);

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pageCount - 1) {
      _controller.nextPage(
          duration: _pageTransition, curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_index > 0) {
      _controller.previousPage(
        duration: _pageTransition,
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go(AppRoutes.splash);
    }
  }

  void _finish() {
    // Selesai onboarding -> daftar akun sebelum masuk beranda.
    context.go(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double contentWidth = math.min(constraints.maxWidth, 480);
          final double scale = contentWidth / 430;
          final double height = constraints.maxHeight;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              height: height,
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(child: OnboardingBackground()),
                  Positioned(
                    top: height * (418 / 932),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: OnboardingCard(scale: scale),
                  ),
                  Positioned.fill(
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
                      children: <Widget>[
                        OnboardingPageOne(scale: scale),
                        OnboardingPageTwo(scale: scale),
                        OnboardingPageThree(scale: scale),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16 * scale,
                    right: 16 * scale,
                    bottom: 45 * scale,
                    child: OnboardingFooter(
                      scale: scale,
                      stepCount: _pageCount,
                      currentStep: _index,
                      buttonLabel: 'Lanjutkan',
                      onButtonPressed: _next,
                      onSkip: _finish,
                    ),
                  ),
                  Positioned(
                    left: 16 * scale,
                    top: MediaQuery.paddingOf(context).top + 13 * scale,
                    child: CircleBackButton(onPressed: _back, scale: scale),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
