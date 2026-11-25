// lib/data/repositories/customer_order_repository_impl.dart
//
// Implementasi CustomerOrderRepository (TASK-025).

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/customer_order_entity.dart';
import '../../../domain/repositories/customer_order_repository.dart';
import '../datasources/interfaces/customer_order_datasource.dart';
import '../models/customer/customer_order_models.dart';

class CustomerOrderRepositoryImpl implements CustomerOrderRepository {
  const CustomerOrderRepositoryImpl(this._dataSource);

  final CustomerOrderDataSource _dataSource;

  @override
  Future<Result<CustomerOrder>> checkout({required String address}) async {
    try {
      final Map<String, Object?> response = await _dataSource.checkout(
        <String, Object?>{'alamat': address.trim()},
      );
      final Object? raw = response['data'];
      if (raw is! Map<String, Object?>) {
        return Result<CustomerOrder>.failure(const ParsingFailure());
      }
      final CustomerOrderModel model = CustomerOrderModel.fromJson(raw);
      return Result<CustomerOrder>.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result<CustomerOrder>.failure(failure);
    } catch (e) {
      return Result<CustomerOrder>.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<CustomerOrder>>> fetchOrders() async {
    try {
      final Map<String, Object?> response = await _dataSource.fetchOrders();
      final Object? raw = response['data'];
      if (raw is! List) {
        return Result<List<CustomerOrder>>.failure(const ParsingFailure());
      }
      final List<CustomerOrder> orders = raw
          .whereType<Map<String, Object?>>()
          .map((Map<String, Object?> json) => CustomerOrderModel.fromJson(json).toEntity())
          .toList(growable: false);
      return Result<List<CustomerOrder>>.success(orders);
    } on AppFailure catch (failure) {
      return Result<List<CustomerOrder>>.failure(failure);
    } catch (e) {
      return Result<List<CustomerOrder>>.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CustomerOrder>> fetchOrderDetail(int id) async {
    try {
      final Map<String, Object?> response = await _dataSource.fetchOrderDetail(id);
      final Object? raw = response['data'];
      if (raw is! Map<String, Object?>) {
        return Result<CustomerOrder>.failure(const ParsingFailure());
      }
      final CustomerOrderModel model = CustomerOrderModel.fromJson(raw);
      return Result<CustomerOrder>.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result<CustomerOrder>.failure(failure);
    } catch (e) {
      return Result<CustomerOrder>.failure(ServerFailure(message: e.toString()));
    }
  }
}
