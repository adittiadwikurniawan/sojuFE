// lib/data/datasources/mock/storefront_mock_datasource.dart
//
// Sumber data mock etalase Pelanggan (Phase A / offline / test).
// Meniru format envelope `{success, data, message?}` persis seperti endpoint backend:
// - `GET /api/public/products`
// - `GET /api/customer/keranjang`
// - `PUT /api/customer/keranjang`

import '../interfaces/featured_products_datasource.dart';

/// Datasource mock katalog dan keranjang.
class StorefrontMockDataSource implements FeaturedProductsDataSource {
  StorefrontMockDataSource({
    List<Map<String, Object?>>? initialProducts,
    List<Map<String, Object?>>? initialCartItems,
  })  : _products = initialProducts ?? _defaultProducts,
        _cartItems = initialCartItems != null
            ? List<Map<String, Object?>>.of(initialCartItems)
            : <Map<String, Object?>>[];

  static final List<Map<String, Object?>> _defaultProducts = <Map<String, Object?>>[
    <String, Object?>{
      'id': 1,
      'kode': 'MN-001',
      'namaBarang': 'Soju Sparkling Peach',
      'varian': 'Dingin, Normal',
      'satuan': 'Botol',
      'hargaDefault': 45000,
      'gambar': null,
      'gambarUrl': 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500',
      'deskripsi': 'Minuman sparkling segar beraroma buah persik pilihan.',
      'aktif': true,
    },
    <String, Object?>{
      'id': 2,
      'kode': 'MN-002',
      'namaBarang': 'Tteokbokki Spicy Mozzarella',
      'varian': 'Pedas Sedang, Ekstra Pedas',
      'satuan': 'Porsi',
      'hargaDefault': 35000,
      'gambar': null,
      'gambarUrl': 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500',
      'deskripsi': 'Kue beras kenyal dengan saus gochujang autentik dan lelehan keju.',
      'aktif': true,
    },
    <String, Object?>{
      'id': 3,
      'kode': 'MN-003',
      'namaBarang': 'Korean Fried Chicken Garlic',
      'varian': 'Original, Pedas Manis',
      'satuan': 'Porsi',
      'hargaDefault': 40000,
      'gambar': '/uploads/kfc-garlic.jpg',
      'gambarUrl': null,
      'deskripsi': 'Ayam krispi renyah dibalut saus bawang putih gurih manis.',
      'aktif': true,
    },
    <String, Object?>{
      'id': 4,
      'kode': 'MN-004',
      'namaBarang': 'Kimchi Fried Rice',
      'varian': null,
      'satuan': 'Porsi',
      'hargaDefault': 28000,
      'gambar': null,
      'gambarUrl': null,
      'deskripsi': 'Nasi goreng kimchi pedas segar disajikan dengan telur mata sapi.',
      'aktif': true,
    },
  ];

  final List<Map<String, Object?>> _products;
  final List<Map<String, Object?>> _cartItems;

  @override
  Future<Map<String, Object?>> fetchRawFeaturedContent() async {
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{'key': 'produk_unggulan', 'konten': '[1,2]', 'aktif': true},
    };
  }

  @override
  Future<Map<String, Object?>> fetchRawCatalog({String? search}) async {
    final String query = search?.trim().toLowerCase() ?? '';
    final List<Map<String, Object?>> filtered = _products.where((Map<String, Object?> item) {
      if (item['aktif'] != true) return false;
      if (query.isEmpty) return true;
      final String nama = (item['namaBarang'] as String? ?? '').toLowerCase();
      final String varian = (item['varian'] as String? ?? '').toLowerCase();
      final String kode = (item['kode'] as String? ?? '').toLowerCase();
      return nama.contains(query) || varian.contains(query) || kode.contains(query);
    }).toList();

    return <String, Object?>{
      'success': true,
      'data': filtered,
      'message': 'Katalog produk berhasil dimuat',
    };
  }

  @override
  Future<Map<String, Object?>> fetchRawCart() async {
    return <String, Object?>{
      'success': true,
      'data': List<Map<String, Object?>>.of(_cartItems),
      'message': 'Keranjang berhasil dimuat',
    };
  }

  @override
  Future<Map<String, Object?>> saveRawCart(List<Map<String, Object?>> items) async {
    _cartItems.clear();
    for (final Map<String, Object?> raw in items) {
      final int productId = raw['productId'] is num ? (raw['productId'] as num).toInt() : 0;
      final Map<String, Object?>? product = _products.cast<Map<String, Object?>?>().firstWhere(
            (Map<String, Object?>? p) => p?['id'] == productId,
            orElse: () => null,
          );
      _cartItems.add(<String, Object?>{
        'productId': productId,
        'nama': product?['namaBarang'] ?? 'Menu #$productId',
        'varian': raw['varian'] ?? '',
        'jumlah': raw['jumlah'] ?? 1,
        'catatan': raw['catatan'] ?? '',
        'harga': product?['hargaDefault'] ?? 0,
        'satuan': product?['satuan'] ?? '',
        'gambar': product?['gambar'],
        'gambarUrl': product?['gambarUrl'],
      });
    }

    final int totalQty = _cartItems.fold(
      0,
      (int sum, Map<String, Object?> i) => sum + (i['jumlah'] as num? ?? 0).toInt(),
    );

    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'jumlahItem': totalQty,
      },
      'message': 'Keranjang berhasil diperbarui',
    };
  }
}
