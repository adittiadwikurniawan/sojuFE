// Widget test: navbar bawah Buku Dapur sesuai node Figma `801:4265`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/themes/soju_colors.dart';
import 'package:soju_fe/presentation/widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('navbar memuat label Figma, tombol tambah, dan tab aktif biru', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    BottomNavTab? selected;
    bool addTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: BukuDapurBottomNavBar(
            activeTab: BottomNavTab.audit,
            onTabSelected: (BottomNavTab tab) => selected = tab,
            onAddTap: () => addTapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder nav = find.byType(BukuDapurBottomNavBar);
    expect(nav, findsOneWidget);
    expect(find.byKey(const Key('bottom_nav_glass')), findsOneWidget);
    expect(find.byType(BackdropFilter), findsWidgets);

    final Iterable<Text> labels = tester.widgetList<Text>(
      find.descendant(of: nav, matching: find.byType(Text)),
    );
    expect(
      labels.map((Text text) => text.data).toList(),
      <String?>['Home', 'Analytics', 'Ai Asistant', 'Audit & Stok'],
    );
    expect(find.byIcon(Icons.add), findsOneWidget);

    final Text activeLabel = tester.widget<Text>(
      find.descendant(of: nav, matching: find.text('Audit & Stok')),
    );
    expect(activeLabel.style?.color, SojuColors.primary);

    await tester
        .tap(find.descendant(of: nav, matching: find.text('Analytics')));
    await tester.pumpAndSettle();
    expect(selected, BottomNavTab.analytics);

    await tester.tap(find.byKey(const Key('bottom_nav_add')));
    await tester.pumpAndSettle();
    expect(addTapped, isTrue);
  });

  testWidgets('konten navbar berada di atas area aman bawah', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 24),
          ),
          child: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: BukuDapurBottomNavBar(
              activeTab: BottomNavTab.home,
              onTabSelected: (_) {},
              onAddTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final double contentBottom = tester
        .getBottomLeft(
          find.byKey(const Key('bottom_nav_content')),
        )
        .dy;

    expect(contentBottom, lessThanOrEqualTo(932 - 24 + 1));
  });
}
