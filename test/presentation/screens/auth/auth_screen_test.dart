// Widget test: alur auth (Masuk <-> Daftar) yang digeser dalam satu layar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/auth/auth_screen.dart';
import 'package:soju_fe/presentation/screens/auth/widgets/auth_header.dart';

void main() {
  const String loginSubtitle =
      'Masuk untuk melanjutkan mengelola keuangan dan stok tokomu.';
  const String registerSubtitle =
      'Buat akun sekarang dan tingkatkan penjualan tokomu dengan analitik '
      'pintar.';

  Future<void> pumpAuth(
    WidgetTester tester, {
    AuthTab initialTab = AuthTab.login,
    VoidCallback? onForgotPassword,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          initialTab: initialTab,
          onForgotPassword: onForgotPassword,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Auth memulai di tab Masuk', (WidgetTester tester) async {
    await pumpAuth(tester);

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text(loginSubtitle).hitTestable(), findsOneWidget);
    expect(find.text(registerSubtitle).hitTestable(), findsNothing);
  });

  testWidgets('Tab Daftar menggeser ke formulir daftar tanpa pindah layar', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    await tester.tap(find.text('Daftar').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text(registerSubtitle).hitTestable(), findsOneWidget);
    expect(find.text(loginSubtitle).hitTestable(), findsNothing);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('Tab Masuk menggeser kembali ke formulir masuk', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester, initialTab: AuthTab.register);

    expect(find.text(registerSubtitle).hitTestable(), findsOneWidget);

    await tester.tap(find.text('Masuk').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text(loginSubtitle).hitTestable(), findsOneWidget);
    expect(find.text(registerSubtitle).hitTestable(), findsNothing);
  });

  testWidgets('Auth dibuka langsung pada tab Daftar bila diminta', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester, initialTab: AuthTab.register);

    expect(find.text(registerSubtitle).hitTestable(), findsOneWidget);
    expect(find.text(loginSubtitle).hitTestable(), findsNothing);
  });

  testWidgets('Sapuan horizontal berpindah tab', (WidgetTester tester) async {
    await pumpAuth(tester);

    // Geser dari area header agar tidak berebut gestur dengan medan isian.
    await tester.dragFrom(const Offset(215, 150), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text(registerSubtitle).hitTestable(), findsOneWidget);

    await tester.dragFrom(const Offset(215, 150), const Offset(350, 0));
    await tester.pumpAndSettle();
    expect(find.text(loginSubtitle).hitTestable(), findsOneWidget);
  });

  testWidgets('Isian tetap tersimpan saat bergeser antar tab', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    await tester.enterText(
      find.byType(TextFormField).hitTestable().first,
      'budi@contoh.com',
    );
    await tester.pump();

    await tester.tap(find.text('Daftar').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('budi@contoh.com').hitTestable(), findsOneWidget);
  });

  testWidgets('Tautan Lupa password tetap berfungsi di dalam alur auth', (
    WidgetTester tester,
  ) async {
    bool forgotPasswordTapped = false;
    await pumpAuth(
      tester,
      onForgotPassword: () => forgotPasswordTapped = true,
    );

    await tester.tap(find.text('Lupa password?'));
    await tester.pump();

    expect(forgotPasswordTapped, isTrue);
  });
}
