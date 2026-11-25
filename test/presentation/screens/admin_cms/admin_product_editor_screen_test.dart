// test/presentation/screens/admin_cms/admin_product_editor_screen_test.dart
//
// Widget test AdminProductEditorScreen pada layar mobile (430x932) dan
// desktop (1200x800), termasuk tombol Pratinjau -> ProductDetailSheet.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/themes/app_theme.dart';
import 'package:soju_fe/domain/entities/admin_cms_entity.dart';
import 'package:soju_fe/presentation/screens/admin_cms/admin_product_editor_screen.dart';

void main() {
  testWidgets(
    'AdminProductEditorScreen tampil responsif di desktop, mendukung pratinjau & publikasi',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      AdminProductDraft? capturedDraft;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdminProductEditorScreen(
            onSave: (AdminProductDraft draft) async {
              capturedDraft = draft;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tambah Produk Baru'), findsOneWidget);
      expect(find.text('Detail Produk'), findsOneWidget);
      expect(find.text('Visibilitas'), findsOneWidget);
      expect(find.text('Cover'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('admin_product_name_field')),
        'Soju Leci Segar',
      );
      await tester.enterText(
        find.byKey(const Key('admin_product_price_field')),
        '48000',
      );
      await tester.enterText(
        find.byKey(const Key('admin_product_variant_field')),
        'Dingin, Normal',
      );

      // Buka tab Lanjutan untuk isi URL gambar
      await tester.tap(find.byKey(const Key('admin_product_tab_advanced')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('admin_product_image_field')), findsOneWidget);

      // Uji Pratinjau membuka ProductDetailSheet
      await tester.tap(find.byKey(const Key('admin_product_preview_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('product_detail_sheet')), findsOneWidget);
      expect(find.text('Soju Leci Segar'), findsOneWidget);

      // Tutup sheet pratinjau
      Navigator.of(tester.element(find.byKey(const Key('product_detail_sheet'))))
          .pop();
      await tester.pumpAndSettle();

      // Publikasikan produk
      await tester.tap(find.byKey(const Key('admin_product_publish_button')));
      await tester.pumpAndSettle();

      expect(capturedDraft, isNotNull);
      expect(capturedDraft!.name, 'Soju Leci Segar');
      expect(capturedDraft!.price, 48000);
      expect(capturedDraft!.variant, 'Dingin, Normal');
      expect(capturedDraft!.isActive, isTrue);
    },
  );

  testWidgets(
    'AdminProductEditorScreen nyaman di layar mobile (430x932) dan menyimpan draft',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      AdminProductDraft? capturedDraft;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdminProductEditorScreen(
            existing: const AdminProductItem(
              id: 7,
              code: 'PRD-007',
              name: 'Tteokbokki Keju',
              unit: 'porsi',
              price: 35000,
              variant: 'Pedas, Sedang',
              isActive: true,
            ),
            onSave: (AdminProductDraft draft) async {
              capturedDraft = draft;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Produk'), findsOneWidget);
      expect(find.byKey(const Key('admin_product_draft_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('admin_product_draft_button')));
      await tester.pumpAndSettle();

      expect(capturedDraft, isNotNull);
      expect(capturedDraft!.name, 'Tteokbokki Keju');
      expect(capturedDraft!.isActive, isFalse);
    },
  );
}
