// test/presentation/providers/storefront/customer_cart_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/domain/repositories/storefront_repository.dart';
import 'package:soju_fe/domain/usecases/storefront_usecases.dart';
import 'package:soju_fe/presentation/providers/storefront/customer_cart_controller.dart';

class _FakeStorefrontRepository implements StorefrontRepository {
  Result<List<CartItem>> getCartResult =
      Result<List<CartItem>>.success(<CartItem>[]);
  Result<int> saveCartResult = Result<int>.success(0);
  List<CartItem>? lastSavedItems;

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search}) async =>
      Result<List<CatalogProduct>>.success(<CatalogProduct>[]);

  @override
  Future<Result<List<CartItem>>> fetchCart() async => getCartResult;

  @override
  Future<Result<int>> saveCart(List<CartItem> items) async {
    lastSavedItems = List<CartItem>.of(items);
    return saveCartResult;
  }
}

void main() {
  late _FakeStorefrontRepository repository;
  late CustomerCartController controller;

  setUp(() {
    repository = _FakeStorefrontRepository();
    controller = CustomerCartController(
      getCart: GetCart(repository),
      saveCart: SaveCart(repository),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  const CatalogProduct sampleProduct = CatalogProduct(
    id: 1,
    code: 'MN-001',
    name: 'Soju Peach',
    variants: <String>['Dingin', 'Normal'],
    unit: 'Botol',
    price: 45000,
  );

  test('initial state is initial and empty', () {
    expect(controller.status, CartStatus.initial);
    expect(controller.items, isEmpty);
    expect(controller.isEmpty, isTrue);
    expect(controller.totalQuantity, 0);
    expect(controller.totalPrice, 0);
  });

  test('load() populates items and sets status to ready', () async {
    const List<CartItem> initial = <CartItem>[
      CartItem(
        productId: 1,
        name: 'Soju Peach',
        variant: 'Dingin',
        quantity: 2,
        price: 45000,
      ),
    ];
    repository.getCartResult = Result<List<CartItem>>.success(initial);

    final Future<void> future = controller.load();
    expect(controller.status, CartStatus.loading);
    await future;

    expect(controller.status, CartStatus.ready);
    expect(controller.items.length, 1);
    expect(controller.totalQuantity, 2);
    expect(controller.totalPrice, 90000);
  });

  test('addProduct() adds new item and syncs with repository', () async {
    repository.saveCartResult = Result<int>.success(2);

    final bool success = await controller.addProduct(
      sampleProduct,
      variant: 'Dingin',
      quantity: 2,
      note: 'Less ice',
    );

    expect(success, isTrue);
    expect(controller.items.length, 1);
    expect(controller.items.first.productId, 1);
    expect(controller.items.first.variant, 'Dingin');
    expect(controller.items.first.quantity, 2);
    expect(controller.items.first.note, 'Less ice');
    expect(repository.lastSavedItems?.length, 1);
  });

  test('addProduct() merges quantity for same product and variant', () async {
    repository.saveCartResult = Result<int>.success(5);

    await controller.addProduct(
      sampleProduct,
      variant: 'Dingin',
      quantity: 2,
      note: 'Awal',
    );
    await controller.addProduct(
      sampleProduct,
      variant: 'Dingin',
      quantity: 3,
      note: 'Tambahan',
    );

    expect(controller.items.length, 1);
    expect(controller.items.first.quantity, 5);
    expect(controller.items.first.note, 'Tambahan');
  });

  test('addProduct() rolls back and sets syncError when saveCart fails', () async {
    repository.saveCartResult = Result<int>.failure(
      const ServerFailure(message: 'Gagal menyimpan keranjang di server'),
    );

    final bool success = await controller.addProduct(
      sampleProduct,
      variant: 'Dingin',
      quantity: 1,
    );

    expect(success, isFalse);
    expect(controller.items, isEmpty);
    expect(controller.syncError, 'Gagal menyimpan keranjang di server');
  });

  test('updateQuantity() updates quantity and removes item when qty < 1', () async {
    repository.saveCartResult = Result<int>.success(1);
    await controller.addProduct(sampleProduct, quantity: 2);

    await controller.updateQuantity(0, 5);
    expect(controller.items.first.quantity, 5);

    await controller.updateQuantity(0, 0);
    expect(controller.items, isEmpty);
  });

  test('removeAt() removes item at specified index', () async {
    repository.saveCartResult = Result<int>.success(1);
    await controller.addProduct(sampleProduct, variant: 'V1');
    await controller.addProduct(sampleProduct, variant: 'V2');
    expect(controller.items.length, 2);

    await controller.removeAt(0);
    expect(controller.items.length, 1);
    expect(controller.items.first.variant, 'V2');
  });

  test('load() detects HTTP 400 stale-cart failure and sets isStaleCartError flag', () async {
    repository.getCartResult = Result<List<CartItem>>.failure(
      const ServerFailure(statusCode: 400, message: 'Produk tidak tersedia'),
    );

    await controller.load();

    expect(controller.status, CartStatus.error);
    expect(controller.errorMessage, 'Produk tidak tersedia');
    expect(controller.isStaleCartError, isTrue);
    expect(controller.canClearStaleCart, isTrue);

    // Other non-400 failure should not set isStaleCartError
    repository.getCartResult = Result<List<CartItem>>.failure(
      const ServerFailure(statusCode: 500, message: 'Internal Server Error'),
    );
    await controller.load();
    expect(controller.isStaleCartError, isFalse);
  });

  test('clearCart() sends empty list to saveCart and recovers to empty ready state', () async {
    repository.getCartResult = Result<List<CartItem>>.failure(
      const ServerFailure(statusCode: 400, message: 'Produk tidak tersedia'),
    );
    await controller.load();
    expect(controller.isStaleCartError, isTrue);

    repository.saveCartResult = Result<int>.success(0);
    final bool success = await controller.clearCart();

    expect(success, isTrue);
    expect(repository.lastSavedItems, isEmpty);
    expect(controller.status, CartStatus.ready);
    expect(controller.items, isEmpty);
    expect(controller.isEmpty, isTrue);
    expect(controller.isStaleCartError, isFalse);
    expect(controller.errorMessage, isNull);
  });

  test('reset() clears in-memory items, errors, and stale flags back to initial', () async {
    repository.saveCartResult = Result<int>.success(1);
    await controller.addProduct(sampleProduct);
    expect(controller.items.length, 1);
    expect(controller.totalQuantity, 1);

    controller.reset();

    expect(controller.status, CartStatus.initial);
    expect(controller.items, isEmpty);
    expect(controller.isEmpty, isTrue);
    expect(controller.totalQuantity, 0);
    expect(controller.isStaleCartError, isFalse);
    expect(controller.errorMessage, isNull);
    expect(controller.syncError, isNull);
  });
}
