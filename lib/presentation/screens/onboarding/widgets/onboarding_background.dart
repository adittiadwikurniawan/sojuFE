import 'package:flutter/material.dart';

import '../../../../core/themes/soju_colors.dart';

/// Latar halaman onboarding: gradien langit -> putih plus glow blur di area
/// atas (aset `onboarding_glow.png` hasil export dari Figma).
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double scale = constraints.maxWidth / 430;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const DecoratedBox(
              decoration: BoxDecoration(gradient: SojuColors.background),
            ),
            Positioned(
              top: constraints.maxHeight * (165 / 932),
              left: (constraints.maxWidth - 313 * scale) / 2,
              width: 313 * scale,
              child: Image.asset(
                'assets/images/onboarding_glow.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      },
    );
  }
}
