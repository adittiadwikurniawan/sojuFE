// lib/presentation/providers/storefront/customer_catalog_controller.dart
//
// ChangeNotifier katalog menu Pelanggan (loading / empty / error / loaded).

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/storefront_entity.dart';
import '../../../domain/usecases/storefront_usecases.dart';

enum CatalogStatus { initial, loading, loaded, empty, error }

/// Controller katalog produk publik.
class CustomerCatalogController extends ChangeNotifier {
  CustomerCatalogController({required GetCatalogProducts getProducts})
      : _getProducts = getProducts;

  final GetCatalogProducts _getProducts;

  CatalogStatus _status = CatalogStatus.initial;
  List<CatalogProduct> _products = const <CatalogProduct>[];
  String? _errorMessage;
  String _search = '';
  int _requestId = 0;

  CatalogStatus get status => _status;
  List<CatalogProduct> get products => _products;
  String? get errorMessage => _errorMessage;
  String get search => _search;

  /// Memuat ulang katalog (dipakai juga tombol "Coba Lagi").
  Future<void> load({String? search}) async {
    if (search != null) _search = search.trim();
    final int requestId = ++_requestId;
    _status = CatalogStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final Result<List<CatalogProduct>> result =
        await _getProducts(search: _search.isEmpty ? null : _search);
    if (requestId != _requestId) return;

    result.fold(
      onFailure: (AppFailure failure) {
        _status = CatalogStatus.error;
        _errorMessage = failure.message;
      },
      onSuccess: (List<CatalogProduct> products) {
        _products = products;
        _status =
            products.isEmpty ? CatalogStatus.empty : CatalogStatus.loaded;
      },
    );
    notifyListeners();
  }
}
