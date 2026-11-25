// test/presentation/screens/customer/customer_checkout_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/domain/repositories/customer_order_repository.dart';
import 'package:soju_fe/domain/repositories/storefront_repository.dart';
import 'package:soju_fe/domain/usecases/customer_order_usecases.dart';
import 'package:soju_fe/domain/usecases/storefront_usecases.dart';
import 'package:soju_fe/presentation/providers/customer/customer_checkout_controller.dart';
import 'package:soju_fe/presentation/providers/storefront/customer_cart_controller.dart';
import 'package:soju_fe/presentation/screens/customer/customer_checkout_screen.dart';

class _FakeOrderRepo implements CustomerOrderRepository {
  Result<CustomerOrder>? resultToReturn;
  String? capturedAddress;

  @override
  Future<Result<CustomerOrder>> checkout({required String address}) async {
    capturedAddress = address;
    return resultToReturn ??
        Result<CustomerOrder>.success(
          CustomerOrder(
            id: 1,
            code: 'PSN-SUCCESS-1',
            customerId: 1,
            recipientName: 'Pelanggan Test',
            recipientEmail: 'pelanggan@test.com',
            recipientPhone: '081234567890',
            recipientAddress: address,
            total: 90000,
            status: CustomerOrderStatus.menungguKonfirmasi,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<Result<List<CustomerOrder>>> fetchOrders() async =>
      Result<List<CustomerOrder>>.success(<CustomerOrder>[]);

  @override
  Future<Result<CustomerOrder>> fetchOrderDetail(int id) async =>
      throw UnimplementedError();
}

class _FakeStorefrontRepo implements StorefrontRepository {
  List<CartItem> items = <CartItem>[];

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search}) async =>
      Result<List<CatalogProduct>>.success(<CatalogProduct>[]);

  @override
  Future<Result<List<CartItem>>> fetchCart() async =>
      Result<List<CartItem>>.success(items);

  @override
  Future<Result<int>> saveCart(List<CartItem> newItems) async {
    items = List<CartItem>.from(newItems);
    return Result<int>.success(items.length);
  }
}

void main() {
  late _FakeOrderRepo orderRepo;
  late _FakeStorefrontRepo storefrontRepo;
  late CustomerCartController cartController;
  late CustomerCheckoutController checkoutController;

  const AuthUser testUser = AuthUser(
    id: 1,
    name: 'Pelanggan Test',
    email: 'pelanggan@test.com',
    role: UserRole.customer,
    phone: '081234567890',
    address: 'Jl. Senopati No. 10, Jakarta Selatan',
  );

  setUp(() {
    orderRepo = _FakeOrderRepo();
    storefrontRepo = _FakeStorefrontRepo();
    cartController = CustomerCartController(
      getCart: GetCart(storefrontRepo),
      saveCart: SaveCart(storefrontRepo),
    );
    checkoutController = CustomerCheckoutController(
      checkoutOrder: CheckoutCustomerOrder(orderRepo),
      initialAddress: testUser.address ?? '',
    );
  });

  tearDown(() {
    cartController.dispose();
    checkoutController.dispose();
  });

  testWidgets('renders empty cart view when cart has no items', (WidgetTester tester) async {
    bool browseClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCheckoutScreen(
          cartController: cartController,
          checkoutController: checkoutController,
          user: testUser,
          onBrowseMenu: () => browseClicked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Checkout Pesanan'), findsOneWidget);
    expect(find.text('Keranjang Kosong'), findsOneWidget);
    expect(find.byKey(const Key('customer_checkout_empty_browse')), findsOneWidget);

    await tester.tap(find.byKey(const Key('customer_checkout_empty_browse')));
    expect(browseClicked, isTrue);
  });

  testWidgets('back button triggers onBack callback', (WidgetTester tester) async {
    bool backClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCheckoutScreen(
          cartController: cartController,
          checkoutController: checkoutController,
          user: testUser,
          onBack: () => backClicked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('customer_checkout_back')));
    expect(backClicked, isTrue);
  });

  testWidgets('renders cart summary, address form, and handles successful checkout',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    bool viewOrdersClicked = false;

    // Add items to cart
    await cartController.addProduct(
      const CatalogProduct(
        id: 1,
        code: 'MN-1',
        name: 'Soju Peach',
        variants: <String>['Dingin'],
        unit: 'Botol',
        price: 45000,
      ),
      quantity: 2,
      variant: 'Dingin',
      note: 'Tambahkan es batu',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCheckoutScreen(
          cartController: cartController,
          checkoutController: checkoutController,
          user: testUser,
          onViewOrders: () => viewOrdersClicked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and user info
    expect(find.text('Checkout Pesanan'), findsOneWidget);
    expect(find.textContaining('Pelanggan Test'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);

    // Verify item breakdown
    expect(find.text('Soju Peach'), findsOneWidget);
    expect(find.text('Varian: Dingin'), findsOneWidget);
    expect(find.text('Catatan: "Tambahkan es batu"'), findsOneWidget);
    expect(find.text('2 × Rp 45.000'), findsOneWidget);
    expect(find.text('Rp 90.000'), findsWidgets);

    // Verify prefilled address in text field
    final Finder addressInput =
        find.byKey(const Key('customer_checkout_address_input'));
    expect(addressInput, findsOneWidget);
    expect(find.text(testUser.address!), findsOneWidget);

    // Enter a new address
    await tester.enterText(addressInput, 'Jl. Baru No. 99, Jakarta Pusat');
    await tester.pump();

    // Tap confirm checkout button
    await tester.ensureVisible(find.byKey(const Key('customer_checkout_button')));
    await tester.ensureVisible(find.byKey(const Key('customer_checkout_button')));
    await tester.tap(find.byKey(const Key('customer_checkout_button')));
    await tester.pumpAndSettle();

    // Verify checkout was executed with new address and cart was cleared
    expect(orderRepo.capturedAddress, 'Jl. Baru No. 99, Jakarta Pusat');
    expect(cartController.isEmpty, isTrue);
    expect(cartController.totalQuantity, 0);
    expect(find.text('Pesanan berhasil dibuat!'), findsOneWidget);
    expect(viewOrdersClicked, isTrue);
  });

  testWidgets('displays error message when checkout fails', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    orderRepo.resultToReturn = Result<CustomerOrder>.failure(
      const ServerFailure(
        statusCode: 400,
        message: 'Menu Soju Peach sedang habis stok',
      ),
    );

    await cartController.addProduct(
      const CatalogProduct(
        id: 1,
        code: 'MN-1',
        name: 'Soju Peach',
        variants: <String>[],
        unit: 'Botol',
        price: 45000,
      ),
      quantity: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCheckoutScreen(
          cartController: cartController,
          checkoutController: checkoutController,
          user: testUser,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('customer_checkout_button')));
    await tester.tap(find.byKey(const Key('customer_checkout_button')));
    await tester.pumpAndSettle();

    expect(find.text('Menu Soju Peach sedang habis stok'), findsOneWidget);
    // Cart should not be emptied on error
    expect(cartController.isEmpty, isFalse);
  });
}
