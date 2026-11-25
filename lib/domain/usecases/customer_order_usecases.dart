// lib/domain/usecases/customer_order_usecases.dart
//
// Usecase pesanan pelanggan (TASK-025): checkout, daftar riwayat, dan detail.

import '../../core/common/result.dart';
import '../entities/customer_order_entity.dart';
import '../repositories/customer_order_repository.dart';

class CheckoutCustomerOrder {
  const CheckoutCustomerOrder(this._repository);

  final CustomerOrderRepository _repository;

  Future<Result<CustomerOrder>> call({required String address}) {
    return _repository.checkout(address: address);
  }
}

class GetCustomerOrders {
  const GetCustomerOrders(this._repository);

  final CustomerOrderRepository _repository;

  Future<Result<List<CustomerOrder>>> call() {
    return _repository.fetchOrders();
  }
}

class GetCustomerOrderDetail {
  const GetCustomerOrderDetail(this._repository);

  final CustomerOrderRepository _repository;

  Future<Result<CustomerOrder>> call(int id) {
    return _repository.fetchOrderDetail(id);
  }
}
