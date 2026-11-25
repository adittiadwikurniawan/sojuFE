// Widget test: layar Lupa Password.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/app/routes/app_routes.dart';
import 'package:soju_fe/presentation/screens/auth/forgot_password_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    Future<void> Function(String email)? onSendResetLink,
    VoidCallback? onCancel,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ForgotPasswordScreen(
          onSendResetLink: onSendResetLink,
          onCancel: onCancel,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> submitEmail(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextFormField), email);
    await tester.tap(find.widgetWithText(FilledButton, 'Lanjutkan'));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('Lupa Password menampilkan judul, isian email, dan aksi', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Lupa Password'), findsOneWidget);
    expect(
      find.text('Masukkan alamat email yang terdaftar pada akun Anda'),
      findsOneWidget,
    );
    expect(find.text('Masukkan Email Kamu'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Lanjutkan'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Batalkan'), findsOneWidget);
  });

  testWidgets('Lupa Password memvalidasi email kosong dan format salah', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Lanjutkan'));
    await tester.pump();
    expect(find.text('Email wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'budi');
    await tester.tap(find.widgetWithText(FilledButton, 'Lanjutkan'));
    await tester.pump();
    expect(find.text('Format email belum benar'), findsOneWidget);
  });

  testWidgets('Lupa Password menampilkan konfirmasi setelah email dikirim', (
    WidgetTester tester,
  ) async {
    String? requested;
    await pumpScreen(
      tester,
      onSendResetLink: (String email) async => requested = email,
    );

    await submitEmail(tester, 'budi@contoh.com');

    expect(requested, 'budi@contoh.com');
    expect(find.text('Cek Email Kamu'), findsOneWidget);
    expect(
      find.textContaining('budi@contoh.com', findRichText: true),
      findsOneWidget,
    );
    expect(
        find.widgetWithText(FilledButton, 'Kembali ke Masuk'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Kirim ulang tautan'),
        findsOneWidget);
    expect(find.text('Gunakan email lain'), findsOneWidget);
  });

  testWidgets('Lupa Password menampilkan galat bila pengiriman gagal', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      onSendResetLink: (String email) async => throw Exception('jaringan mati'),
    );

    await submitEmail(tester, 'budi@contoh.com');

    expect(find.text('Cek Email Kamu'), findsNothing);
    expect(
      find.text('Tautan gagal dikirim. Periksa koneksi lalu coba lagi.'),
      findsOneWidget,
    );
  });

  testWidgets('Batalkan memicu onCancel', (WidgetTester tester) async {
    bool cancelled = false;
    await pumpScreen(tester, onCancel: () => cancelled = true);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Batalkan'));
    await tester.pump();

    expect(cancelled, isTrue);
  });

  testWidgets('Kirim ulang memanggil pengiriman tanpa mengubah email', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await pumpScreen(
      tester,
      onSendResetLink: (String email) async => calls += 1,
    );

    await submitEmail(tester, 'budi@contoh.com');
    expect(calls, 1);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Kirim ulang tautan'));
    await tester.pump();
    await tester.pump();

    expect(calls, 2);
    expect(find.text('Tautan reset sudah dikirim ulang.'), findsOneWidget);
  });

  testWidgets('Lupa password dari Masuk kembali ke Masuk lewat Batalkan', (
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

    await tester.tap(find.text('Lupa password?'));
    await tester.pumpAndSettle();

    expect(find.text('Lupa Password'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Batalkan'));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang di Buku Kita'), findsOneWidget);
  });
}
