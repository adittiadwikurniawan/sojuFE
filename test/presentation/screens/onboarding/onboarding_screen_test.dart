// Widget test: layar onboarding (carousel 3 langkah).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding menampilkan langkah pertama dan footer navigasi', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Kelola Keuangan Lebih Mudah'), findsOneWidget);
    expect(find.text('Lanjutkan'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
  });
}
