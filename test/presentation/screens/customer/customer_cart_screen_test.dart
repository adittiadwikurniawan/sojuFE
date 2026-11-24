// test/presentation/screens/customer/customer_cart_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/domain/repositories/storefront_repository.dart';
import 'package:soju_fe/domain/usecases/storefront_usecases.dart';
import 'package:soju_fe/presentation/providers/storefront/customer_cart_controller.dart';
import 'package:soju_fe/presentation/screens/customer/customer_cart_screen.dart';

class _MockStorefrontRepository implements StorefrontRepository {
  Result<List<CartItem>> getCartResult =
      Result<List<CartItem>>.success(<CartItem>[]);
  Result<int> saveCartResult = Result<int>.success(0);
  int saveCartCallCount = 0;

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search}) async =>
      Result<List<CatalogProduct>>.success(<CatalogProduct>[]);

  @override
  Future<Result<List<CartItem>>> fetchCart() async => getCartResult;

  @override
  Future<Result<int>> saveCart(List<CartItem> items) async {
    saveCartCallCount++;
    return saveCartResult;
  }
}

void main() {
  late _MockStorefrontRepository repository;
  late CustomerCartController controller;

  setUp(() {
    repository = _MockStorefrontRepository();
    controller = CustomerCartController(
      getCart: GetCart(repository),
      saveCart: SaveCart(repository),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('renders empty cart view with action buttons', (WidgetTester tester) async {
    bool browseMenuClicked = false;
    bool checkoutClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCartScreen(
          controller: controller,
          onBrowseMenu: () => browseMenuClicked = true,
          onCheckout: () => checkoutClicked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer_cart_empty')), findsOneWidget);
    expect(find.text('Keranjang masih kosong'), findsOneWidget);
    expect(find.text('Yuk pilih menu favoritmu terlebih dahulu.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('customer_cart_browse_menu')));
    expect(browseMenuClicked, isTrue);

    await tester.tap(find.byKey(const Key('customer_checkout_button')));
    expect(checkoutClicked, isTrue);
  });

  testWidgets('renders error view with retry button on failure', (WidgetTester tester) async {
    repository.getCartResult = Result<List<CartItem>>.failure(
      const ServerFailure(message: 'Server sedang sibuk'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCartScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keranjang gagal dimuat'), findsOneWidget);
    expect(find.text('Server sedang sibuk'), findsOneWidget);
    expect(find.byKey(const Key('customer_cart_retry')), findsOneWidget);

    repository.getCartResult = Result<List<CartItem>>.success(<CartItem>[]);
    await tester.tap(find.byKey(const Key('customer_cart_retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer_cart_empty')), findsOneWidget);
  });

  testWidgets('renders cart items, updates quantity, removes item, and triggers checkout',
      (WidgetTester tester) async {
    bool checkoutCalled = false;
    const List<CartItem> sampleItems = <CartItem>[
      CartItem(
        productId: 1,
        name: 'Soju Peach',
        variant: 'Dingin',
        quantity: 2,
        note: 'Kurangi es',
        price: 45000,
      ),
      CartItem(
        productId: 2,
        name: 'Tteokbokki Mozzarella',
        variant: 'Pedas',
        quantity: 1,
        price: 35000,
      ),
    ];
    repository.getCartResult = Result<List<CartItem>>.success(sampleItems);
    repository.saveCartResult = Result<int>.success(3);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCartScreen(
          controller: controller,
          onCheckout: () => checkoutCalled = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and items
    expect(find.text('Keranjang Belanja'), findsOneWidget);
    expect(find.text('Soju Peach'), findsOneWidget);
    expect(find.text('Varian: Dingin'), findsOneWidget);
    expect(find.text('Catatan: Kurangi es'), findsOneWidget);
    expect(find.text('Tteokbokki Mozzarella'), findsOneWidget);

    // Verify subtotal and total
    expect(find.text('Rp 90.000'), findsOneWidget);
    expect(find.text('Rp 35.000'), findsOneWidget);
    expect(find.text('Total (3 item)'), findsOneWidget);
    expect(find.text('Rp 125.000'), findsOneWidget);

    // Increment quantity of first item
    await tester.tap(find.byKey(const Key('customer_cart_increment_0')));
    await tester.pumpAndSettle();
    expect(repository.saveCartCallCount, 1);
    expect(controller.items[0].quantity, 3);

    // Remove second item
    await tester.tap(find.byKey(const Key('customer_cart_remove_1')));
    await tester.pumpAndSettle();
    expect(repository.saveCartCallCount, 2);
    expect(controller.items.length, 1);

    // Checkout button
    await tester.tap(find.byKey(const Key('customer_checkout_button')));
    expect(checkoutCalled, isTrue);
  });
}
