// test/presentation/providers/customer/customer_orders_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';
import 'package:soju_fe/domain/repositories/customer_order_repository.dart';
import 'package:soju_fe/domain/usecases/customer_order_usecases.dart';
import 'package:soju_fe/presentation/providers/customer/customer_orders_controller.dart';

class _FakeOrderRepo implements CustomerOrderRepository {
  Result<List<CustomerOrder>>? ordersResult;
  Result<CustomerOrder>? detailResult;

  @override
  Future<Result<CustomerOrder>> checkout({required String address}) =>
      throw UnimplementedError();

  @override
  Future<Result<List<CustomerOrder>>> fetchOrders() async {
    return ordersResult ??
        Result<List<CustomerOrder>>.success(
          <CustomerOrder>[
            CustomerOrder(
              id: 1,
              code: 'PSN-1',
              customerId: 1,
              recipientName: 'Budi',
              recipientEmail: 'budi@test.com',
              recipientPhone: '081',
              recipientAddress: 'Jl. A',
              total: 45000,
              status: CustomerOrderStatus.menungguKonfirmasi,
              createdAt: DateTime(2026, 11, 25),
            ),
            CustomerOrder(
              id: 2,
              code: 'PSN-2',
              customerId: 1,
              recipientName: 'Budi',
              recipientEmail: 'budi@test.com',
              recipientPhone: '081',
              recipientAddress: 'Jl. A',
              total: 90000,
              status: CustomerOrderStatus.selesai,
              createdAt: DateTime(2026, 11, 24),
            ),
          ],
        );
  }

  @override
  Future<Result<CustomerOrder>> fetchOrderDetail(int id) async {
    return detailResult ??
        Result<CustomerOrder>.success(
          CustomerOrder(
            id: id,
            code: 'PSN-$id',
            customerId: 1,
            recipientName: 'Budi',
            recipientEmail: 'budi@test.com',
            recipientPhone: '081',
            recipientAddress: 'Jl. A',
            total: 45000,
            status: CustomerOrderStatus.diproses,
            createdAt: DateTime(2026, 11, 25),
          ),
        );
  }
}

void main() {
  late _FakeOrderRepo repo;
  late CustomerOrdersController controller;

  setUp(() {
    repo = _FakeOrderRepo();
    controller = CustomerOrdersController(
      getOrders: GetCustomerOrders(repo),
      getOrderDetail: GetCustomerOrderDetail(repo),
    );
  });

  tearDown(() => controller.dispose());

  group('CustomerOrdersController', () {
    test('loads orders and exposes them in order list', () async {
      expect(controller.isEmpty, isTrue);

      await controller.loadOrders();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.orders.length, 2);
      expect(controller.filteredOrders.length, 2);
    });

    test('filters orders by status correctly', () async {
      await controller.loadOrders();

      controller.setFilter(CustomerOrderStatus.selesai);
      expect(controller.filteredOrders.length, 1);
      expect(controller.filteredOrders.first.code, 'PSN-2');

      controller.setFilter(CustomerOrderStatus.diproses);
      expect(controller.filteredOrders, isEmpty);

      controller.setFilter(null);
      expect(controller.filteredOrders.length, 2);
    });

    test('sets error message on failure', () async {
      repo.ordersResult = Result<List<CustomerOrder>>.failure(
        const NetworkFailure(message: 'Jaringan internet terputus'),
      );

      await controller.loadOrders();

      expect(controller.isLoading, isFalse);
      expect(controller.orders, isEmpty);
      expect(controller.errorMessage, 'Jaringan internet terputus');
    });

    test('loads order detail by id', () async {
      final CustomerOrder? detail = await controller.loadOrderDetail(99);

      expect(detail, isNotNull);
      expect(detail?.id, 99);
      expect(controller.selectedOrderDetail?.code, 'PSN-99');
    });
  });
}
