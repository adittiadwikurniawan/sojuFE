import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/storefront_entity.dart';
import '../../../domain/usecases/featured_products_usecase.dart';

enum FeaturedProductsStatus { initial, loading, loaded, empty, error }

/// Controller state Produk Unggulan pada beranda Pelanggan.
class FeaturedProductsController extends ChangeNotifier {
  FeaturedProductsController({required GetFeaturedProducts getProducts})
      : _getProducts = getProducts;

  final GetFeaturedProducts _getProducts;

  FeaturedProductsStatus _status = FeaturedProductsStatus.initial;
  List<CatalogProduct> _products = const <CatalogProduct>[];
  String? _errorMessage;
  int _requestId = 0;

  FeaturedProductsStatus get status => _status;
  List<CatalogProduct> get products => _products;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    final int requestId = ++_requestId;
    _status = FeaturedProductsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final Result<List<CatalogProduct>> result = await _getProducts();
    if (requestId != _requestId) return;

    result.fold(
      onFailure: (AppFailure failure) {
        _status = FeaturedProductsStatus.error;
        _errorMessage = failure.message;
      },
      onSuccess: (List<CatalogProduct> products) {
        _products = products;
        _status = products.isEmpty
            ? FeaturedProductsStatus.empty
            : FeaturedProductsStatus.loaded;
      },
    );
    notifyListeners();
  }
}
