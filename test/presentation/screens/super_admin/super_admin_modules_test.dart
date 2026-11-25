// test/presentation/screens/super_admin/super_admin_modules_test.dart
//
// Widget test modul Super Admin: AdminCmsScreen (`/admin/cms`) dan AdminCrmScreen (`/admin/crm`).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/themes/app_theme.dart';
import 'package:soju_fe/data/data_providers.dart';
import 'package:soju_fe/presentation/screens/admin_cms/admin_cms_screen.dart';
import 'package:soju_fe/presentation/screens/admin_crm/admin_crm_screen.dart';

void main() {
  setUp(() {
    DataProviders.resetAuth();
  });

  testWidgets(
    'AdminCmsScreen menampilkan Konten Publik dan Katalog Produk serta dapat berpindah tab',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AdminCmsScreen(
            controllerFactory: DataProviders.createAdminCmsController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Konten CMS & Produk'), findsOneWidget);
      expect(find.text('headline_beranda'), findsOneWidget);
      expect(find.text('Selamat Datang di Buku Dapur SOJU'), findsOneWidget);

      await tester.tap(find.textContaining('Katalog Produk'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sosis Solo Ayam'), findsOneWidget);
      expect(find.textContaining('Rp 35.000'), findsOneWidget);
    },
  );

  testWidgets(
    'AdminCrmScreen menampilkan ringkasan pelanggan, toggle status, dan tab Kampanye CRM',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AdminCrmScreen(
            controllerFactory: DataProviders.createAdminCrmController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pelanggan & CRM'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsOneWidget);
      expect(find.text('3 Pesanan'), findsOneWidget);

      await tester.tap(find.textContaining('Kampanye CRM'));
      await tester.pumpAndSettle();

      expect(find.text('Promo Akhir Pekan SOJU'), findsOneWidget);
      expect(find.text('Semua Pelanggan Berizin Promo'), findsOneWidget);
    },
  );
}
