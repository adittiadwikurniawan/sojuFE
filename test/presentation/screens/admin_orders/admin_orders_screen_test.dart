// test/presentation/screens/admin_orders/admin_orders_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';
import 'package:soju_fe/domain/repositories/admin_order_repository.dart';
import 'package:soju_fe/domain/usecases/admin_order_usecases.dart';
import 'package:soju_fe/presentation/providers/admin_orders/admin_orders_controller.dart';
import 'package:soju_fe/presentation/screens/admin_orders/admin_orders_screen.dart';

class _FakeAdminOrderRepository implements AdminOrderRepository {
  List<CustomerOrder> orders = <CustomerOrder>[
    CustomerOrder(
      id: 99,
      code: 'SOJU-999',
      customerId: 1,
      recipientName: 'Dewi Lestari',
      recipientEmail: 'dewi@example.com',
      recipientPhone: '08123456789',
      recipientAddress: 'Jl. Sudirman No. 10',
      total: 50000,
      status: CustomerOrderStatus.menungguKonfirmasi,
      createdAt: DateTime(2026, 11, 24, 14, 30),
      items: const <CustomerOrderItem>[
        CustomerOrderItem(
          id: 1,
          orderId: 99,
          productId: 10,
          productName: 'Sosis Solo',
          price: 25000,
          quantity: 2,
          subtotal: 50000,
        ),
      ],
    ),
  ];

  bool shouldFail = false;

  @override
  Future<Result<List<CustomerOrder>>> fetchOrders({CustomerOrderStatus? status}) async {
    if (shouldFail) {
      return Result.failure(const ServerFailure(message: 'Gagal memuat dari server'));
    }
    if (status == null) {
      return Result.success(orders);
    }
    return Result.success(orders.where((CustomerOrder o) => o.status == status).toList());
  }

  @override
  Future<Result<CustomerOrder>> updateOrderStatus({
    required int orderId,
    required CustomerOrderStatus status,
  }) async {
    final int idx = orders.indexWhere((CustomerOrder o) => o.id == orderId);
    if (idx != -1) {
      final CustomerOrder updated = CustomerOrder(
        id: orders[idx].id,
        code: orders[idx].code,
        customerId: orders[idx].customerId,
        recipientName: orders[idx].recipientName,
        recipientEmail: orders[idx].recipientEmail,
        recipientPhone: orders[idx].recipientPhone,
        recipientAddress: orders[idx].recipientAddress,
        total: orders[idx].total,
        status: status,
        createdAt: orders[idx].createdAt,
        items: orders[idx].items,
      );
      orders[idx] = updated;
      return Result.success(updated);
    }
    return Result.failure(const ServerFailure(message: 'Pesanan tidak ditemukan'));
  }
}

void main() {
  group('AdminOrdersScreen Widget Test', () {
    late _FakeAdminOrderRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakeAdminOrderRepository();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: AdminOrdersScreen(
          controllerFactory: () => AdminOrdersController(
            getAdminOrders: GetAdminOrders(fakeRepo),
            updateAdminOrderStatus: UpdateAdminOrderStatus(fakeRepo),
          ),
        ),
      );
    }

    testWidgets('renders list of orders and updates status via dropdown', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Memastikan header, filter chips, dan kartu pesanan tampil
      expect(find.text('Pesanan Pelanggan'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('#SOJU-999'), findsOneWidget);
      expect(find.text('Pemesan: Dewi Lestari (08123456789)'), findsOneWidget);
      expect(find.text('2x Sosis Solo'), findsOneWidget);
      expect(find.text('Total Pembayaran'), findsOneWidget);
      expect(find.text('Rp 50.000'), findsWidgets);
      expect(find.text('Menunggu Konfirmasi'), findsWidgets);

      // Verifikasi flow update status via dropdown
      final dropdownFinder = find.byKey(const Key('order_status_dropdown_99'));
      expect(dropdownFinder, findsOneWidget);

      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Pilih status 'Diproses' dari menu dropdown
      final diprosesOption = find.text('Diproses').last;
      await tester.tap(diprosesOption);
      await tester.pumpAndSettle();

      // Verifikasi status pesanan berhasil diperbarui
      expect(fakeRepo.orders.first.status, CustomerOrderStatus.diproses);
      expect(find.text('Status pesanan #SOJU-999 diubah menjadi Diproses'), findsOneWidget);
    });

    testWidgets('displays empty state when no orders found', (
      WidgetTester tester,
    ) async {
      fakeRepo.orders = <CustomerOrder>[];
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_orders_empty')), findsOneWidget);
      expect(find.text('Belum ada pesanan'), findsOneWidget);
    });

    testWidgets('displays error state and allows retry', (
      WidgetTester tester,
    ) async {
      fakeRepo.shouldFail = true;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_orders_error')), findsOneWidget);
      expect(find.text('Gagal memuat dari server'), findsOneWidget);

      // Fix repo and tap retry
      fakeRepo.shouldFail = false;
      await tester.tap(find.byKey(const Key('admin_orders_retry_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_orders_error')), findsNothing);
      expect(find.text('#SOJU-999'), findsOneWidget);
    });
  });
}
