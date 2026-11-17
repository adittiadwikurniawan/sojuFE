import 'package:flutter/material.dart';

import '../../../../core/themes/soju_colors.dart';

/// Kartu putih dengan sudut atas membulat dan lekuk sirkular di tengah atas,
/// meniru bentuk `Subtract` pada Figma.
class OnboardingCard extends StatelessWidget {
  const OnboardingCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _OnboardingCardClipper(scale: scale),
      child: const SizedBox.expand(
        child: ColoredBox(color: SojuColors.surface),
      ),
    );
  }
}

class _OnboardingCardClipper extends CustomClipper<Path> {
  const _OnboardingCardClipper({required this.scale});

  final double scale;

  @override
  Path getClip(Size size) {
    final Path card = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Offset.zero & size,
          topLeft: Radius.circular(67 * scale),
          topRight: Radius.circular(67 * scale),
        ),
      );
    final Path notch = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, -54 * scale),
          radius: 78 * scale,
        ),
      );
    return Path.combine(PathOperation.difference, card, notch);
  }

  @override
  bool shouldReclip(_OnboardingCardClipper oldClipper) =>
      oldClipper.scale != scale;
}
