// lib/domain/repositories/customer_order_repository.dart
//
// Kontrak repository pesanan pelanggan (TASK-025).

import '../../core/common/result.dart';
import '../entities/customer_order_entity.dart';

abstract class CustomerOrderRepository {
  /// Mengirim checkout pesanan baru berdasarkan isi keranjang aktif di backend.
  Future<Result<CustomerOrder>> checkout({required String address});

  /// Mengambil daftar riwayat pesanan pelanggan aktif.
  Future<Result<List<CustomerOrder>>> fetchOrders();

  /// Mengambil rincian pesanan pelanggan berdasarkan ID.
  Future<Result<CustomerOrder>> fetchOrderDetail(int id);
}
