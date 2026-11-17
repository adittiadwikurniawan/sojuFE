import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import 'widgets/buku_kita_wordmark.dart';
import 'widgets/outlined_action_button.dart';
import 'widgets/splash_blob.dart';

/// Layar splash / sambutan (Figma `Ob 1`–`Ob 6`).
///
/// Efek splash mengikuti keyframe desain: sebuah bentuk gradien "memercik"
/// dari lingkaran kecil di tengah layar (`Ob 1`) lalu membesar memenuhi layar
/// (`Ob 2`–`Ob 5`), setelah itu wordmark "Buku Kita" muncul (`Ob 6`) dan
/// disusul tombol "Mulai Sekarang".
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 1900);

  /// Ukuran blob tiap keyframe Figma (`Ob 1`..`Ob 5`) dalam px frame 430.
  static const List<double> _widthKeys = <double>[92, 279, 310, 310, 978];
  static const List<double> _heightKeys = <double>[92, 279, 259, 216, 1112];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  )..forward();

  late final Animation<double> _blobT = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6),
  );
  late final Animation<double> _blobWidth =
      _sequence(_widthKeys).animate(_blobT);
  late final Animation<double> _blobHeight =
      _sequence(_heightKeys).animate(_blobT);

  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.55, 0.82, curve: Curves.easeOut),
  );
  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.55, 0.85, curve: Curves.easeOutBack),
  );
  late final Animation<double> _buttonReveal = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.78, 1, curve: Curves.easeOutCubic),
  );

  /// Rangkaian tween antar keyframe ukuran dengan easing halus.
  static TweenSequence<double> _sequence(List<double> keys) {
    return TweenSequence<double>(<TweenSequenceItem<double>>[
      for (int i = 0; i < keys.length - 1; i++)
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: keys[i], end: keys[i + 1]).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
          // Segmen terakhir (membesar memenuhi layar) diberi porsi lebih besar.
          weight: i == keys.length - 2 ? 2 : 1,
        ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double contentWidth = math.min(constraints.maxWidth, 480);
          final double scale = contentWidth / 430;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: OverflowBox(
                      minWidth: 0,
                      maxWidth: double.infinity,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget? child) {
                          return SplashBlob(
                            width: _blobWidth.value,
                            height: _blobHeight.value,
                            scale: scale,
                          );
                        },
                      ),
                    ),
                  ),
                  Center(
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.82, end: 1).animate(
                          _logoScale,
                        ),
                        child: BukuKitaWordmark(scale: scale),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16 * scale,
                    right: 16 * scale,
                    bottom: 85 * scale,
                    child: FadeTransition(
                      opacity: _buttonReveal,
                      child: AnimatedBuilder(
                        animation: _buttonReveal,
                        builder: (BuildContext context, Widget? child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              24 * scale * (1 - _buttonReveal.value),
                            ),
                            child: child,
                          );
                        },
                        child: OutlinedActionButton(
                          label: 'Mulai Sekarang',
                          scale: scale,
                          onPressed: () => context.go(AppRoutes.onboarding),
                        ),
                      ),
                    ),
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
