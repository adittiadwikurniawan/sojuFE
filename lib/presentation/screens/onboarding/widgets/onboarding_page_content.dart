import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import 'entrance.dart';

/// Konten satu halaman onboarding: ilustrasi di area gradien atas, lalu judul
/// dan deskripsi di area kartu putih.
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.scale,
    required this.illustrationWidth,
    required this.illustration,
    required this.title,
    required this.description,
  });

  final double scale;
  final double illustrationWidth;
  final Widget illustration;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 418,
          child: Center(
            child: Entrance(
              offset: 18 * scale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: illustrationWidth,
                  child: illustration,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 514,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16 * scale, 76 * scale, 16 * scale, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Entrance(
                  delay: const Duration(milliseconds: 90),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 29.5 * scale,
                      fontWeight: FontWeight.w700,
                      height: 32 / 29.5,
                      letterSpacing: -0.59 * scale,
                      color: SojuColors.ink,
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
                Entrance(
                  delay: const Duration(milliseconds: 180),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 17.6 * scale,
                      fontWeight: FontWeight.w400,
                      height: 24 / 17.6,
                      color: SojuColors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
