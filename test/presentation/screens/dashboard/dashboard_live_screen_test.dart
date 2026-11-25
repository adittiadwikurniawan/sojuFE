// test/presentation/screens/dashboard/dashboard_live_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/dashboard_entity.dart';
import 'package:soju_fe/domain/repositories/dashboard_repository.dart';
import 'package:soju_fe/domain/usecases/dashboard_usecases.dart';
import 'package:soju_fe/presentation/providers/dashboard/dashboard_controller.dart';
import 'package:soju_fe/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:soju_fe/presentation/screens/dashboard/models/dashboard_view_data.dart';
import 'package:soju_fe/presentation/screens/dashboard/widgets/revenue_chart_card.dart';

class _FakeDashboardRepository implements DashboardRepository {
  Result<DashboardSummaryEntity>? result;

  @override
  Future<Result<DashboardSummaryEntity>> fetchDashboardSummary({
    String period = '7d',
  }) async {
    return result ??
        Result.success(
          const DashboardSummaryEntity(
            cashBalance: 7500000,
            newOrdersCount: 12,
          ),
        );
  }
}

void main() {
  group('DashboardScreen Reactive Live States', () {
    late _FakeDashboardRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakeDashboardRepository();
    });

    Widget createWidgetUnderTest({DashboardController Function()? factory}) {
      return MaterialApp(
        home: DashboardScreen(
          controllerFactory: factory ??
              () => DashboardController(
                    getDashboardSummary: GetDashboardSummary(fakeRepo),
                  ),
        ),
      );
    }

    testWidgets('renders loading state initially while loading', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final controller = DashboardController(
        getDashboardSummary: GetDashboardSummary(fakeRepo),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(factory: () => controller),
      );

      expect(find.byKey(const Key('dashboard_loading')), findsOneWidget);
      expect(find.text('Memuat ringkasan operasional...'), findsOneWidget);
    });

    testWidgets(
      'keeps RevenueChartCard visible when operational data is zero and allows reload',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        fakeRepo.result = Result.success(
          const DashboardSummaryEntity(
            cashBalance: 0,
            newOrdersCount: 0,
            recentActivities: <DashboardActivityData>[],
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(RevenueChartCard), findsOneWidget);
        expect(find.text('Total Penghasilan'), findsOneWidget);
        expect(find.byKey(const Key('dashboard_empty')), findsOneWidget);

        fakeRepo.result = Result.success(
          const DashboardSummaryEntity(
            cashBalance: 5000000,
            newOrdersCount: 3,
          ),
        );
        final Finder retryBtn =
            find.byKey(const Key('dashboard_empty_retry_button'));
        await tester.ensureVisible(retryBtn);
        await tester.pumpAndSettle();
        await tester.tap(retryBtn);
        await tester.pumpAndSettle();

        expect(find.text('Rp 5.000.000'), findsWidgets);
        expect(find.text('3 Pesanan'), findsOneWidget);
      },
    );

    testWidgets('renders error state on failure and allows retry', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      fakeRepo.result = Result.failure(
        const ServerFailure(message: 'Koneksi ke backend terputus'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard_error')), findsOneWidget);
      expect(find.text('Koneksi ke backend terputus'), findsOneWidget);
      expect(find.byKey(const Key('dashboard_retry_button')), findsOneWidget);

      fakeRepo.result = Result.success(
        const DashboardSummaryEntity(
          cashBalance: 2500000,
          newOrdersCount: 7,
        ),
      );
      await tester.tap(find.byKey(const Key('dashboard_retry_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard_error')), findsNothing);
      expect(find.text('Rp 2.500.000'), findsWidgets);
      expect(find.text('7 Pesanan'), findsOneWidget);
    });

    testWidgets('renders live data state with metrics and charts', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      fakeRepo.result = Result.success(
        const DashboardSummaryEntity(
          cashBalance: 8000000,
          newOrdersCount: 15,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(RevenueChartCard), findsOneWidget);
      expect(find.text('Rp 8.000.000'), findsWidgets);
      expect(find.text('15 Pesanan'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsWidgets);
      expect(find.text('Aktivitas'), findsOneWidget);
    });
  });
}
