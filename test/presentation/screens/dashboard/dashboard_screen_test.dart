// Widget test: layar Beranda (ringkasan dashboard).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:soju_fe/presentation/screens/dashboard/models/dashboard_view_data.dart';

void main() {
  testWidgets('Beranda menampilkan bilah atas, metrik, grafik, dan aktivitas', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pump();

    expect(find.text('Cari Kas Mu'), findsOneWidget);
    expect(find.text('Total Penghasilan'), findsOneWidget);
    expect(find.text('Tanya BukuKita AI'), findsOneWidget);
    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Lihat Semua'), findsOneWidget);
    expect(
      find.text('Order Online #SOJU-108 (Sosis & Nugget Frozen)'),
      findsOneWidget,
    );
  });

  testWidgets('Total Penghasilan, tanggal, dan menu profil terhubung', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    int analyticsCount = 0;
    int viewProfileCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          onAnalyticsTap: () => analyticsCount++,
          onViewProfile: () => viewProfileCount++,
        ),
      ),
    );
    await tester.pump();

    // Kartu tanggal terpisah tidak lagi dipakai di Beranda; kontrol tanggal
    // berada di pil tanggal pada kartu Total Penghasilan.
    expect(find.byKey(const Key('date_filter_card')), findsNothing);
    expect(find.byKey(const Key('chart_date_pill')), findsOneWidget);

    await tester.tap(find.byKey(const Key('total_penghasilan_card')));
    await tester.pump();
    expect(analyticsCount, 1);

    await tester.tap(find.byKey(const Key('chart_date_pill')));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Tanggal'), findsOneWidget);
    expect(analyticsCount, 1);
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dashboard_avatar')));
    await tester.pumpAndSettle();
    expect(find.text('Adittia'), findsOneWidget);
    expect(find.text('adittia@sojucorp.com'), findsOneWidget);
    expect(find.text('Lihat Profil'), findsOneWidget);
    expect(find.text('Tambah Akun'), findsNothing);
    expect(find.text('Kelola Akun'), findsNothing);

    await tester.tap(find.byKey(const Key('profile_view_profile')));
    await tester.pumpAndSettle();
    expect(viewProfileCount, 1);
  });

  testWidgets('Beranda merender data dari model, bukan hardcode', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const DashboardViewData data = DashboardViewData(
      avatarAsset: 'assets/images/avatar_profil.png',
      searchHint: 'Cari apa saja',
      metrics: <DashboardMetricData>[
        DashboardMetricData(
          title: 'Laba Bersih',
          value: 'Rp 100.000',
          note: 'Margin 10%',
        ),
      ],
      revenue: RevenueSummary(
        title: 'Penghasilan',
        dateLabel: '1 Jan 2027',
        total: 'Rp 1.000.000',
        growth: '+5%',
        axisMax: 100,
        days: <RevenueDayData>[
          RevenueDayData(label: 'Senin', thisWeek: 50, lastWeek: 40),
        ],
        lastWeekLegend: 'Minggu Lalu',
        thisWeekLegend: 'Minggu Sekarang',
      ),
      assistant: AssistantCardData(
        title: 'Tanya AI',
        subtitle: 'Asisten kas',
        inputHint: 'Tulis perintah',
        quickCommands: <AssistantCommandData>[
          AssistantCommandData(
            label: '/add',
            labelSize: 13,
            icon: Icons.add,
          ),
        ],
      ),
      activities: <DashboardActivityData>[
        DashboardActivityData(
          name: 'Kopi',
          variant: 'Manis',
          sku: 'SKU: KOPI - 01',
          pack: '1 Pack',
          badge: 'Pengeluaran',
          imageAsset: 'assets/images/activity_sosis.png',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(home: DashboardScreen(data: data)),
    );
    await tester.pump();

    expect(find.text('Cari apa saja'), findsOneWidget);
    expect(find.text('Laba Bersih'), findsOneWidget);
    expect(find.text('Penghasilan'), findsOneWidget);
    expect(find.text('Tanya AI'), findsOneWidget);
    expect(find.text('Kopi'), findsOneWidget);
    expect(find.text('Sosis'), findsNothing);
  });
}
