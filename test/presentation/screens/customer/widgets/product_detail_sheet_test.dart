// test/presentation/screens/customer/widgets/product_detail_sheet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/domain/entities/storefront_entity.dart';
import 'package:soju_fe/presentation/screens/customer/widgets/product_detail_sheet.dart';

void main() {
  const CatalogProduct productWithVariants = CatalogProduct(
    id: 1,
    code: 'MN-001',
    name: 'Soju Sparkling Peach',
    variants: <String>['Dingin', 'Normal'],
    unit: 'Botol',
    price: 45000,
    description: 'Minuman segar beraroma persik.',
  );

  const CatalogProduct productWithoutVariants = CatalogProduct(
    id: 2,
    code: 'MN-002',
    name: 'Kimchi Fried Rice',
    variants: <String>[],
    unit: 'Porsi',
    price: 28000,
  );

  testWidgets('renders product details and handles variant selection, quantity, and notes',
      (WidgetTester tester) async {
    ProductSelection? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                key: const Key('open_sheet'),
                onPressed: () async {
                  result = await showProductDetailSheet(
                    context,
                    productWithVariants,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open_sheet')));
    await tester.pumpAndSettle();

    // Verify product name, description, price
    expect(find.text('Soju Sparkling Peach'), findsOneWidget);
    expect(find.text('Minuman segar beraroma persik.'), findsOneWidget);
    expect(find.text('Rp 45.000 / Botol'), findsOneWidget);

    // Verify variants chips
    expect(find.text('Dingin'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);

    // Try submit without selecting variant
    await tester.tap(find.byKey(const Key('product_add_to_cart')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product_variant_error')), findsOneWidget);
    expect(find.text('Pilih varian terlebih dahulu.'), findsOneWidget);

    // Select variant
    await tester.tap(find.byKey(const Key('product_variant_Dingin')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product_variant_error')), findsNothing);

    // Increment quantity
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('product_quantity_increment')));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    // Enter note
    await tester.enterText(
      find.byKey(const Key('product_note_field')),
      'Banyakin es',
    );
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.byKey(const Key('product_add_to_cart')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.variant, 'Dingin');
    expect(result!.quantity, 2);
    expect(result!.note, 'Banyakin es');
  });

  testWidgets('submits product without variants without requiring variant selection',
      (WidgetTester tester) async {
    ProductSelection? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                key: const Key('open_sheet_no_variants'),
                onPressed: () async {
                  result = await showProductDetailSheet(
                    context,
                    productWithoutVariants,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open_sheet_no_variants')));
    await tester.pumpAndSettle();

    expect(find.text('Kimchi Fried Rice'), findsOneWidget);
    expect(find.text('Pilih Varian'), findsNothing);

    await tester.tap(find.byKey(const Key('product_add_to_cart')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.variant, isEmpty);
    expect(result!.quantity, 1);
  });
}
