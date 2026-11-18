// lib/presentation/widgets/bottom_glass_overlay.dart
//
// Lapisan kaca di bawah layar, diambil dari node Figma `586:1740`.
//
// Berbeda dari blur biasa, [BackdropFilter] memblur isi halaman yang bergulir
// di belakang lapisan ini sehingga efek glassmorphism terlihat saat scroll.

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Tinggi desain lapisan kaca (node `586:1740`).
const double kBottomGlassOverlayHeight = 137;

/// Jarak aman bawah untuk konten yang dapat digulir di dalam shell navbar.
///
/// 137 px lapisan kaca + 24 px jarak desain.
const double kBottomContentInset = kBottomGlassOverlayHeight + 24;

/// Lapisan gradien putih dengan blur latar.
class BottomGlassOverlay extends StatelessWidget {
  const BottomGlassOverlay({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('bottom_glass_overlay'),
      height: kBottomGlassOverlayHeight * scale,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4.9 * scale,
            sigmaY: 4.9 * scale,
          ),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0x33FFFFFF),
                  Color(0x0DFFFFFF),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
