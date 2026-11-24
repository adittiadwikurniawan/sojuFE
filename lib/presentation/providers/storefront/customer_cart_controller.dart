// lib/presentation/providers/storefront/customer_cart_controller.dart
//
// ChangeNotifier keranjang Pelanggan yang disinkronkan dengan
// `GET/PUT /api/customer/keranjang`. Mutasi bersifat optimistis: daftar lokal
// diperbarui dulu, lalu dikembalikan bila PUT gagal.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/storefront_entity.dart';
import '../../../domain/usecases/storefront_usecases.dart';

enum CartStatus { initial, loading, ready, error }

/// Controller keranjang Pelanggan.
class CustomerCartController extends ChangeNotifier {
  CustomerCartController({required GetCart getCart, required SaveCart saveCart})
      : _getCart = getCart,
        _saveCart = saveCart;

  final GetCart _getCart;
  final SaveCart _saveCart;

  CartStatus _status = CartStatus.initial;
  List<CartItem> _items = const <CartItem>[];
  String? _errorMessage;
  String? _syncError;
  bool _isSyncing = false;

  CartStatus get status => _status;
  List<CartItem> get items => _items;
  bool get isEmpty => _items.isEmpty;
  bool get isSyncing => _isSyncing;

  /// Pesan galat saat memuat keranjang (state error penuh).
  String? get errorMessage => _errorMessage;

  /// Pesan galat sinkronisasi terakhir (ditampilkan sebagai banner).
  String? get syncError => _syncError;

  int get totalQuantity => _items.totalQuantity;
  int get totalPrice => _items.totalPrice;

  Future<void> load() async {
    _status = CartStatus.loading;
    _errorMessage = null;
    notifyListeners();
    final Result<List<CartItem>> result = await _getCart();
    result.fold(
      onFailure: (AppFailure f) {
        _status = CartStatus.error;
        _errorMessage = f.message;
      },
      onSuccess: (List<CartItem> items) {
        _items = List<CartItem>.unmodifiable(items);
        _status = CartStatus.ready;
      },
    );
    notifyListeners();
  }

  /// Menambahkan produk; baris dengan produk+varian sama digabung.
  Future<bool> addProduct(
    CatalogProduct product, {
    String variant = '',
    int quantity = 1,
    String note = '',
  }) {
    final String trimmedNote = _clipNote(note);
    final List<CartItem> next = List<CartItem>.of(_items);
    final int index =
        next.indexWhere((CartItem i) => i.sameLine(product.id, variant));
    if (index >= 0) {
      final CartItem existing = next[index];
      next[index] = existing.copyWith(
        quantity: _clampQty(existing.quantity + quantity),
        note: trimmedNote.isEmpty ? existing.note : trimmedNote,
      );
    } else {
      next.add(
        CartItem(
          productId: product.id,
          name: product.name,
          variant: variant.trim(),
          quantity: _clampQty(quantity),
          note: trimmedNote,
          price: product.price,
          unit: product.unit,
          imageUrl: product.imageUrl,
        ),
      );
    }
    return _commit(next);
  }

  Future<bool> updateQuantity(int index, int quantity) {
    if (index < 0 || index >= _items.length) return Future<bool>.value(false);
    if (quantity < kCartMinQuantity) return removeAt(index);
    final List<CartItem> next = List<CartItem>.of(_items);
    next[index] = next[index].copyWith(quantity: _clampQty(quantity));
    return _commit(next);
  }

  Future<bool> removeAt(int index) {
    if (index < 0 || index >= _items.length) return Future<bool>.value(false);
    final List<CartItem> next = List<CartItem>.of(_items)..removeAt(index);
    return _commit(next);
  }

  void clearSyncError() {
    if (_syncError == null) return;
    _syncError = null;
    notifyListeners();
  }

  Future<bool> _commit(List<CartItem> next) async {
    final List<CartItem> previous = _items;
    _items = List<CartItem>.unmodifiable(next);
    _status = CartStatus.ready;
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    final Result<int> result = await _saveCart(_items);
    _isSyncing = false;
    final bool ok = result.isSuccess;
    if (!ok) {
      _items = previous;
      _syncError = result.failureOrNull?.message ??
          'Gagal menyimpan keranjang. Coba lagi.';
    }
    notifyListeners();
    return ok;
  }

  static int _clampQty(int value) =>
      math.max(kCartMinQuantity, math.min(kCartMaxQuantity, value));

  static String _clipNote(String note) {
    final String t = note.trim();
    return t.length > kCartNoteMaxLength
        ? t.substring(0, kCartNoteMaxLength)
        : t;
  }
}
