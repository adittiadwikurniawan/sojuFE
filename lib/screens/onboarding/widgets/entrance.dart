import 'package:flutter/material.dart';

/// Staggered entrance animation for onboarding elements.
///
/// Setiap elemen halaman dibungkus `Entrance` dengan interval [begin]-[end]
/// pada animation controller halaman. Saat halaman menjadi aktif, controller
/// diputar dari 0 sehingga elemen muncul berurutan: fade-in + geser ke atas.
class Entrance extends StatelessWidget {
  const Entrance({
    super.key,
    required this.animation,
    required this.child,
    this.begin = 0.0,
    this.end = 1.0,
    this.dx = 0,
    this.dy = 0.12,
    this.curve = Curves.easeOutCubic,
  });

  final Animation<double> animation;
  final Widget child;
  final double begin;
  final double end;
  final double dx; // pergeseran horizontal (fraksi dari lebar widget)
  final double dy; // pergeseran vertikal (fraksi dari tinggi widget)
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: curve),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(dx, dy),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}