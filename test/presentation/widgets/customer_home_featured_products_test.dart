import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/domain/repositories/featured_products_repository.dart';
import 'package:soju_fe/domain/usecases/featured_products_usecase.dart';
import 'package:soju_fe/presentation/providers/storefront/featured_products_controller.dart';
import 'package:soju_fe/presentation/widgets/role_shell_screens.dart';

class _FakeFeaturedProductsRepository implements FeaturedProductsRepository {
  Result<List<CatalogProduct>> result =
      Result<List<CatalogProduct>>.success(<CatalogProduct>[]);
  int calls = 0;

  @override
  Future<Result<List<CatalogProduct>>> fetchFeaturedProducts() async {
    calls++;
    return result;
  }
}

void main() {
  testWidgets('renders featured product card and retries after an error',
      (WidgetTester tester) async {
    final _FakeFeaturedProductsRepository repository =
        _FakeFeaturedProductsRepository()
          ..result = Result<List<CatalogProduct>>.failure(
            const ServerFailure(message: 'Gagal memuat produk.'),
          );
    final FeaturedProductsController controller = FeaturedProductsController(
      getProducts: GetFeaturedProducts(repository),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerHomeShellScreen(
          featuredProductsController: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat produk.'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    repository.result = Result<List<CatalogProduct>>.success(
      <CatalogProduct>[
        const CatalogProduct(
          id: 1,
          code: 'MN-001',
          name: 'Soju Sparkling Peach',
          variants: <String>['Dingin'],
          unit: 'Botol',
          price: 1234567,
        ),
      ],
    );
    await tester.tap(find.byKey(const Key('customer_home_featured_retry')));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text('Soju Sparkling Peach'), findsOneWidget);
    expect(find.text('Dingin'), findsOneWidget);
    expect(find.text('Rp 1.234.567'), findsOneWidget);
    expect(find.text('Menu Minuman'), findsNothing);
    expect(find.text('Menu Makanan'), findsNothing);
  });

  testWidgets('shows empty message when no featured products are configured',
      (WidgetTester tester) async {
    final _FakeFeaturedProductsRepository repository =
        _FakeFeaturedProductsRepository();
    final FeaturedProductsController controller = FeaturedProductsController(
      getProducts: GetFeaturedProducts(repository),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerHomeShellScreen(
          featuredProductsController: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada menu pilihan saat ini'), findsOneWidget);
  });
}
