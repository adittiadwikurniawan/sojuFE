// test/presentation/providers/admin_controllers_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';
import 'package:soju_fe/domain/entities/dashboard_entity.dart';
import 'package:soju_fe/domain/entities/transaction_entity.dart';
import 'package:soju_fe/domain/repositories/admin_order_repository.dart';
import 'package:soju_fe/domain/repositories/dashboard_repository.dart';
import 'package:soju_fe/domain/repositories/transaction_repository.dart';
import 'package:soju_fe/domain/usecases/admin_order_usecases.dart';
import 'package:soju_fe/domain/usecases/dashboard_usecases.dart';
import 'package:soju_fe/domain/usecases/transaction_usecases.dart';
import 'package:soju_fe/presentation/providers/admin_orders/admin_orders_controller.dart';
import 'package:soju_fe/presentation/providers/dashboard/dashboard_controller.dart';
import 'package:soju_fe/presentation/providers/transactions/transactions_controller.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_transaction.dart';
import 'package:soju_fe/presentation/screens/dashboard/models/dashboard_view_data.dart';

class _MockDashboardRepository implements DashboardRepository {
  Result<DashboardSummaryEntity> result = Result.success(
    const DashboardSummaryEntity(
      cashBalance: 1200000,
      newOrdersCount: 4,
    ),
  );

  @override
  Future<Result<DashboardSummaryEntity>> fetchDashboardSummary({String period = '7d'}) async => result;
}

class _MockTransactionRepository implements TransactionRepository {
  Result<List<TransactionEntity>> result = Result.success(<TransactionEntity>[
    TransactionEntity(
      id: 1,
      code: 'TRX-1',
      title: 'Penjualan Risol',
      category: 'Siap Saji',
      date: DateTime(2026, 11, 24),
      type: TransactionType.income,
      amount: 25000,
    ),
  ]);

  @override
  Future<Result<List<TransactionEntity>>> fetchTransactions({String? search, String? startDate, String? endDate, int page = 1, int limit = 50}) async => result;
}

class _MockAdminOrderRepository implements AdminOrderRepository {
  Result<List<CustomerOrder>> listResult = Result.success(<CustomerOrder>[
    CustomerOrder(
      id: 10,
      code: 'ORD-10',
      customerId: 2,
      recipientName: 'Siti',
      recipientEmail: 'siti@example.com',
      recipientPhone: '0812999999',
      recipientAddress: 'Jl. Melati',
      total: 30000,
      status: CustomerOrderStatus.menungguKonfirmasi,
      createdAt: DateTime(2026, 11, 24),
    ),
  ]);

  Result<CustomerOrder> updateResult = Result.success(
    CustomerOrder(
      id: 10,
      code: 'ORD-10',
      customerId: 2,
      recipientName: 'Siti',
      recipientEmail: 'siti@example.com',
      recipientPhone: '0812999999',
      recipientAddress: 'Jl. Melati',
      total: 30000,
      status: CustomerOrderStatus.diproses,
      createdAt: DateTime(2026, 11, 24),
    ),
  );

  @override
  Future<Result<List<CustomerOrder>>> fetchOrders({CustomerOrderStatus? status}) async => listResult;

  @override
  Future<Result<CustomerOrder>> updateOrderStatus({required int orderId, required CustomerOrderStatus status}) async => updateResult;
}

void main() {
  group('DashboardController', () {
    test('loads summary and updates state to data', () async {
      final mockRepo = _MockDashboardRepository();
      final controller = DashboardController(getDashboardSummary: GetDashboardSummary(mockRepo));

      expect(controller.state.status, DashboardStatus.loading);
      await controller.load();

      expect(controller.state.status, DashboardStatus.data);
      expect(controller.state.summary?.cashBalance, 1200000);
      expect(controller.state.viewData?.metrics.first.value, 'Rp 1.200.000');
    });

    test('handles failure and sets error state', () async {
      final mockRepo = _MockDashboardRepository()..result = Result.failure(const ServerFailure(message: 'Server down'));
      final controller = DashboardController(getDashboardSummary: GetDashboardSummary(mockRepo));

      await controller.load();
      expect(controller.state.status, DashboardStatus.error);
      expect(controller.state.errorMessage, 'Server down');
    });

    test('sets empty status when zero operational activity', () async {
      final mockRepo = _MockDashboardRepository()
        ..result = Result.success(
          const DashboardSummaryEntity(
            cashBalance: 0,
            newOrdersCount: 0,
            recentActivities: <DashboardActivityData>[],
          ),
        );
      final controller = DashboardController(getDashboardSummary: GetDashboardSummary(mockRepo));

      await controller.load();
      expect(controller.state.status, DashboardStatus.empty);
      expect(controller.state.viewData?.metrics.first.value, 'Rp 0');
    });
  });

  group('TransactionsController', () {
    test('loads transactions and converts to view data', () async {
      final mockRepo = _MockTransactionRepository();
      final controller = TransactionsController(getTransactions: GetTransactions(mockRepo));

      await controller.load();
      expect(controller.state.status, TransactionsStatus.data);
      expect(controller.state.transactions.length, 1);
      expect(controller.state.viewData?.transactions.first.title, 'Penjualan Risol');
    });

    test('sets empty status when transactions list is empty', () async {
      final mockRepo = _MockTransactionRepository()..result = Result.success(<TransactionEntity>[]);
      final controller = TransactionsController(getTransactions: GetTransactions(mockRepo));

      await controller.load();
      expect(controller.state.status, TransactionsStatus.empty);
    });
  });

  group('AdminOrdersController', () {
    test('loads orders and updates single order status', () async {
      final mockRepo = _MockAdminOrderRepository();
      final controller = AdminOrdersController(
        getAdminOrders: GetAdminOrders(mockRepo),
        updateAdminOrderStatus: UpdateAdminOrderStatus(mockRepo),
      );

      await controller.load();
      expect(controller.state.status, AdminOrdersStatus.data);
      expect(controller.state.orders.length, 1);
      expect(controller.state.orders.first.status, CustomerOrderStatus.menungguKonfirmasi);

      final ok = await controller.updateStatus(orderId: 10, newStatus: CustomerOrderStatus.diproses);
      expect(ok, isTrue);
      expect(controller.state.orders.first.status, CustomerOrderStatus.diproses);
    });

    test('sets empty status when no orders returned', () async {
      final mockRepo = _MockAdminOrderRepository()..listResult = Result.success(<CustomerOrder>[]);
      final controller = AdminOrdersController(
        getAdminOrders: GetAdminOrders(mockRepo),
        updateAdminOrderStatus: UpdateAdminOrderStatus(mockRepo),
      );

      await controller.load();
      expect(controller.state.status, AdminOrdersStatus.empty);
    });
  });
}
