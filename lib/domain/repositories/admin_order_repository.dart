// lib/domain/repositories/admin_order_repository.dart
//
// Kontrak repository pesanan pelanggan untuk admin (`ADMIN` & `SUPER_ADMIN`).

import '../../core/common/result.dart';
import '../entities/customer_order_entity.dart';

abstract interface class AdminOrderRepository {
  /// Mengambil daftar pesanan pelanggan dari endpoint admin.
  Future<Result<List<CustomerOrder>>> fetchOrders({CustomerOrderStatus? status});

  /// Memperbarui status pesanan pelanggan.
  Future<Result<CustomerOrder>> updateOrderStatus({
    required int orderId,
    required CustomerOrderStatus status,
  });
}
