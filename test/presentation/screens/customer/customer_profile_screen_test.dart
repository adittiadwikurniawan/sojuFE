// test/presentation/screens/customer/customer_profile_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';
import 'package:soju_fe/domain/entities/customer_profile_entity.dart';
import 'package:soju_fe/domain/repositories/customer_profile_repository.dart';
import 'package:soju_fe/domain/usecases/customer_profile_usecases.dart';
import 'package:soju_fe/presentation/providers/customer/customer_profile_controller.dart';
import 'package:soju_fe/presentation/screens/customer/customer_profile_screen.dart';

class _FakeProfileRepo implements CustomerProfileRepository {
  CustomerProfile currentProfile = CustomerProfile(
    id: 1,
    name: 'Pelanggan Setia',
    email: 'pelanggan@sojucorp.com',
    phone: '081234567890',
    address: 'Jl. Senopati No. 45',
    promotionAllowed: true,
    emailVerifiedAt: DateTime(2026, 11, 20),
  );

  CustomerProfileUpdateDraft? lastUpdateDraft;
  CustomerChangePasswordDraft? lastPasswordDraft;

  @override
  Future<Result<CustomerProfile>> fetchProfile() async =>
      Result<CustomerProfile>.success(currentProfile);

  @override
  Future<Result<CustomerProfile>> updateProfile(
    CustomerProfileUpdateDraft draft,
  ) async {
    lastUpdateDraft = draft;
    currentProfile = currentProfile.copyWith(
      name: draft.name,
      email: draft.email,
      phone: draft.phone,
      address: draft.address,
      promotionAllowed: draft.promotionAllowed,
    );
    return Result<CustomerProfile>.success(currentProfile);
  }

  @override
  Future<Result<String>> changePassword(
    CustomerChangePasswordDraft draft,
  ) async {
    lastPasswordDraft = draft;
    return Result<String>.success('Password berhasil diperbarui');
  }
}

void main() {
  late _FakeProfileRepo repository;
  late CustomerProfileController controller;

  const AuthUser testUser = AuthUser(
    id: 1,
    name: 'Pelanggan Setia',
    email: 'pelanggan@sojucorp.com',
    role: UserRole.customer,
    phone: '081234567890',
    address: 'Jl. Senopati No. 45',
  );

  setUp(() {
    repository = _FakeProfileRepo();
    controller = CustomerProfileController(
      getProfile: GetCustomerProfile(repository),
      updateProfile: UpdateCustomerProfile(repository),
      changePassword: ChangeCustomerPassword(repository),
      initialProfile: repository.currentProfile,
    );
  });

  tearDown(() => controller.dispose());

  testWidgets('renders customer profile information and verification badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerProfileScreen(
          controller: controller,
          user: testUser,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Akun Pelanggan'), findsOneWidget);
    expect(find.text('Pelanggan Setia'), findsWidgets);
    expect(find.text('pelanggan@sojucorp.com'), findsWidgets);
    expect(find.text('Terverifikasi'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
    expect(find.text('Jl. Senopati No. 45'), findsOneWidget);
    expect(find.text('Diizinkan (Aktif)'), findsOneWidget);
  });

  testWidgets('opens edit profile sheet and saves profile changes', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerProfileScreen(
          controller: controller,
          user: testUser,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Ubah Profil"
    await tester.tap(find.byKey(const Key('customer_edit_profile_button')));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Profil Akun'), findsOneWidget);

    // Edit Name
    final Finder nameField = find.byKey(const Key('customer_profile_name_input'));
    await tester.enterText(nameField, 'Pelanggan Setia Update');

    // Tap save
    await tester.tap(find.byKey(const Key('customer_save_profile_button')));
    await tester.pumpAndSettle();

    expect(repository.lastUpdateDraft?.name, 'Pelanggan Setia Update');
    expect(find.text('Profil berhasil diperbarui!'), findsOneWidget);
    expect(find.text('Pelanggan Setia Update'), findsWidgets);
  });

  testWidgets('opens change password sheet and submits new password', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerProfileScreen(
          controller: controller,
          user: testUser,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Ganti Password"
    await tester.tap(find.byKey(const Key('customer_change_password_button')));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Password Akun'), findsOneWidget);

    // Enter passwords
    await tester.enterText(
      find.byKey(const Key('customer_old_password_input')),
      'oldPassword123',
    );
    await tester.enterText(
      find.byKey(const Key('customer_new_password_input')),
      'newPassword123',
    );
    await tester.enterText(
      find.byKey(const Key('customer_confirm_password_input')),
      'newPassword123',
    );

    // Submit
    await tester.tap(find.byKey(const Key('customer_submit_password_button')));
    await tester.pumpAndSettle();

    expect(repository.lastPasswordDraft?.currentPassword, 'oldPassword123');
    expect(repository.lastPasswordDraft?.newPassword, 'newPassword123');
    expect(find.text('Password berhasil diperbarui!'), findsOneWidget);
  });

  testWidgets('logout button invokes onLogout callback', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    bool logoutCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerProfileScreen(
          controller: controller,
          user: testUser,
          onLogout: () => logoutCalled = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder logoutBtn = find.byKey(const Key('customer_logout_button'));
    await tester.ensureVisible(logoutBtn);
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    expect(logoutCalled, isTrue);
  });
}
