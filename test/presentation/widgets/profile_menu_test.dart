// Widget test: menu Profil / Menu Akun (Figma `622:1156`).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/profile/models/profile_view_data.dart';
import 'package:soju_fe/presentation/widgets/profile_menu.dart';

void main() {
  Future<void> pumpMenu(
    WidgetTester tester, {
    VoidCallback? onLogout,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: ElevatedButton(
                onPressed: () => showProfileMenu(
                  context,
                  data: ProfileViewData.sample,
                  onLogout: onLogout,
                ),
                child: const Text('Buka profil'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Buka profil'));
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan nama, email, role, dan hanya aksi Keluar', (
    WidgetTester tester,
  ) async {
    await pumpMenu(tester);

    expect(find.byKey(const Key('profile_menu_card')), findsOneWidget);
    expect(find.text('Adittia'), findsOneWidget);
    expect(find.text('adittia@sojucorp.com'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);

    // Sesuai PRD, pengelolaan akun belum tersedia.
    expect(find.text('Tambah Akun'), findsNothing);
    expect(find.text('Kelola Akun'), findsNothing);
  });

  testWidgets('Keluar membuka dialog konfirmasi dan Batal tidak memanggil aksi',
      (WidgetTester tester) async {
    int logoutCount = 0;
    await pumpMenu(tester, onLogout: () => logoutCount++);

    await tester.tap(find.byKey(const Key('profile_logout')));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari akun?'), findsOneWidget);
    expect(find.textContaining('Adittia'), findsWidgets);

    await tester.tap(find.byKey(const Key('profile_logout_cancel')));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari akun?'), findsNothing);
    expect(logoutCount, 0);
  });

  testWidgets('konfirmasi Keluar memanggil callback logout', (
    WidgetTester tester,
  ) async {
    int logoutCount = 0;
    await pumpMenu(tester, onLogout: () => logoutCount++);

    await tester.tap(find.byKey(const Key('profile_logout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_logout_confirm')));
    await tester.pumpAndSettle();

    expect(logoutCount, 1);
  });
}
