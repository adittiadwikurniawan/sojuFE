// lib/presentation/providers/customer/customer_orders_controller.dart
//
// Controller riwayat pesanan pelanggan SOJU (TASK-025).

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../domain/entities/customer_order_entity.dart';
import '../../../domain/usecases/customer_order_usecases.dart';

class CustomerOrdersController extends ChangeNotifier {
  CustomerOrdersController({
    required GetCustomerOrders getOrders,
    GetCustomerOrderDetail? getOrderDetail,
  })  : _getOrders = getOrders,
        _getOrderDetail = getOrderDetail;

  final GetCustomerOrders _getOrders;
  final GetCustomerOrderDetail? _getOrderDetail;

  bool _isLoading = false;
  String? _errorMessage;
  List<CustomerOrder> _orders = const <CustomerOrder>[];
  CustomerOrderStatus? _statusFilter;
  CustomerOrder? _selectedOrderDetail;
  bool _isLoadingDetail = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CustomerOrder> get orders => _orders;
  CustomerOrderStatus? get statusFilter => _statusFilter;
  CustomerOrder? get selectedOrderDetail => _selectedOrderDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isEmpty => _orders.isEmpty;

  List<CustomerOrder> get filteredOrders {
    if (_statusFilter == null) {
      return _orders;
    }
    return _orders.where((CustomerOrder o) => o.status == _statusFilter).toList();
  }

  void setFilter(CustomerOrderStatus? filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final Result<List<CustomerOrder>> result = await _getOrders();
    _isLoading = false;

    if (result.isSuccess) {
      _orders = result.valueOrNull ?? const <CustomerOrder>[];
      _errorMessage = null;
    } else {
      _errorMessage = result.failureOrNull?.message ??
          'Gagal memuat riwayat pesanan. Ketuk untuk coba lagi.';
    }
    notifyListeners();
  }

  Future<void> refresh() => loadOrders();

  Future<CustomerOrder?> loadOrderDetail(int id) async {
    final GetCustomerOrderDetail? usecase = _getOrderDetail;
    if (usecase == null) {
      // Fallback cari di riwayat yang sudah dimuat
      return _orders.cast<CustomerOrder?>().firstWhere(
            (CustomerOrder? o) => o?.id == id,
            orElse: () => null,
          );
    }

    _isLoadingDetail = true;
    notifyListeners();

    final Result<CustomerOrder> result = await usecase(id);
    _isLoadingDetail = false;

    if (result.isSuccess) {
      _selectedOrderDetail = result.valueOrNull;
    }
    notifyListeners();
    return result.valueOrNull;
  }
}
