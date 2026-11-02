// Smoke test untuk alur onboarding "Soju".
//
// Catatan: halaman 2 punya animasi "pulsing dot" yang berulang tanpa henti,
// jadi kita memakai `pump(duration)` alih-alih `pumpAndSettle()`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/main.dart';
import 'package:soju_fe/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen menampilkan halaman pertama',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Kelola Keuangan Bisnis Lebih\nMudah'), findsOneWidget);
    expect(find.text('Lanjutkan'), findsWidgets);
  });

  testWidgets('Tombol Lanjutkan pindah ke halaman kedua',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pump(const Duration(milliseconds: 1600));

    await tester.tap(find.text('Lanjutkan').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(
      find.text('Asisten AI Pintar & Kategorisasi Otomatis'),
      findsOneWidget,
    );
  });
}