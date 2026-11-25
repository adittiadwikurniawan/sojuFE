// Widget test: alur auth multi-peran (Masuk Admin/Pelanggan <-> Daftar Pelanggan).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/domain/entities/auth_session_entity.dart';
import 'package:soju_fe/presentation/screens/auth/auth_screen.dart';
import 'package:soju_fe/presentation/screens/auth/models/login_form_data.dart';
import 'package:soju_fe/presentation/screens/auth/models/register_form_data.dart';
import 'package:soju_fe/presentation/screens/auth/widgets/auth_header.dart';

void main() {
  const String adminLoginSubtitle =
      'Masuk untuk melanjutkan mengelola keuangan dan stok tokomu.';
  const String customerLoginSubtitle =
      'Masuk sebagai pelanggan untuk memesan menu favoritmu.';
  const String registerSubtitle =
      'Buat akun pelanggan untuk memesan menu dan memantau pesananmu.';

  Future<void> pumpAuth(
    WidgetTester tester, {
    AuthTab initialTab = AuthTab.login,
    AuthPortal initialPortal = AuthPortal.admin,
    ValueChanged<LoginFormData>? onLoginSubmit,
    ValueChanged<RegisterFormData>? onRegisterSubmit,
    VoidCallback? onForgotPassword,
    ValueChanged<AuthPortal>? onForgotPasswordWithPortal,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          initialTab: initialTab,
          initialPortal: initialPortal,
          onLoginSubmit: onLoginSubmit,
          onRegisterSubmit: onRegisterSubmit,
          onForgotPassword: onForgotPassword,
          onForgotPasswordWithPortal: onForgotPasswordWithPortal,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Auth memulai di tab Masuk dengan pemilih peran Admin & Pelanggan',
      (WidgetTester tester) async {
    await pumpAuth(tester);

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text(adminLoginSubtitle).hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('auth_portal_admin')), findsOneWidget);
    expect(find.byKey(const Key('auth_portal_customer')), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.text(registerSubtitle).hitTestable(), findsNothing);
  });

  testWidgets('Pemilih peran Pelanggan meneruskan AuthPortal.customer saat Masuk',
      (WidgetTester tester) async {
    LoginFormData? submitted;
    await pumpAuth(
      tester,
      onLoginSubmit: (LoginFormData data) => submitted = data,
    );

    await tester.tap(find.byKey(const Key('auth_portal_customer')));
    await tester.pump();

    expect(find.text(customerLoginSubtitle).hitTestable(), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).hitTestable().at(0),
      'budi@contoh.com',
    );
    await tester.enterText(
      find.byType(TextFormField).hitTestable().at(1),
      'rahasia123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(submitted, isNotNull);
    expect(submitted!.portal, AuthPortal.customer);
    expect(submitted!.email, 'budi@contoh.com');
  });

  testWidgets('Tab Daftar menggeser ke formulir pendaftaran Pelanggan', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    await tester.tap(find.text('Daftar').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text(registerSubtitle).hitTestable(), findsOneWidget);
    expect(
      find.text('Pendaftaran khusus akun Pelanggan.').hitTestable(),
      findsOneWidget,
    );
    expect(find.text(adminLoginSubtitle).hitTestable(), findsNothing);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('Tab Masuk menggeser kembali ke formulir masuk', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester, initialTab: AuthTab.register);

    expect(find.text(registerSubtitle).hitTestable(), findsOneWidget);

    await tester.tap(find.text('Masuk').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text(adminLoginSubtitle).hitTestable(), findsOneWidget);
    expect(find.text(registerSubtitle).hitTestable(), findsNothing);
  });

  testWidgets('Sapuan horizontal berpindah tab dan mempertahankan isian', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    await tester.enterText(
      find.byType(TextFormField).hitTestable().first,
      'budi@contoh.com',
    );
    await tester.pump();

    await tester.dragFrom(const Offset(215, 150), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text(registerSubtitle).hitTestable(), findsOneWidget);

    await tester.dragFrom(const Offset(215, 150), const Offset(350, 0));
    await tester.pumpAndSettle();
    expect(find.text(adminLoginSubtitle).hitTestable(), findsOneWidget);
    expect(find.text('budi@contoh.com').hitTestable(), findsOneWidget);
  });

  testWidgets('Tautan Lupa password meneruskan peran terpilih', (
    WidgetTester tester,
  ) async {
    AuthPortal? forgotPortal;
    await pumpAuth(
      tester,
      onForgotPasswordWithPortal: (AuthPortal portal) => forgotPortal = portal,
    );

    await tester.tap(find.byKey(const Key('auth_portal_customer')));
    await tester.pump();

    await tester.tap(find.text('Lupa password?'));
    await tester.pump();

    expect(forgotPortal, AuthPortal.customer);
  });
}
