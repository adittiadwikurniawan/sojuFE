// test/data/repositories/storefront_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/data/datasources/interfaces/storefront_datasource.dart';
import 'package:soju_fe/data/repositories/storefront_repository_impl.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';

class _FakeStorefrontDataSource implements StorefrontDataSource {
  Map<String, Object?>? catalogResponse;
  Map<String, Object?>? cartResponse;
  Map<String, Object?>? saveCartResponse;
  AppFailure? errorToThrow;
  List<Map<String, Object?>>? capturedSavedItems;

  @override
  Future<Map<String, Object?>> fetchRawCatalog({String? search}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return catalogResponse ??
        <String, Object?>{
          'success': true,
          'data': <Map<String, Object?>>[],
        };
  }

  @override
  Future<Map<String, Object?>> fetchRawCart() async {
    if (errorToThrow != null) throw errorToThrow!;
    return cartResponse ??
        <String, Object?>{
          'success': true,
          'data': <Map<String, Object?>>[],
        };
  }

  @override
  Future<Map<String, Object?>> saveRawCart(List<Map<String, Object?>> items) async {
    capturedSavedItems = items;
    if (errorToThrow != null) throw errorToThrow!;
    return saveCartResponse ??
        <String, Object?>{
          'success': true,
          'data': <String, Object?>{'jumlahItem': items.length},
        };
  }
}

void main() {
  late _FakeStorefrontDataSource dataSource;
  late StorefrontRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeStorefrontDataSource();
    repository = StorefrontRepositoryImpl(
      dataSource,
      apiOrigin: 'http://localhost:4000',
    );
  });

  group('fetchCatalog', () {
    test('returns products list on valid response', () async {
      dataSource.catalogResponse = <String, Object?>{
        'success': true,
        'data': <Map<String, Object?>>[
          <String, Object?>{
            'id': 1,
            'kode': 'MN-001',
            'namaBarang': 'Soju Peach',
            'varian': 'Dingin',
            'satuan': 'Botol',
            'hargaDefault': 45000,
            'gambarUrl': 'https://s3.example.com/p.png',
            'aktif': true,
          },
        ],
      };

      final Result<List<CatalogProduct>> result =
          await repository.fetchCatalog();
      expect(result.isSuccess, isTrue);
      final List<CatalogProduct> products = result.valueOrNull!;
      expect(products.length, 1);
      expect(products.first.id, 1);
      expect(products.first.name, 'Soju Peach');
    });

    test('returns EnvelopeFailure when success is false', () async {
      dataSource.catalogResponse = <String, Object?>{
        'success': false,
        'message': 'Gagal mengambil data',
      };

      final Result<List<CatalogProduct>> result =
          await repository.fetchCatalog();
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<EnvelopeFailure>());
      expect(result.failureOrNull?.message, 'Gagal mengambil data');
    });

    test('propagates AppFailure from datasource', () async {
      dataSource.errorToThrow = const NetworkFailure();

      final Result<List<CatalogProduct>> result =
          await repository.fetchCatalog();
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('fetchCart', () {
    test('returns cart items on success', () async {
      dataSource.cartResponse = <String, Object?>{
        'success': true,
        'data': <Map<String, Object?>>[
          <String, Object?>{
            'productId': 2,
            'nama': 'Tteokbokki',
            'varian': 'Pedas',
            'jumlah': 3,
            'catatan': 'Pedas banget',
            'harga': 30000,
            'satuan': 'Porsi',
          },
        ],
      };

      final Result<List<CartItem>> result = await repository.fetchCart();
      expect(result.isSuccess, isTrue);
      final List<CartItem> items = result.valueOrNull!;
      expect(items.length, 1);
      expect(items.first.productId, 2);
      expect(items.first.quantity, 3);
      expect(items.first.subtotal, 90000);
    });
  });

  group('saveCart', () {
    test('sends formatted payload and returns total quantity', () async {
      dataSource.saveCartResponse = <String, Object?>{
        'success': true,
        'data': <String, Object?>{'jumlahItem': 5},
      };

      final Result<int> result = await repository.saveCart(<CartItem>[
        const CartItem(
          productId: 1,
          name: 'Item 1',
          quantity: 2,
          variant: 'V1',
          note: 'N1',
        ),
        const CartItem(
          productId: 2,
          name: 'Item 2',
          quantity: 3,
          variant: 'V2',
          note: 'N2',
        ),
      ]);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 5);
      expect(dataSource.capturedSavedItems?.length, 2);
      expect(dataSource.capturedSavedItems?.first['productId'], 1);
      expect(dataSource.capturedSavedItems?.first['jumlah'], 2);
    });
  });
}
