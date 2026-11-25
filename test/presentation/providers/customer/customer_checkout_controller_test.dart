// test/presentation/providers/customer/customer_checkout_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/domain/repositories/customer_order_repository.dart';
import 'package:soju_fe/domain/repositories/storefront_repository.dart';
import 'package:soju_fe/domain/usecases/customer_order_usecases.dart';
import 'package:soju_fe/domain/usecases/storefront_usecases.dart';
import 'package:soju_fe/presentation/providers/customer/customer_checkout_controller.dart';
import 'package:soju_fe/presentation/providers/storefront/customer_cart_controller.dart';

class _FakeOrderRepo implements CustomerOrderRepository {
  Result<CustomerOrder>? resultToReturn;
  String? capturedAddress;

  @override
  Future<Result<CustomerOrder>> checkout({required String address}) async {
    capturedAddress = address;
    return resultToReturn ??
        Result<CustomerOrder>.success(
          CustomerOrder(
            id: 1,
            code: 'PSN-TEST-1',
            customerId: 1,
            recipientName: 'Budi',
            recipientEmail: 'budi@test.com',
            recipientPhone: '08123',
            recipientAddress: address,
            total: 45000,
            status: CustomerOrderStatus.menungguKonfirmasi,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<Result<List<CustomerOrder>>> fetchOrders() async =>
      Result<List<CustomerOrder>>.success(<CustomerOrder>[]);

  @override
  Future<Result<CustomerOrder>> fetchOrderDetail(int id) async =>
      throw UnimplementedError();
}

class _FakeStorefrontRepo implements StorefrontRepository {
  List<CartItem> items = <CartItem>[];

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search}) async =>
      Result<List<CatalogProduct>>.success(<CatalogProduct>[]);

  @override
  Future<Result<List<CartItem>>> fetchCart() async =>
      Result<List<CartItem>>.success(items);

  @override
  Future<Result<int>> saveCart(List<CartItem> newItems) async {
    items = List<CartItem>.from(newItems);
    return Result<int>.success(items.length);
  }
}

void main() {
  late _FakeOrderRepo orderRepo;
  late _FakeStorefrontRepo storefrontRepo;
  late CustomerCartController cartController;
  late CustomerCheckoutController checkoutController;

  setUp(() {
    orderRepo = _FakeOrderRepo();
    storefrontRepo = _FakeStorefrontRepo();
    cartController = CustomerCartController(
      getCart: GetCart(storefrontRepo),
      saveCart: SaveCart(storefrontRepo),
    );
    checkoutController = CustomerCheckoutController(
      checkoutOrder: CheckoutCustomerOrder(orderRepo),
      initialAddress: 'Jl. Senopati No. 10',
    );
  });

  tearDown(() {
    cartController.dispose();
    checkoutController.dispose();
  });

  group('CustomerCheckoutController', () {
    test('initializes with initialAddress and clean state', () {
      expect(checkoutController.deliveryAddress, 'Jl. Senopati No. 10');
      expect(checkoutController.isLoading, isFalse);
      expect(checkoutController.errorMessage, isNull);
      expect(checkoutController.addressError, isNull);
    });

    test('validates empty delivery address and rejects submission', () async {
      checkoutController.setDeliveryAddress('   ');

      final bool success = await checkoutController.submitCheckout(
        cartController: cartController,
      );

      expect(success, isFalse);
      expect(checkoutController.addressError, 'Alamat pengiriman wajib diisi');
      expect(orderRepo.capturedAddress, isNull);
    });

    test('submits checkout, clears synced cart, and stores created order', () async {
      // Setup cart with items
      await cartController.addProduct(
        const CatalogProduct(
          id: 1,
          code: 'P-1',
          name: 'Soju Peach',
          variants: <String>[],
          unit: 'Botol',
          price: 45000,
        ),
        quantity: 2,
      );
      expect(cartController.totalQuantity, 2);

      final bool success = await checkoutController.submitCheckout(
        cartController: cartController,
      );

      expect(success, isTrue);
      expect(checkoutController.isLoading, isFalse);
      expect(checkoutController.order?.code, 'PSN-TEST-1');
      expect(orderRepo.capturedAddress, 'Jl. Senopati No. 10');
      // Cart should be reset to empty
      expect(cartController.isEmpty, isTrue);
      expect(cartController.totalQuantity, 0);
    });

    test('sets error message when checkout fails at repository level', () async {
      orderRepo.resultToReturn = Result<CustomerOrder>.failure(
        const ServerFailure(
          statusCode: 400,
          message: 'Keranjang Anda telah berubah atau kedaluwarsa.',
        ),
      );

      final bool success = await checkoutController.submitCheckout(
        cartController: cartController,
      );

      expect(success, isFalse);
      expect(checkoutController.order, isNull);
      expect(
        checkoutController.errorMessage,
        'Keranjang Anda telah berubah atau kedaluwarsa.',
      );
    });
  });
}
