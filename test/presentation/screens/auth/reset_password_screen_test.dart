// Widget test: layar Atur Ulang Password (reset password) lintas peran.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/app/routes/app_routes.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';
import 'package:soju_fe/presentation/screens/auth/models/reset_password_form_data.dart';
import 'package:soju_fe/presentation/screens/auth/reset_password_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    AuthPortal initialPortal = AuthPortal.admin,
    String initialToken = '',
    Future<void> Function(ResetPasswordFormData data)? onSubmit,
    VoidCallback? onCancel,
    VoidCallback? onBackToLogin,
    ValueChanged<AuthPortal>? onBackToLoginWithPortal,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ResetPasswordScreen(
          initialPortal: initialPortal,
          initialToken: initialToken,
          onSubmit: onSubmit,
          onCancel: onCancel,
          onBackToLogin: onBackToLogin,
          onBackToLoginWithPortal: onBackToLoginWithPortal,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('memvalidasi token kosong, password pendek, dan konfirmasi beda',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Atur Ulang Password'));
    await tester.pump();

    expect(find.text('Token reset password wajib diisi'), findsOneWidget);
    expect(find.text('Password baru wajib diisi'), findsOneWidget);
    expect(find.text('Konfirmasi password wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'tok-123');
    await tester.enterText(find.byType(TextFormField).at(1), 'pendek');
    await tester.enterText(find.byType(TextFormField).at(2), 'berbeda');
    await tester.tap(find.widgetWithText(FilledButton, 'Atur Ulang Password'));
    await tester.pump();

    expect(find.text('Password baru minimal 8 karakter'), findsOneWidget);
    expect(find.text('Konfirmasi password tidak sama'), findsOneWidget);
  });

  testWidgets('mengirim token dan password baru untuk peran Pelanggan maupun Admin',
      (WidgetTester tester) async {
    ResetPasswordFormData? submitted;
    AuthPortal? returnedPortal;

    await pumpScreen(
      tester,
      initialPortal: AuthPortal.admin,
      onSubmit: (ResetPasswordFormData data) async => submitted = data,
      onBackToLoginWithPortal: (AuthPortal portal) => returnedPortal = portal,
    );

    await tester.tap(find.byKey(const Key('auth_portal_customer')));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'token-reset-xyz');
    await tester.enterText(find.byType(TextFormField).at(1), 'sandiBaru123');
    await tester.enterText(find.byType(TextFormField).at(2), 'sandiBaru123');
    await tester.tap(find.widgetWithText(FilledButton, 'Atur Ulang Password'));
    await tester.pump();
    await tester.pump();

    expect(submitted, isNotNull);
    expect(submitted!.portal, AuthPortal.customer);
    expect(submitted!.token, 'token-reset-xyz');
    expect(submitted!.newPassword, 'sandiBaru123');

    expect(find.text('Password Berhasil Diubah'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk Sekarang'));
    await tester.pump();
    expect(returnedPortal, AuthPortal.customer);
  });

  testWidgets(
      'AppRouter meneruskan peran aktif dari ResetPasswordScreen kembali ke LoginScreen',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = AppRouter.create(
      initialLocation: '${AppRoutes.resetPassword}?peran=admin',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('auth_portal_customer')));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'token-reset-xyz');
    await tester.enterText(find.byType(TextFormField).at(1), 'sandiBaru123');
    await tester.enterText(find.byType(TextFormField).at(2), 'sandiBaru123');
    await tester.tap(find.widgetWithText(FilledButton, 'Atur Ulang Password'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk Sekarang'));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '${AppRoutes.login}?peran=customer');
    expect(
      find
          .text('Masuk sebagai pelanggan untuk memesan menu favoritmu.')
          .hitTestable(),
      findsOneWidget,
    );
  });
}
