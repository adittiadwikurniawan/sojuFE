// test/data/repositories/customer_order_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/data/datasources/interfaces/customer_order_datasource.dart';
import 'package:soju_fe/data/repositories/customer_order_repository_impl.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';

class _FakeCustomerOrderDataSource implements CustomerOrderDataSource {
  Map<String, Object?>? checkoutResponse;
  Map<String, Object?>? ordersResponse;
  Map<String, Object?>? orderDetailResponse;
  AppFailure? errorToThrow;
  Map<String, Object?>? capturedCheckoutPayload;

  @override
  Future<Map<String, Object?>> checkout(Map<String, Object?> payload) async {
    capturedCheckoutPayload = payload;
    if (errorToThrow != null) throw errorToThrow!;
    return checkoutResponse ??
        <String, Object?>{
          'status': 'success',
          'data': <String, Object?>{
            'id': 1,
            'kode': 'PSN-100',
            'pelangganId': 1,
            'namaPenerima': 'Budi',
            'emailPenerima': 'budi@test.com',
            'noTelepon': '08123',
            'alamat': payload['alamat'] ?? 'Alamat Budi',
            'total': 45000,
            'status': 'MENUNGGU_KONFIRMASI',
            'dibuatPada': '2026-11-25T01:00:00.000Z',
            'item': <Map<String, Object?>>[],
          },
        };
  }

  @override
  Future<Map<String, Object?>> fetchOrders() async {
    if (errorToThrow != null) throw errorToThrow!;
    return ordersResponse ??
        <String, Object?>{
          'status': 'success',
          'data': <Map<String, Object?>>[
            <String, Object?>{
              'id': 1,
              'kode': 'PSN-100',
              'pelangganId': 1,
              'namaPenerima': 'Budi',
              'emailPenerima': 'budi@test.com',
              'noTelepon': '08123',
              'alamat': 'Alamat Budi',
              'total': 45000,
              'status': 'MENUNGGU_KONFIRMASI',
              'dibuatPada': '2026-11-25T01:00:00.000Z',
              'item': <Map<String, Object?>>[],
            },
          ],
        };
  }

  @override
  Future<Map<String, Object?>> fetchOrderDetail(int id) async {
    if (errorToThrow != null) throw errorToThrow!;
    return orderDetailResponse ??
        <String, Object?>{
          'status': 'success',
          'data': <String, Object?>{
            'id': id,
            'kode': 'PSN-$id',
            'pelangganId': 1,
            'namaPenerima': 'Budi',
            'emailPenerima': 'budi@test.com',
            'noTelepon': '08123',
            'alamat': 'Alamat Budi',
            'total': 45000,
            'status': 'DIPROSES',
            'dibuatPada': '2026-11-25T01:00:00.000Z',
            'item': <Map<String, Object?>>[],
          },
        };
  }
}

void main() {
  late _FakeCustomerOrderDataSource dataSource;
  late CustomerOrderRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeCustomerOrderDataSource();
    repository = CustomerOrderRepositoryImpl(dataSource);
  });

  group('CustomerOrderRepositoryImpl.checkout', () {
    test('sends delivery address and returns created CustomerOrder on success', () async {
      final Result<CustomerOrder> result = await repository.checkout(
        address: 'Jl. Merdeka No. 45',
      );

      expect(result.isSuccess, isTrue);
      final CustomerOrder order = result.valueOrNull!;
      expect(order.id, 1);
      expect(order.code, 'PSN-100');
      expect(dataSource.capturedCheckoutPayload?['alamat'], 'Jl. Merdeka No. 45');
    });

    test('returns FailureResult when dataSource throws AppFailure', () async {
      dataSource.errorToThrow = const ServerFailure(
        statusCode: 400,
        message: 'Keranjang masih kosong',
      );

      final Result<CustomerOrder> result = await repository.checkout(
        address: 'Alamat Test',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, 'Keranjang masih kosong');
    });

    test('returns ParsingFailure when response data is invalid', () async {
      dataSource.checkoutResponse = <String, Object?>{
        'status': 'success',
        'data': 'invalid_data_shape',
      };

      final Result<CustomerOrder> result = await repository.checkout(
        address: 'Alamat Test',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ParsingFailure>());
    });
  });

  group('CustomerOrderRepositoryImpl.fetchOrders', () {
    test('returns list of CustomerOrder entities on success', () async {
      final Result<List<CustomerOrder>> result = await repository.fetchOrders();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.length, 1);
      expect(result.valueOrNull?.first.code, 'PSN-100');
    });

    test('returns FailureResult on network error', () async {
      dataSource.errorToThrow = const NetworkFailure();

      final Result<List<CustomerOrder>> result = await repository.fetchOrders();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('CustomerOrderRepositoryImpl.fetchOrderDetail', () {
    test('returns single order with items on success', () async {
      final Result<CustomerOrder> result = await repository.fetchOrderDetail(42);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.id, 42);
      expect(result.valueOrNull?.status, CustomerOrderStatus.diproses);
    });

    test('returns 404 ServerFailure when order is not found', () async {
      dataSource.errorToThrow = const ServerFailure(
        statusCode: 404,
        message: 'Pesanan tidak ditemukan',
      );

      final Result<CustomerOrder> result = await repository.fetchOrderDetail(999);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, 'Pesanan tidak ditemukan');
    });
  });
}
