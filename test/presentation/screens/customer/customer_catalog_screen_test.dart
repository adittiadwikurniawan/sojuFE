// test/presentation/screens/customer/customer_catalog_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/domain/repositories/storefront_repository.dart';
import 'package:soju_fe/domain/usecases/storefront_usecases.dart';
import 'package:soju_fe/presentation/providers/storefront/customer_cart_controller.dart';
import 'package:soju_fe/presentation/providers/storefront/customer_catalog_controller.dart';
import 'package:soju_fe/presentation/screens/customer/customer_catalog_screen.dart';

class _FakeStorefrontRepo implements StorefrontRepository {
  Result<List<CatalogProduct>> catalogResult =
      Result<List<CatalogProduct>>.success(<CatalogProduct>[]);
  Result<List<CartItem>> cartResult =
      Result<List<CartItem>>.success(<CartItem>[]);
  Result<int> saveCartResult = Result<int>.success(1);

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search}) async =>
      catalogResult;

  @override
  Future<Result<List<CartItem>>> fetchCart() async => cartResult;

  @override
  Future<Result<int>> saveCart(List<CartItem> items) async => saveCartResult;
}

void main() {
  late _FakeStorefrontRepo repository;
  late CustomerCatalogController catalogController;
  late CustomerCartController cartController;

  setUp(() {
    repository = _FakeStorefrontRepo();
    catalogController = CustomerCatalogController(
      getProducts: GetCatalogProducts(repository),
    );
    cartController = CustomerCartController(
      getCart: GetCart(repository),
      saveCart: SaveCart(repository),
    );
  });

  tearDown(() {
    catalogController.dispose();
    cartController.dispose();
  });

  const CatalogProduct sample = CatalogProduct(
    id: 1,
    code: 'MN-001',
    name: 'Soju Sparkling Peach',
    variants: <String>['Dingin'],
    unit: 'Botol',
    price: 45000,
  );

  testWidgets('renders catalog list and opens product detail sheet',
      (WidgetTester tester) async {
    repository.catalogResult =
        Result<List<CatalogProduct>>.success(<CatalogProduct>[sample]);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCatalogScreen(
          catalogController: catalogController,
          cartController: cartController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menu SOJU'), findsOneWidget);
    expect(find.text('Soju Sparkling Peach'), findsOneWidget);
    expect(find.text('Rp 45.000'), findsOneWidget);

    // Tap product card to open bottom sheet
    await tester.tap(find.byKey(const Key('customer_product_1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product_detail_sheet')), findsOneWidget);
    expect(find.byKey(const Key('product_add_to_cart')), findsOneWidget);

    // Add to cart
    await tester.tap(find.byKey(const Key('product_add_to_cart')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product_detail_sheet')), findsNothing);
    expect(find.text('Soju Sparkling Peach ditambahkan ke keranjang.'), findsOneWidget);
    expect(cartController.items.length, 1);
  });

  testWidgets('renders error view with retry button on error',
      (WidgetTester tester) async {
    repository.catalogResult = Result<List<CatalogProduct>>.failure(
      const ServerFailure(message: 'Gagal memuat katalog'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerCatalogScreen(
          catalogController: catalogController,
          cartController: cartController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menu gagal dimuat'), findsOneWidget);
    expect(find.text('Gagal memuat katalog'), findsOneWidget);
    expect(find.byKey(const Key('customer_catalog_retry')), findsOneWidget);

    // Click retry
    repository.catalogResult =
        Result<List<CatalogProduct>>.success(<CatalogProduct>[sample]);
    await tester.tap(find.byKey(const Key('customer_catalog_retry')));
    await tester.pumpAndSettle();

    expect(find.text('Soju Sparkling Peach'), findsOneWidget);
  });
}
