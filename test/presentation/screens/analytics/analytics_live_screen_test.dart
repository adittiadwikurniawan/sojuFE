// test/presentation/screens/analytics/analytics_live_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/transaction_entity.dart';
import 'package:soju_fe/domain/repositories/transaction_repository.dart';
import 'package:soju_fe/domain/usecases/transaction_usecases.dart';
import 'package:soju_fe/presentation/providers/transactions/transactions_controller.dart';
import 'package:soju_fe/presentation/screens/analytics/analytics_screen.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_transaction.dart';
import 'package:soju_fe/presentation/widgets/bar_chart_card.dart';

class _FakeTransactionRepository implements TransactionRepository {
  Result<List<TransactionEntity>>? result;

  @override
  Future<Result<List<TransactionEntity>>> fetchTransactions({
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    return result ??
        Result.success(<TransactionEntity>[
          TransactionEntity(
            id: 1,
            code: 'TRX-101',
            title: 'Penjualan Risol Mayo',
            category: 'Siap Saji',
            date: DateTime(2026, 11, 24),
            type: TransactionType.income,
            amount: 35000,
          ),
        ]);
  }
}

void main() {
  group('AnalyticsScreen Reactive Live States', () {
    late _FakeTransactionRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakeTransactionRepository();
    });

    Widget createWidgetUnderTest({TransactionsController Function()? factory}) {
      return MaterialApp(
        home: AnalyticsScreen(
          controllerFactory: factory ??
              () => TransactionsController(
                    getTransactions: GetTransactions(fakeRepo),
                  ),
        ),
      );
    }

    testWidgets('renders loading state initially while loading', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final controller = TransactionsController(
        getTransactions: GetTransactions(fakeRepo),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(factory: () => controller),
      );

      expect(find.byKey(const Key('analytics_loading')), findsOneWidget);
      expect(find.text('Memuat data transaksi...'), findsOneWidget);
    });

    testWidgets(
      'keeps BarChartCard visible when transaction list is empty and allows reload',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        fakeRepo.result = Result.success(<TransactionEntity>[]);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(BarChartCard), findsOneWidget);
        expect(find.text('Tren Arus Kas Harian'), findsOneWidget);

        final Finder retryBtn =
            find.byKey(const Key('analytics_empty_retry_button'));
        await tester.ensureVisible(retryBtn);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('analytics_empty')), findsOneWidget);
        expect(find.text('Belum ada data transaksi'), findsOneWidget);

        fakeRepo.result = Result.success(<TransactionEntity>[
          TransactionEntity(
            id: 2,
            code: 'TRX-102',
            title: 'Penjualan Dimsum',
            category: 'Siap Saji',
            date: DateTime(2026, 11, 24),
            type: TransactionType.income,
            amount: 50000,
          ),
        ]);
        await tester.tap(retryBtn);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('analytics_empty')), findsNothing);
        expect(find.text('Penjualan Dimsum'), findsOneWidget);
      },
    );

    testWidgets('renders error state on failure and allows retry', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      fakeRepo.result = Result.failure(
        const ServerFailure(message: 'Gagal mengambil data transaksi'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('analytics_error')), findsOneWidget);
      expect(find.text('Gagal mengambil data transaksi'), findsOneWidget);
      expect(find.byKey(const Key('analytics_retry_button')), findsOneWidget);

      fakeRepo.result = Result.success(<TransactionEntity>[
        TransactionEntity(
          id: 3,
          code: 'TRX-103',
          title: 'Restock Daging Ayam',
          category: 'Bahan Baku',
          date: DateTime(2026, 11, 24),
          type: TransactionType.expense,
          amount: 150000,
        ),
      ]);
      await tester.tap(find.byKey(const Key('analytics_retry_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('analytics_error')), findsNothing);
      expect(find.text('Restock Daging Ayam'), findsOneWidget);
    });

    testWidgets('renders live data state with transactions and summary', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      fakeRepo.result = Result.success(<TransactionEntity>[
        TransactionEntity(
          id: 1,
          code: 'TRX-101',
          title: 'Penjualan Risol Mayo',
          category: 'Siap Saji',
          date: DateTime(2026, 11, 24),
          type: TransactionType.income,
          amount: 35000,
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Penjualan Risol Mayo'), findsOneWidget);
      expect(find.text('1 Transaksi'), findsOneWidget);
    });
  });
}
