// lib/domain/usecases/storefront_usecases.dart
//
// Usecase etalase Pelanggan.

import '../../core/common/result.dart';
import '../entities/storefront_entity.dart';
import '../repositories/storefront_repository.dart';

/// Memuat katalog produk publik.
class GetCatalogProducts {
  const GetCatalogProducts(this._repository);

  final StorefrontRepository _repository;

  Future<Result<List<CatalogProduct>>> call({String? search}) =>
      _repository.fetchCatalog(search: search);
}

/// Memuat keranjang tersimpan milik Pelanggan.
class GetCart {
  const GetCart(this._repository);

  final StorefrontRepository _repository;

  Future<Result<List<CartItem>>> call() => _repository.fetchCart();
}

/// Menyimpan seluruh isi keranjang Pelanggan.
class SaveCart {
  const SaveCart(this._repository);

  final StorefrontRepository _repository;

  Future<Result<int>> call(List<CartItem> items) =>
      _repository.saveCart(items);
}
