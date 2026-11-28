// Widget test: halaman "Lihat Semua" aktivitas.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/models/activity_view_data.dart';
import 'package:soju_fe/presentation/screens/activities/activities_screen.dart';
import 'package:soju_fe/presentation/widgets/activity_tile.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    List<ActivityData> activities = ActivityViewData.sample,
    VoidCallback? onBack,
    ValueChanged<ActivityData>? onActivityTap,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ActivitiesScreen(
          activities: activities,
          onBack: onBack,
          onActivityTap: onActivityTap,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan seluruh aktivitas dalam mode baca-saja', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Semua Aktivitas'), findsOneWidget);
    expect(find.text('4 aktivitas'), findsOneWidget);
    expect(find.byType(ActivityTile), findsNWidgets(4));
    // Detail belum menjadi bagian alur, jadi tombolnya tidak ditampilkan.
    expect(find.text('Detail'), findsNothing);
  });

  testWidgets('tombol kembali memanggil callback', (
    WidgetTester tester,
  ) async {
    bool backTapped = false;
    await pumpScreen(tester, onBack: () => backTapped = true);

    await tester.tap(find.byKey(const Key('activities_back')));
    await tester.pump();

    expect(backTapped, isTrue);
  });

  testWidgets('menampilkan empty state saat tidak ada aktivitas', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, activities: const <ActivityData>[]);

    expect(find.text('0 aktivitas'), findsOneWidget);
    expect(find.text('Belum ada aktivitas'), findsOneWidget);
    expect(find.byType(ActivityTile), findsNothing);
  });

  testWidgets('tombol Detail muncul saat callback disediakan', (
    WidgetTester tester,
  ) async {
    ActivityData? selected;
    await pumpScreen(
      tester,
      onActivityTap: (ActivityData activity) => selected = activity,
    );

    expect(find.text('Detail'), findsNWidgets(4));
    await tester.tap(find.text('Detail').first);
    await tester.pump();

    expect(selected?.name, 'Penjualan Sosis Bakar (5 Porsi)');
  });
}
