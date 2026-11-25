// lib/domain/repositories/storefront_repository.dart
//
// Kontrak repository etalase Pelanggan (katalog publik + keranjang).

import '../../core/common/result.dart';
import '../entities/storefront_entity.dart';

/// Repository katalog publik dan keranjang Pelanggan.
abstract interface class StorefrontRepository {
  /// `GET /api/public/products` (opsional [search]).
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search});

  /// `GET /api/customer/keranjang`.
  Future<Result<List<CartItem>>> fetchCart();

  /// `PUT /api/customer/keranjang`; mengembalikan total jumlah item.
  Future<Result<int>> saveCart(List<CartItem> items);
}
