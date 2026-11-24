// lib/domain/usecases/admin_order_usecases.dart
//
// Usecase untuk pesanan pelanggan di sisi Admin.

import '../../core/common/result.dart';
import '../entities/customer_order_entity.dart';
import '../repositories/admin_order_repository.dart';

class GetAdminOrders {
  const GetAdminOrders(this._repository);

  final AdminOrderRepository _repository;

  Future<Result<List<CustomerOrder>>> call({CustomerOrderStatus? status}) {
    return _repository.fetchOrders(status: status);
  }
}

class UpdateAdminOrderStatus {
  const UpdateAdminOrderStatus(this._repository);

  final AdminOrderRepository _repository;

  Future<Result<CustomerOrder>> call({
    required int orderId,
    required CustomerOrderStatus status,
  }) {
    return _repository.updateOrderStatus(orderId: orderId, status: status);
  }
}
