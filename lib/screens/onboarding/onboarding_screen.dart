import 'package:flutter/material.dart';
import '../../theme/soju_colors.dart';
import 'pages/onboarding_page_one.dart';
import 'pages/onboarding_page_two.dart';
import 'pages/onboarding_page_three.dart';
import 'pages/onboarding_page_four.dart';
import 'pages/onboarding_page_five.dart';
import 'pages/onboarding_page_six.dart';
import 'widgets/on_nav.dart';

/// Onboarding flow dengan PageView + PageController, animasi masuk
/// ketika halaman berganti (Fade+Slide staggered via [AnimationController]).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
    value: 1.0,
  );

  int _current = 0;
  final int _total = 6;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final p = _pageController.page?.round() ?? 0;
    if (p != _current) {
      setState(() => _current = p);
      _animController.forward(from: 0.0);
    }
  }

  void _next() {
    if (_current < _total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 560),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Selesai onboarding
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding selesai!')),
        );
      }
    }
  }

  void _prev() {
    if (_current > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 560),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SojuColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                children: [
                  OnNav(onNext: _next, onPrev: _prev, child: OnboardingPageOne(animation: _animController)),
                  OnNav(onNext: _next, onPrev: _prev, child: OnboardingPageTwo(animation: _animController)),
                  OnNav(onNext: _next, onPrev: _prev, child: OnboardingPageThree(animation: _animController)),
                  OnNav(onNext: _next, onPrev: _prev, child: OnboardingPageFour(animation: _animController)),
                  OnNav(onNext: _next, onPrev: _prev, child: OnboardingPageFive(animation: _animController)),
                  OnNav(onNext: _next, onPrev: _prev, child: OnboardingPageSix(animation: _animController)),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

