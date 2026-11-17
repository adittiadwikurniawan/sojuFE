import 'package:flutter/material.dart';

import 'primary_action_button.dart';
import 'skip_button.dart';
import 'step_dots.dart';

/// Zona navigasi bawah: indikator langkah, tombol utama, dan tautan lewati.
class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.scale,
    required this.stepCount,
    required this.currentStep,
    required this.buttonLabel,
    required this.onButtonPressed,
    required this.onSkip,
    this.showSkip = true,
  });

  final double scale;
  final int stepCount;
  final int currentStep;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final VoidCallback onSkip;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StepDots(
          count: stepCount,
          currentIndex: currentStep,
          scale: scale,
        ),
        SizedBox(height: 27 * scale),
        PrimaryActionButton(
          label: buttonLabel,
          onPressed: onButtonPressed,
          scale: scale,
        ),
        if (showSkip) ...<Widget>[
          SizedBox(height: 2 * scale),
          SkipButton(onPressed: onSkip, scale: scale),
        ],
      ],
    );
  }
}
