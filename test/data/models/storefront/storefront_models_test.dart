// test/data/models/storefront/storefront_models_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/data/models/storefront/storefront_models.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';

void main() {
  group('resolveProductImageUrl', () {
    const String origin = 'http://localhost:4000';

    test('prioritizes S3 gambarUrl over local gambar and fallback', () {
      final String? url = resolveProductImageUrl(
        id: 10,
        origin: origin,
        gambarUrl: 'https://my-bucket.s3.amazonaws.com/products/item.png',
        gambar: '/uploads/local.png',
      );
      expect(url, 'https://my-bucket.s3.amazonaws.com/products/item.png');
    });

    test('uses absolute gambar url when gambarUrl is absent', () {
      final String? url = resolveProductImageUrl(
        id: 11,
        origin: origin,
        gambarUrl: null,
        gambar: 'https://cdn.example.com/food.jpg',
      );
      expect(url, 'https://cdn.example.com/food.jpg');
    });

    test('resolves relative gambar path against origin', () {
      final String? url = resolveProductImageUrl(
        id: 12,
        origin: origin,
        gambarUrl: null,
        gambar: '/uploads/tteokbokki.jpg',
      );
      expect(url, 'http://localhost:4000/uploads/tteokbokki.jpg');
    });

    test('falls back to BLOB endpoint /api/public/products/:id/image', () {
      final String? url = resolveProductImageUrl(
        id: 15,
        origin: origin,
        gambarUrl: null,
        gambar: null,
      );
      expect(url, 'http://localhost:4000/api/public/products/15/image');
    });

    test('returns null when id <= 0 and no image specified', () {
      final String? url = resolveProductImageUrl(
        id: 0,
        origin: origin,
        gambarUrl: null,
        gambar: null,
      );
      expect(url, isNull);
    });
  });

  group('parseVariants', () {
    test('splits comma separated string and trims items', () {
      final List<String> variants = parseVariants('Dingin, Panas , Normal ');
      expect(variants, <String>['Dingin', 'Panas', 'Normal']);
    });

    test('returns empty list for null, empty, or non-string input', () {
      expect(parseVariants(null), isEmpty);
      expect(parseVariants(''), isEmpty);
      expect(parseVariants(123), isEmpty);
    });
  });

  group('CatalogProductModel', () {
    test('parses full JSON into CatalogProduct entity', () {
      final Map<String, Object?> json = <String, Object?>{
        'id': 1,
        'kode': 'MN-001',
        'namaBarang': 'Soju Peach',
        'varian': 'Dingin, Normal',
        'satuan': 'Botol',
        'hargaDefault': 45000,
        'gambarUrl': 'https://images.example.com/peach.png',
        'gambar': null,
        'deskripsi': 'Segar beraroma buah persik',
        'aktif': true,
      };

      final CatalogProductModel model =
          CatalogProductModel.fromJson(json, origin: 'http://localhost:4000');
      final CatalogProduct entity = model.entity;

      expect(entity.id, 1);
      expect(entity.code, 'MN-001');
      expect(entity.name, 'Soju Peach');
      expect(entity.variants, <String>['Dingin', 'Normal']);
      expect(entity.hasVariants, isTrue);
      expect(entity.unit, 'Botol');
      expect(entity.price, 45000);
      expect(entity.imageUrl, 'https://images.example.com/peach.png');
      expect(entity.description, 'Segar beraroma buah persik');
    });

    test('throws FormatException when id is missing or not a number', () {
      expect(
        () => CatalogProductModel.fromJson(<String, Object?>{'id': 'invalid'}),
        throwsFormatException,
      );
    });
  });

  group('CartItemModel', () {
    test('parses JSON into CartItem entity', () {
      final Map<String, Object?> json = <String, Object?>{
        'productId': 2,
        'nama': 'Tteokbokki Mozzarella',
        'varian': 'Pedas Sedang',
        'jumlah': 2,
        'catatan': 'Kurangi garam',
        'harga': 35000,
        'satuan': 'Porsi',
        'gambarUrl': 'https://images.example.com/tteok.png',
      };

      final CartItemModel model =
          CartItemModel.fromJson(json, origin: 'http://localhost:4000');
      final CartItem item = model.entity;

      expect(item.productId, 2);
      expect(item.name, 'Tteokbokki Mozzarella');
      expect(item.variant, 'Pedas Sedang');
      expect(item.quantity, 2);
      expect(item.note, 'Kurangi garam');
      expect(item.price, 35000);
      expect(item.subtotal, 70000);
      expect(item.unit, 'Porsi');
      expect(item.imageUrl, 'https://images.example.com/tteok.png');
    });

    test('converts CartItem to PUT payload', () {
      const CartItem item = CartItem(
        productId: 3,
        name: 'Korean Fried Chicken',
        variant: 'Garlic',
        quantity: 4,
        note: 'Jangan terlalu pedas',
        price: 40000,
      );

      final Map<String, Object?> payload = CartItemModel.toPayload(item);
      expect(payload, <String, Object?>{
        'productId': 3,
        'varian': 'Garlic',
        'jumlah': 4,
        'catatan': 'Jangan terlalu pedas',
      });
    });

    test('sameLine compares productId and case-insensitive variant', () {
      const CartItem item = CartItem(
        productId: 5,
        name: 'Item 5',
        variant: 'Dingin',
        quantity: 1,
      );

      expect(item.sameLine(5, 'dingin'), isTrue);
      expect(item.sameLine(5, 'Dingin '), isTrue);
      expect(item.sameLine(5, 'Panas'), isFalse);
      expect(item.sameLine(6, 'Dingin'), isFalse);
    });
  });

  group('CartTotals', () {
    test('computes total quantity and total price correctly', () {
      const List<CartItem> items = <CartItem>[
        CartItem(productId: 1, name: 'A', quantity: 2, price: 10000),
        CartItem(productId: 2, name: 'B', quantity: 3, price: 20000),
      ];

      expect(items.totalQuantity, 5);
      expect(items.totalPrice, 20000 + 60000);
    });
  });
}
