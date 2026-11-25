import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/themes/app_theme.dart';
import 'package:soju_fe/data/datasources/mock/admin_users_mock_datasource.dart';
import 'package:soju_fe/data/repositories/admin_users_repository_impl.dart';
import 'package:soju_fe/domain/entities/auth_session_entity.dart';
import 'package:soju_fe/domain/usecases/admin_users_usecases.dart';
import 'package:soju_fe/presentation/providers/admin_users/admin_users_controller.dart';
import 'package:soju_fe/presentation/screens/admin_users/admin_users_screen.dart';
import 'package:soju_fe/presentation/widgets/admin_drawer.dart';

AdminUsersController _buildMockController() {
  final AdminUsersRepositoryImpl repo = AdminUsersRepositoryImpl(
    AdminUsersMockDataSource(),
  );
  return AdminUsersController(
    getAdminUsers: GetAdminUsers(repo),
    createAdminUser: CreateAdminUser(repo),
    updateAdminUser: UpdateAdminUser(repo),
    updateAdminUserStatus: UpdateAdminUserStatus(repo),
    softDisableAdminUser: SoftDisableAdminUser(repo),
    triggerPasswordReset: TriggerAdminUserPasswordReset(repo),
  );
}

void main() {
  const AuthUser superAdminUser = AuthUser(
    id: 1,
    name: 'Dea Super Admin',
    email: 'superadmin@sojucorp.com',
    role: UserRole.superAdmin,
  );

  const AuthUser regularAdminUser = AuthUser(
    id: 2,
    name: 'Budi Operasional',
    email: 'admin@sojucorp.com',
    role: UserRole.admin,
  );

  group('AdminUsersScreen & SUPER_ADMIN gating', () {
    testWidgets('ADMIN role cannot access AdminUsersScreen and sees Akses Ditolak', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdminUsersScreen(
            currentUser: regularAdminUser,
            controllerFactory: _buildMockController,
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_users_access_denied')), findsOneWidget);
      expect(find.text('Akses Ditolak'), findsOneWidget);
      expect(find.byKey(const Key('admin_users_add_button')), findsNothing);
      expect(find.byKey(const Key('admin_users_list')), findsNothing);
    });

    testWidgets('AdminDrawer hides Kelola Pengguna for ADMIN and shows it for SUPER_ADMIN', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AdminDrawer(
              role: UserRole.admin,
              onSelectItem: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_drawer_audit')), findsOneWidget);
      expect(find.byKey(const Key('admin_drawer_users')), findsNothing);
      expect(find.text('Kelola Pengguna'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AdminDrawer(
              role: UserRole.superAdmin,
              onSelectItem: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_drawer_users')), findsOneWidget);
      expect(find.text('Kelola Pengguna'), findsOneWidget);
    });

    testWidgets('SUPER_ADMIN sees self-protection UI: self-disable and self-role-change disabled', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdminUsersScreen(
            currentUser: superAdminUser,
            controllerFactory: _buildMockController,
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Self badge & self-protection note visible on id=1.
      expect(find.byKey(const Key('admin_user_self_badge_1')), findsOneWidget);
      expect(
        find.byKey(const Key('admin_user_self_protection_note_1')),
        findsOneWidget,
      );

      // Self-disable button is disabled (onPressed == null).
      final OutlinedButton selfDisableBtn = tester.widget<OutlinedButton>(
        find.byKey(const Key('admin_user_toggle_1')),
      );
      expect(selfDisableBtn.onPressed, isNull);

      // Opening Edit dialog on self disables the role dropdown.
      await tester.ensureVisible(find.byKey(const Key('admin_user_edit_1')));
      await tester.tap(find.byKey(const Key('admin_user_edit_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_user_edit_dialog')), findsOneWidget);
      expect(find.byKey(const Key('edit_user_self_role_note')), findsOneWidget);
      final DropdownButtonFormField<dynamic> selfRoleField =
          tester.widget<DropdownButtonFormField<dynamic>>(
        find.byKey(const Key('edit_user_role_dropdown')),
      );
      expect(selfRoleField.onChanged, isNull);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Scroll to other active admin (id=2) and verify disable button IS enabled.
      await tester.drag(
        find.byKey(const Key('admin_users_list')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      final OutlinedButton otherDisableBtn = tester.widget<OutlinedButton>(
        find.byKey(const Key('admin_user_toggle_2')),
      );
      expect(otherDisableBtn.onPressed, isNotNull);
    });

    testWidgets('SUPER_ADMIN can soft-disable with confirmation dialog, trigger reset password, and create user', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdminUsersScreen(
            currentUser: superAdminUser,
            controllerFactory: _buildMockController,
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to user 2 and soft-disable with confirmation dialog.
      await tester.drag(
        find.byKey(const Key('admin_users_list')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('admin_user_toggle_2')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('admin_user_status_confirm_dialog')),
        findsOneWidget,
      );
      expect(find.text('Nonaktifkan Akun Admin?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm_toggle_user_status')));
      await tester.pumpAndSettle();

      expect(find.text('Akun admin berhasil dinonaktifkan'), findsOneWidget);

      // Trigger reset password on active user 1 with confirmation dialog.
      await tester.drag(
        find.byKey(const Key('admin_users_list')),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('admin_user_reset_1')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('admin_user_reset_confirm_dialog')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('confirm_reset_user_password')));
      await tester.pumpAndSettle();
      expect(
        find.text('Tautan reset password telah dikirim ke email admin.'),
        findsOneWidget,
      );

      // Create new admin user.
      await tester.tap(find.byKey(const Key('admin_users_add_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_user_create_dialog')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('create_user_name_field')),
        'Rina Operasional',
      );
      await tester.enterText(
        find.byKey(const Key('create_user_email_field')),
        'rina@sojucorp.com',
      );
      await tester.enterText(
        find.byKey(const Key('create_user_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('create_user_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Akun Admin berhasil dibuat'), findsOneWidget);
    });
  });
}
