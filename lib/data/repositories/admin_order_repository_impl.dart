// lib/data/repositories/admin_order_repository_impl.dart
//
// Implementasi AdminOrderRepository.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/customer_order_entity.dart';
import '../../domain/repositories/admin_order_repository.dart';
import '../datasources/interfaces/admin_order_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/customer/customer_order_models.dart';

class AdminOrderRepositoryImpl implements AdminOrderRepository {
  const AdminOrderRepositoryImpl(this._dataSource);

  final AdminOrderDataSource _dataSource;

  @override
  Future<Result<List<CustomerOrder>>> fetchOrders({
    CustomerOrderStatus? status,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchOrdersRaw(
        status: status?.raw,
      );
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Daftar pesanan tidak valid.',
          ),
        );
      }

      final Object? dataContent = envelope.data;
      final List list;
      if (dataContent is List) {
        list = dataContent;
      } else if (dataContent is Map && dataContent['data'] is List) {
        list = dataContent['data'] as List;
      } else {
        list = const <Object?>[];
      }

      final List<CustomerOrder> orders = list
          .whereType<Map<String, Object?>>()
          .map((Map<String, Object?> m) => CustomerOrderModel.fromJson(m).toEntity())
          .toList();

      return Result.success(orders);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<CustomerOrder>> updateOrderStatus({
    required int orderId,
    required CustomerOrderStatus status,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.updateOrderStatusRaw(
        id: orderId,
        status: status.raw,
      );
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Gagal memperbarui status pesanan.',
          ),
        );
      }

      if (envelope.data is! Map) {
        return Result.failure(const ParsingFailure());
      }

      final CustomerOrder order = CustomerOrderModel.fromJson(
        envelope.data as Map<String, Object?>,
      ).toEntity();

      return Result.success(order);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
