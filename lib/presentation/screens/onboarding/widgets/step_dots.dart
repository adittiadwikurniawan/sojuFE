import 'package:flutter/material.dart';

import '../../../../core/themes/soju_colors.dart';

/// Indikator langkah onboarding: pil memanjang untuk langkah aktif, titik
/// bulat untuk langkah lain.
class StepDots extends StatelessWidget {
  const StepDots({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.scale,
  });

  final int count;
  final int currentIndex;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int index = 0; index < count; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(horizontal: 4.5 * scale),
            width: (index == currentIndex ? 27 : 9) * scale,
            height: 9 * scale,
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? SojuColors.primaryDeep
                  : SojuColors.dotInactive,
              borderRadius: BorderRadius.circular(4.5 * scale),
            ),
          ),
      ],
    );
  }
}
