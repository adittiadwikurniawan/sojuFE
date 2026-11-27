// Smoke test: memastikan aplikasi SojuApp dapat di-boot langsung ke Beranda Tamu SOJU.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/app/app.dart';

void main() {
  testWidgets('SojuApp langsung membuka Beranda Tamu SOJU tanpa splash', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SojuApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer_home_screen')), findsOneWidget);
    expect(find.text('Menu Unggulan ★'), findsOneWidget);
  });
}
