// lib/presentation/providers/admin_orders/admin_orders_controller.dart
//
// Controller untuk Pesanan Pelanggan di sisi Admin (`ADMIN` & `SUPER_ADMIN`).
// Menangani state: loading, data, empty, error, updating status, dan retry.

import 'package:flutter/foundation.dart';
import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/customer_order_entity.dart';
import '../../../domain/usecases/admin_order_usecases.dart';

enum AdminOrdersStatus { loading, data, empty, error }

class AdminOrdersState {
  const AdminOrdersState({
    required this.status,
    this.orders = const <CustomerOrder>[],
    this.filterStatus,
    this.errorMessage,
    this.updatingOrderId,
  });

  const AdminOrdersState.initial()
      : this(status: AdminOrdersStatus.loading);

  final AdminOrdersStatus status;
  final List<CustomerOrder> orders;
  final CustomerOrderStatus? filterStatus;
  final String? errorMessage;
  final int? updatingOrderId;

  bool isUpdating(int orderId) => updatingOrderId == orderId;

  AdminOrdersState copyWith({
    AdminOrdersStatus? status,
    List<CustomerOrder>? orders,
    CustomerOrderStatus? filterStatus,
    bool clearFilter = false,
    String? errorMessage,
    int? updatingOrderId,
    bool clearUpdating = false,
  }) {
    return AdminOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filterStatus:
          clearFilter ? null : (filterStatus ?? this.filterStatus),
      errorMessage: errorMessage ?? this.errorMessage,
      updatingOrderId:
          clearUpdating ? null : (updatingOrderId ?? this.updatingOrderId),
    );
  }
}

class AdminOrdersController extends ChangeNotifier {
  AdminOrdersController({
    required GetAdminOrders getAdminOrders,
    required UpdateAdminOrderStatus updateAdminOrderStatus,
  })  : _getAdminOrders = getAdminOrders,
        _updateAdminOrderStatus = updateAdminOrderStatus;

  final GetAdminOrders _getAdminOrders;
  final UpdateAdminOrderStatus _updateAdminOrderStatus;

  AdminOrdersState _state = const AdminOrdersState.initial();
  AdminOrdersState get state => _state;

  Future<void> load({CustomerOrderStatus? status}) async {
    _state = _state.copyWith(
      status: AdminOrdersStatus.loading,
      filterStatus: status,
      clearFilter: status == null,
      errorMessage: null,
    );
    notifyListeners();

    final Result<List<CustomerOrder>> result =
        await _getAdminOrders(status: status);

    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: AdminOrdersStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (List<CustomerOrder> items) {
        if (items.isEmpty) {
          _state = _state.copyWith(
            status: AdminOrdersStatus.empty,
            orders: const <CustomerOrder>[],
          );
        } else {
          _state = _state.copyWith(
            status: AdminOrdersStatus.data,
            orders: items,
          );
        }
      },
    );
    notifyListeners();
  }

  Future<bool> updateStatus({
    required int orderId,
    required CustomerOrderStatus newStatus,
  }) async {
    _state = _state.copyWith(updatingOrderId: orderId);
    notifyListeners();

    final Result<CustomerOrder> result = await _updateAdminOrderStatus(
      orderId: orderId,
      status: newStatus,
    );

    bool success = false;
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          clearUpdating: true,
          errorMessage: failure.message,
        );
      },
      onSuccess: (CustomerOrder updated) {
        success = true;
        final List<CustomerOrder> updatedList = _state.orders.map((CustomerOrder o) {
          return o.id == updated.id ? updated : o;
        }).toList();

        _state = _state.copyWith(
          clearUpdating: true,
          orders: updatedList,
        );
      },
    );
    notifyListeners();
    return success;
  }
}
