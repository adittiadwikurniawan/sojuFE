// test/data/repositories/admin_repositories_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/data/datasources/interfaces/admin_order_datasource.dart';
import 'package:soju_fe/data/datasources/interfaces/dashboard_datasource.dart';
import 'package:soju_fe/data/datasources/interfaces/transaction_datasource.dart';
import 'package:soju_fe/data/repositories/admin_order_repository_impl.dart';
import 'package:soju_fe/data/repositories/dashboard_repository_impl.dart';
import 'package:soju_fe/data/repositories/transaction_repository_impl.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';
import 'package:soju_fe/domain/entities/dashboard_entity.dart';
import 'package:soju_fe/domain/entities/transaction_entity.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_transaction.dart';

class _FakeDashboardDataSource implements DashboardDataSource {
  @override
  Future<Map<String, Object?>> fetchSummary({String period = '7d'}) async {
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'saldo_kas': 1500000,
        'order_baru': <String, Object?>{'total': 5},
      },
    };
  }

  @override
  Future<Map<String, Object?>> fetchCashChart({String period = '7d'}) async {
    return <String, Object?>{
      'success': true,
      'data': <Map<String, Object?>>[
        <String, Object?>{
          'tanggal': '2026-11-20',
          'pemasukan': 200000,
          'pengeluaran': 50000,
        },
      ],
    };
  }

  @override
  Future<List<Map<String, Object?>>> fetchRecentActivities({int limit = 5}) async {
    return <Map<String, Object?>>[
      <String, Object?>{
        'id': 'log-1',
        'recordLabel': 'Penjualan Sosis Solo',
        'action': 'tambah',
        'detail': '2 porsi',
      },
    ];
  }
}

class _FakeTransactionDataSource implements TransactionDataSource {
  @override
  Future<Map<String, Object?>> fetchTransactionsRaw({
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    return <String, Object?>{
      'success': true,
      'data': <Map<String, Object?>>[
        <String, Object?>{
          'id': 101,
          'kode': 'TRX-101',
          'namaTransaksi': 'Penjualan Sosis Solo',
          'detail': '2 porsi',
          'nominal': 36000,
          'jenisTransaksi': <String, Object?>{
            'namaTransaksi': 'Pendapatan Siap Saji',
            'arah': 'PEMASUKAN',
          },
          'tanggal': '2026-11-24T10:00:00.000Z',
          'sumberInput': 'MANUAL',
        },
      ],
    };
  }
}

class _FakeAdminOrderDataSource implements AdminOrderDataSource {
  CustomerOrderStatus currentStatus = CustomerOrderStatus.menungguKonfirmasi;

  @override
  Future<Map<String, Object?>> fetchOrdersRaw({String? status}) async {
    return <String, Object?>{
      'success': true,
      'data': <Map<String, Object?>>[
        <String, Object?>{
          'id': 1,
          'kode': 'ORD-001',
          'pelangganId': 10,
          'namaPenerima': 'Budi Santoso',
          'emailPenerima': 'budi@example.com',
          'noTelepon': '081234567890',
          'alamat': 'Jl. Merdeka No. 1',
          'total': 45000,
          'status': currentStatus.raw,
          'dibuatPada': '2026-11-24T12:00:00.000Z',
          'item': <Map<String, Object?>>[
            <String, Object?>{
              'id': 100,
              'pesananId': 1,
              'produkId': 2,
              'namaProduk': 'Sosis Solo',
              'harga': 15000,
              'jumlah': 3,
              'subtotal': 45000,
            },
          ],
        },
      ],
    };
  }

  @override
  Future<Map<String, Object?>> updateOrderStatusRaw({required int id, required String status}) async {
    currentStatus = CustomerOrderStatus.fromRaw(status);
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'id': id,
        'kode': 'ORD-001',
        'pelangganId': 10,
        'namaPenerima': 'Budi Santoso',
        'emailPenerima': 'budi@example.com',
        'noTelepon': '081234567890',
        'alamat': 'Jl. Merdeka No. 1',
        'total': 45000,
        'status': status,
        'dibuatPada': '2026-11-24T12:00:00.000Z',
        'item': <Map<String, Object?>>[],
      },
    };
  }
}

void main() {
  group('AdminRepositories', () {
    test('DashboardRepositoryImpl maps summary, chart, and activities correctly', () async {
      final repo = DashboardRepositoryImpl(_FakeDashboardDataSource());
      final result = await repo.fetchDashboardSummary(period: '7d');

      expect(result.isSuccess, isTrue);
      final DashboardSummaryEntity summary = result.valueOrNull!;
      expect(summary.cashBalance, 1500000);
      expect(summary.newOrdersCount, 5);
      expect(summary.revenueSummary, isNotNull);
      expect(summary.recentActivities.length, 1);
      expect(summary.recentActivities.first.name, 'Penjualan Sosis Solo');
    });

    test('TransactionRepositoryImpl maps transaction entity with income type', () async {
      final repo = TransactionRepositoryImpl(_FakeTransactionDataSource());
      final result = await repo.fetchTransactions();

      expect(result.isSuccess, isTrue);
      final List<TransactionEntity> items = result.valueOrNull!;
      expect(items.length, 1);
      expect(items.first.title, 'Penjualan Sosis Solo');
      expect(items.first.type, TransactionType.income);
      expect(items.first.amount, 36000);
    });

    test('AdminOrderRepositoryImpl fetches and updates order status', () async {
      final fakeDs = _FakeAdminOrderDataSource();
      final repo = AdminOrderRepositoryImpl(fakeDs);

      final listResult = await repo.fetchOrders();
      expect(listResult.isSuccess, isTrue);
      final List<CustomerOrder> orders = listResult.valueOrNull!;
      expect(orders.length, 1);
      expect(orders.first.status, CustomerOrderStatus.menungguKonfirmasi);
      expect(orders.first.recipientName, 'Budi Santoso');
      expect(orders.first.items.length, 1);

      final updateResult = await repo.updateOrderStatus(
        orderId: 1,
        status: CustomerOrderStatus.diproses,
      );
      expect(updateResult.isSuccess, isTrue);
      final CustomerOrder updated = updateResult.valueOrNull!;
      expect(updated.status, CustomerOrderStatus.diproses);
      expect(fakeDs.currentStatus, CustomerOrderStatus.diproses);
    });
  });
}
