// Widget test: layar Masuk (login).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/app/routes/app_routes.dart';
import 'package:soju_fe/presentation/screens/auth/login_screen.dart';
import 'package:soju_fe/presentation/screens/auth/models/login_form_data.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    ValueChanged<LoginFormData>? onSubmit,
    VoidCallback? onRegisterTap,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginScreen(onSubmit: onSubmit, onRegisterTap: onRegisterTap),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Masuk menampilkan header, medan isian, dan opsi masuk lain', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Selamat Datang di Buku Kita'), findsOneWidget);
    expect(find.text('Masuk'), findsNWidgets(2));
    expect(find.text('Daftar'), findsOneWidget);
    expect(find.text('Masukkan email kamu'), findsOneWidget);
    expect(find.text('Masukkan password'), findsOneWidget);
    expect(find.text('Lupa password?'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Masuk'), findsOneWidget);
    expect(find.text('atau'), findsOneWidget);
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
  });

  testWidgets('Masuk menampilkan galat saat isian kosong', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('Masuk meneruskan isian valid lewat onSubmit', (
    WidgetTester tester,
  ) async {
    LoginFormData? submitted;
    await pumpScreen(
      tester,
      onSubmit: (LoginFormData data) => submitted = data,
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'budi@contoh.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(submitted, isNotNull);
    expect(submitted!.email, 'budi@contoh.com');
    expect(submitted!.password, 'rahasia123');
  });

  testWidgets('Tab Daftar memicu onRegisterTap', (WidgetTester tester) async {
    bool registerTapped = false;
    await pumpScreen(tester, onRegisterTap: () => registerTapped = true);

    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(registerTapped, isTrue);
  });

  testWidgets('Masuk membuka beranda setelah isian valid', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: AppRouter.create(initialLocation: AppRoutes.login),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'budi@contoh.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Total Penghasilan'), findsOneWidget);
    expect(find.text('Aktivitas'), findsOneWidget);
  });
}
