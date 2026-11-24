// test/presentation/screens/customer/customer_orders_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';
import 'package:soju_fe/domain/repositories/customer_order_repository.dart';
import 'package:soju_fe/domain/usecases/customer_order_usecases.dart';
import 'package:soju_fe/presentation/providers/customer/customer_orders_controller.dart';
import 'package:soju_fe/presentation/screens/customer/customer_orders_screen.dart';

class _FakeOrderRepo implements CustomerOrderRepository {
  Result<List<CustomerOrder>> getOrdersResult =
      Result<List<CustomerOrder>>.success(<CustomerOrder>[]);

  @override
  Future<Result<CustomerOrder>> checkout({required String address}) =>
      throw UnimplementedError();

  @override
  Future<Result<List<CustomerOrder>>> fetchOrders() async => getOrdersResult;

  @override
  Future<Result<CustomerOrder>> fetchOrderDetail(int id) async =>
      throw UnimplementedError();
}

void main() {
  late _FakeOrderRepo repository;
  late CustomerOrdersController controller;

  final CustomerOrder sampleOrder1 = CustomerOrder(
    id: 101,
    code: 'PSN-101',
    customerId: 1,
    recipientName: 'Pelanggan Test',
    recipientEmail: 'test@soju.com',
    recipientPhone: '081234567890',
    recipientAddress: 'Jl. Senopati No. 45',
    total: 90000,
    status: CustomerOrderStatus.menungguKonfirmasi,
    createdAt: DateTime(2026, 11, 25, 10, 0),
    items: const <CustomerOrderItem>[
      CustomerOrderItem(
        id: 1,
        orderId: 101,
        productId: 1,
        productName: 'Soju Peach',
        variant: 'Dingin',
        price: 45000,
        quantity: 2,
        note: 'Bungkus rapi',
        subtotal: 90000,
      ),
    ],
  );

  final CustomerOrder sampleOrder2 = CustomerOrder(
    id: 102,
    code: 'PSN-102',
    customerId: 1,
    recipientName: 'Pelanggan Test',
    recipientEmail: 'test@soju.com',
    recipientPhone: '081234567890',
    recipientAddress: 'Jl. Senopati No. 45',
    total: 45000,
    status: CustomerOrderStatus.selesai,
    createdAt: DateTime(2026, 11, 24, 15, 30),
    items: const <CustomerOrderItem>[
      CustomerOrderItem(
        id: 2,
        orderId: 102,
        productId: 2,
        productName: 'Soju Original',
        variant: null,
        price: 45000,
        quantity: 1,
        note: null,
        subtotal: 45000,
      ),
    ],
  );

  setUp(() {
    repository = _FakeOrderRepo();
    controller = CustomerOrdersController(
      getOrders: GetCustomerOrders(repository),
    );
  });

  tearDown(() => controller.dispose());

  testWidgets('renders empty state when customer has no orders', (WidgetTester tester) async {
    bool browseClicked = false;
    repository.getOrdersResult = Result<List<CustomerOrder>>.success(<CustomerOrder>[]);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerOrdersScreen(
          controller: controller,
          onBrowseMenu: () => browseClicked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pesanan Saya'), findsOneWidget);
    expect(find.text('Belum Ada Pesanan'), findsOneWidget);
    expect(find.byKey(const Key('customer_orders_empty_browse')), findsOneWidget);

    await tester.tap(find.byKey(const Key('customer_orders_empty_browse')));
    expect(browseClicked, isTrue);
  });

  testWidgets('renders error view with retry button on fetch failure', (WidgetTester tester) async {
    repository.getOrdersResult = Result<List<CustomerOrder>>.failure(
      const NetworkFailure(message: 'Gagal terhubung ke server'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerOrdersScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal terhubung ke server'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    repository.getOrdersResult = Result<List<CustomerOrder>>.success(<CustomerOrder>[sampleOrder1]);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('PSN-101'), findsOneWidget);
  });

  testWidgets('renders orders with status badges and item breakdown', (WidgetTester tester) async {
    repository.getOrdersResult = Result<List<CustomerOrder>>.success(
      <CustomerOrder>[sampleOrder1, sampleOrder2],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerOrdersScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Verify both orders rendered
    expect(find.text('PSN-101'), findsOneWidget);
    expect(find.text('PSN-102'), findsOneWidget);

    // Verify badges
    expect(find.text('Menunggu Konfirmasi'), findsWidgets); // chip + badge
    expect(find.text('Selesai'), findsWidgets); // chip + badge

    // Verify item breakdown in sampleOrder1
    expect(find.text('Soju Peach'), findsOneWidget);
    expect(find.text('Varian: Dingin'), findsOneWidget);
    expect(find.text('Catatan: "Bungkus rapi"'), findsOneWidget);
    expect(find.text('2 × Rp 45.000'), findsOneWidget);

    // Test filter chips: tap "Selesai"
    await tester.tap(find.text('Selesai').first);
    await tester.pumpAndSettle();

    expect(find.text('PSN-102'), findsOneWidget);
    expect(find.text('PSN-101'), findsNothing);

    // Tap "Semua" to restore all
    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();

    expect(find.text('PSN-101'), findsOneWidget);
    expect(find.text('PSN-102'), findsOneWidget);
  });
}
