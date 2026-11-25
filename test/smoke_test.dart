// Smoke test: memastikan aplikasi dapat di-boot dan memutar efek splash.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/app/app.dart';
import 'package:soju_fe/presentation/screens/onboarding/widgets/splash_blob.dart';

void main() {
  testWidgets('SojuApp memutar splash lalu menampilkan wordmark dan tombol', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SojuApp());

    // Awal (Ob 1): bentuk splash masih berupa lingkaran kecil di tengah.
    final Size initial = tester.getSize(find.byType(SplashBlob));
    expect(initial.width, closeTo(92, 1));
    expect(initial.height, closeTo(92, 1));

    await tester.pump(const Duration(milliseconds: 2000));

    // Akhir (Ob 5/Ob 6): bentuk splash memenuhi layar, logo dan tombol muncul.
    final Size grown = tester.getSize(find.byType(SplashBlob));
    expect(grown.width, greaterThan(430));
    expect(grown.height, greaterThan(932));
    expect(find.text('Buku Kita'), findsWidgets);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}
