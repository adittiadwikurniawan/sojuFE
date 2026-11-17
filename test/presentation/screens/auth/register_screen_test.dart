// Widget test: layar Daftar (register).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/app/routes/app_routes.dart';
import 'package:soju_fe/presentation/screens/auth/models/register_form_data.dart';
import 'package:soju_fe/presentation/screens/auth/register_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    ValueChanged<RegisterFormData>? onSubmit,
    VoidCallback? onLoginTap,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegisterScreen(onSubmit: onSubmit, onLoginTap: onLoginTap),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Daftar menampilkan header, empat medan isian, dan tombol', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Selamat Datang di Buku Kita'), findsOneWidget);
    expect(find.text('Daftar'), findsWidgets);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Masukkan Nama Kamu'), findsOneWidget);
    expect(find.text('Masukkan Email Kamu'), findsOneWidget);
    expect(find.text('Masukkan password'), findsOneWidget);
    expect(find.text('Konfirmasi password'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Daftar'), findsOneWidget);
  });

  testWidgets('Daftar menampilkan galat saat isian kosong', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pump();

    expect(find.text('Nama minimal 2 karakter'), findsOneWidget);
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    expect(
      find.text('Setujui syarat & ketentuan dulu ya'),
      findsOneWidget,
    );
  });

  testWidgets('Daftar meneruskan isian valid lewat onSubmit', (
    WidgetTester tester,
  ) async {
    RegisterFormData? submitted;
    await pumpScreen(
      tester,
      onSubmit: (RegisterFormData data) => submitted = data,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Budi');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'budi@contoh.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'rahasia123');
    await tester.enterText(find.byType(TextFormField).at(3), 'rahasia123');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pump();

    expect(submitted, isNotNull);
    expect(submitted!.name, 'Budi');
    expect(submitted!.email, 'budi@contoh.com');
    expect(submitted!.acceptedTerms, isTrue);
  });

  testWidgets('Tab Masuk memicu onLoginTap', (WidgetTester tester) async {
    bool loginTapped = false;
    await pumpScreen(tester, onLoginTap: () => loginTapped = true);

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(loginTapped, isTrue);
  });

  testWidgets('Daftar membuka beranda setelah isian valid', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: AppRouter.create(
          initialLocation: AppRoutes.register,
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Budi');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'budi@contoh.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'rahasia123');
    await tester.enterText(find.byType(TextFormField).at(3), 'rahasia123');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Total Penghasilan'), findsOneWidget);
    expect(find.text('Aktivitas'), findsOneWidget);
  });
}
