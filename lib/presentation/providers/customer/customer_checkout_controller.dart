// lib/presentation/providers/customer/customer_checkout_controller.dart
//
// Controller alur checkout pelanggan SOJU (TASK-025).

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../domain/entities/customer_order_entity.dart';
import '../../../domain/usecases/customer_order_usecases.dart';
import '../storefront/customer_cart_controller.dart';

class CustomerCheckoutController extends ChangeNotifier {
  CustomerCheckoutController({
    required CheckoutCustomerOrder checkoutOrder,
    String initialAddress = '',
  })  : _checkoutOrder = checkoutOrder,
        _deliveryAddress = initialAddress;

  final CheckoutCustomerOrder _checkoutOrder;

  bool _isLoading = false;
  String? _errorMessage;
  CustomerOrder? _order;
  String _deliveryAddress;
  String? _addressError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CustomerOrder? get order => _order;
  String get deliveryAddress => _deliveryAddress;
  String? get addressError => _addressError;

  void setDeliveryAddress(String address) {
    _deliveryAddress = address;
    if (_addressError != null && address.trim().isNotEmpty) {
      _addressError = null;
    }
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null || _addressError != null) {
      _errorMessage = null;
      _addressError = null;
      notifyListeners();
    }
  }

  /// Mengirim checkout ke backend, mengosongkan keranjang tersinkronisasi,
  /// dan menghasilkan entity pesanan baru.
  Future<bool> submitCheckout({
    required CustomerCartController cartController,
    String? addressOverride,
  }) async {
    final String addressToUse = (addressOverride ?? _deliveryAddress).trim();
    if (addressToUse.isEmpty) {
      _addressError = 'Alamat pengiriman wajib diisi';
      notifyListeners();
      return false;
    }

    _deliveryAddress = addressToUse;
    _isLoading = true;
    _errorMessage = null;
    _addressError = null;
    notifyListeners();

    final Result<CustomerOrder> result = await _checkoutOrder(
      address: addressToUse,
    );

    _isLoading = false;
    if (result.isSuccess && result.valueOrNull != null) {
      _order = result.valueOrNull;
      // Backend telah mengosongkan keranjang di database; kosongkan keranjang lokal/badge.
      cartController.reset();
      notifyListeners();
      return true;
    }

    _errorMessage = result.failureOrNull?.message ??
        'Gagal membuat pesanan. Silakan periksa kembali keranjang Anda.';
    notifyListeners();
    return false;
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _order = null;
    _addressError = null;
    notifyListeners();
  }
}
