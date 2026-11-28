// lib/data/models/storefront/storefront_models.dart
//
// DTO katalog publik dan item keranjang beserta resolusi URL gambar:
// 1. `gambarUrl` (S3/absolut) diprioritaskan.
// 2. `gambar` berupa URL absolut atau path relatif origin API.
// 3. Fallback BLOB `GET /api/public/products/:id/image`.

import '../../../domain/entities/storefront_entity.dart';

/// Menyelesaikan URL gambar produk terhadap [origin] API.
String? resolveProductImageUrl({
  required int id,
  required String origin,
  String? gambarUrl,
  String? gambar,
}) {
  final String base = origin.endsWith('/')
      ? origin.substring(0, origin.length - 1)
      : origin;
  for (final String? candidate in <String?>[gambarUrl, gambar]) {
    final String value = candidate?.trim() ?? '';
    if (value.isEmpty) continue;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/') && base.isNotEmpty) {
      return '$base$value';
    }
  }
  // Jika backend tidak menyertakan gambarUrl maupun gambar, berarti produk
  // belum memiliki foto. Kembalikan null agar UI menampilkan placeholder tanpa
  // memicu request HTTP 404 di console browser.
  return null;
}

int _int(Object? v) {
  if (v is num) return v.round();
  if (v is String) return (double.tryParse(v.trim()) ?? 0).round();
  return 0;
}

String _str(Object? v) => v is String ? v.trim() : (v?.toString() ?? '');

String? _optStr(Object? v) {
  final String s = v is String ? v.trim() : '';
  return s.isEmpty ? null : s;
}

/// Memecah string varian `"Panas, Dingin"` menjadi daftar.
List<String> parseVariants(Object? raw) {
  if (raw is! String) return const <String>[];
  return raw
      .split(',')
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList(growable: false);
}

/// DTO produk `/api/public/products`.
class CatalogProductModel {
  const CatalogProductModel(this.entity);

  final CatalogProduct entity;

  factory CatalogProductModel.fromJson(
    Map<String, Object?> json, {
    String origin = '',
  }) {
    final Object? rawId = json['id'];
    if (rawId is! num) {
      throw const FormatException('Field `id` produk tidak valid.');
    }
    final int id = rawId.toInt();
    return CatalogProductModel(
      CatalogProduct(
        id: id,
        code: _str(json['kode']),
        name: _str(json['namaBarang']),
        variants: parseVariants(json['varian']),
        unit: _str(json['satuan']),
        price: _int(json['hargaDefault']),
        description: _optStr(json['deskripsi']),
        imageUrl: resolveProductImageUrl(
          id: id,
          origin: origin,
          gambarUrl: _optStr(json['gambarUrl']),
          gambar: _optStr(json['gambar']),
        ),
      ),
    );
  }
}

/// DTO item `GET /api/customer/keranjang`.
class CartItemModel {
  const CartItemModel(this.entity);

  final CartItem entity;

  factory CartItemModel.fromJson(
    Map<String, Object?> json, {
    String origin = '',
  }) {
    final int productId = _int(json['productId']);
    if (productId <= 0) {
      throw const FormatException('Field `productId` keranjang tidak valid.');
    }
    return CartItemModel(
      CartItem(
        productId: productId,
        name: _str(json['nama']),
        variant: _str(json['varian']),
        quantity: _int(json['jumlah']),
        note: _str(json['catatan']),
        price: _int(json['harga']),
        unit: _str(json['satuan']),
        imageUrl: resolveProductImageUrl(
          id: productId,
          origin: origin,
          gambarUrl: _optStr(json['gambarUrl']),
          gambar: _optStr(json['gambar']),
        ),
      ),
    );
  }

  /// Payload `PUT /api/customer/keranjang` per item.
  static Map<String, Object?> toPayload(CartItem item) => <String, Object?>{
        'productId': item.productId,
        'varian': item.variant,
        'jumlah': item.quantity,
        'catatan': item.note,
      };
}
