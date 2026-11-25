// test/presentation/providers/storefront/customer_catalog_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/domain/repositories/storefront_repository.dart';
import 'package:soju_fe/domain/usecases/storefront_usecases.dart';
import 'package:soju_fe/presentation/providers/storefront/customer_catalog_controller.dart';

class _FakeStorefrontRepository implements StorefrontRepository {
  Result<List<CatalogProduct>> catalogResult =
      Result<List<CatalogProduct>>.success(<CatalogProduct>[]);
  String? capturedSearch;

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search}) async {
    capturedSearch = search;
    return catalogResult;
  }

  @override
  Future<Result<List<CartItem>>> fetchCart() async =>
      Result<List<CartItem>>.success(<CartItem>[]);

  @override
  Future<Result<int>> saveCart(List<CartItem> items) async =>
      Result<int>.success(items.length);
}

void main() {
  late _FakeStorefrontRepository repository;
  late CustomerCatalogController controller;

  setUp(() {
    repository = _FakeStorefrontRepository();
    controller = CustomerCatalogController(
      getProducts: GetCatalogProducts(repository),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('initial state is initial and products list is empty', () {
    expect(controller.status, CatalogStatus.initial);
    expect(controller.products, isEmpty);
    expect(controller.errorMessage, isNull);
  });

  test('load() transitions to loaded when products exist', () async {
    const CatalogProduct product = CatalogProduct(
      id: 1,
      code: 'MN-001',
      name: 'Soju Peach',
      variants: <String>['Dingin'],
      unit: 'Botol',
      price: 45000,
    );
    repository.catalogResult =
        Result<List<CatalogProduct>>.success(<CatalogProduct>[product]);

    final Future<void> future = controller.load(search: 'peach');
    expect(controller.status, CatalogStatus.loading);
    await future;

    expect(controller.status, CatalogStatus.loaded);
    expect(controller.products.length, 1);
    expect(controller.products.first.name, 'Soju Peach');
    expect(repository.capturedSearch, 'peach');
    expect(controller.errorMessage, isNull);
  });

  test('load() transitions to empty when products list is empty', () async {
    repository.catalogResult =
        Result<List<CatalogProduct>>.success(<CatalogProduct>[]);

    await controller.load();

    expect(controller.status, CatalogStatus.empty);
    expect(controller.products, isEmpty);
  });

  test('load() transitions to error on failure', () async {
    repository.catalogResult = Result<List<CatalogProduct>>.failure(
      const NetworkFailure(message: 'Koneksi terputus'),
    );

    await controller.load();

    expect(controller.status, CatalogStatus.error);
    expect(controller.errorMessage, 'Koneksi terputus');
    expect(controller.products, isEmpty);
  });
}
