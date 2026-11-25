// Widget test: layar profil, akun, pengaturan, password, notifikasi, bantuan.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/data/datasources/mock/help_mock_datasource.dart';
import 'package:soju_fe/data/datasources/mock/profile_mock_datasource.dart';
import 'package:soju_fe/data/repositories/help_repository_impl.dart';
import 'package:soju_fe/data/repositories/profile_repository_impl.dart';
import 'package:soju_fe/domain/usecases/help_usecases.dart';
import 'package:soju_fe/domain/usecases/profile_usecases.dart';
import 'package:soju_fe/presentation/providers/profile/change_password_controller.dart';
import 'package:soju_fe/presentation/providers/profile/help_detail_controller.dart';
import 'package:soju_fe/presentation/providers/profile/help_topics_controller.dart';
import 'package:soju_fe/presentation/providers/profile/notification_preferences_controller.dart';
import 'package:soju_fe/presentation/providers/profile/profile_controller.dart';
import 'package:soju_fe/presentation/screens/profile/change_password_screen.dart';
import 'package:soju_fe/presentation/screens/profile/help_detail_screen.dart';
import 'package:soju_fe/presentation/screens/profile/help_topics_screen.dart';
import 'package:soju_fe/presentation/screens/profile/notification_preferences_screen.dart';
import 'package:soju_fe/presentation/screens/profile/profile_account_screen.dart';
import 'package:soju_fe/presentation/screens/profile/profile_screen.dart';
import 'package:soju_fe/presentation/screens/profile/profile_settings_screen.dart';

ProfileController _profileController(ProfileMockDataSource dataSource) {
  final ProfileRepositoryImpl repository = ProfileRepositoryImpl(dataSource);
  return ProfileController(
    getProfile: GetProfile(repository),
    updateProfile: UpdateProfile(repository),
    updateProfilePhoto: UpdateProfilePhoto(repository),
  );
}

Finder _textFormFieldInside(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextFormField),
  );
}

Future<void> _pumpPhoneSize(
  WidgetTester tester,
  Widget child,
) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Profil menampilkan menu dan meneruskan aksi navigasi', (
    WidgetTester tester,
  ) async {
    final ProfileMockDataSource dataSource = ProfileMockDataSource();
    int account = 0;
    int settings = 0;
    int help = 0;

    await _pumpPhoneSize(
      tester,
      ProfileScreen(
        controllerFactory: () => _profileController(dataSource),
        onAccount: () async {
          account++;
        },
        onSettings: () => settings++,
        onHelp: () => help++,
      ),
    );

    expect(find.byKey(const Key('profile_screen')), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Adittia'), findsOneWidget);
    expect(find.text('adittia@sojucorp.com'), findsOneWidget);
    expect(find.text('Akun Saya'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Pusat Bantuan'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_account_menu')));
    await tester.pump();
    expect(account, 1);

    await tester.tap(find.byKey(const Key('profile_settings_menu')));
    await tester.pump();
    expect(settings, 1);

    await tester.tap(find.byKey(const Key('profile_help_menu')));
    await tester.pump();
    expect(help, 1);
  });

  testWidgets('Akun Saya memvalidasi email dan menyimpan perubahan', (
    WidgetTester tester,
  ) async {
    final ProfileMockDataSource dataSource = ProfileMockDataSource();

    await _pumpPhoneSize(
      tester,
      ProfileAccountScreen(
        controllerFactory: () => _profileController(dataSource),
      ),
    );

    expect(find.byKey(const Key('profile_account_screen')), findsOneWidget);
    expect(find.text('Akun Saya'), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('No Telepon'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('profile_email_field')),
      'bukan-email',
    );
    await tester.ensureVisible(find.byKey(const Key('profile_save_button')));
    await tester.tap(find.byKey(const Key('profile_save_button')));
    await tester.pump();

    expect(find.text('Format email tidak valid.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('profile_email_field')),
      'baru@sojucorp.com',
    );
    await tester.ensureVisible(find.byKey(const Key('profile_save_button')));
    await tester.tap(find.byKey(const Key('profile_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Profil berhasil disimpan.'), findsOneWidget);
  });

  testWidgets('Akun Saya membuka sheet foto dan memakai foto contoh', (
    WidgetTester tester,
  ) async {
    final ProfileMockDataSource dataSource = ProfileMockDataSource();

    await _pumpPhoneSize(
      tester,
      ProfileAccountScreen(
        controllerFactory: () => _profileController(dataSource),
      ),
    );

    final Finder avatar = find.byKey(const Key('profile_avatar_edit'));
    final Rect avatarRect = tester.getRect(avatar);
    await tester.tapAt(
      Offset(avatarRect.right - 12, avatarRect.bottom - 12),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_photo_sheet')), findsOneWidget);
    expect(find.text('Gunakan Foto Contoh'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_photo_use_sample')));
    await tester.pumpAndSettle();

    expect(find.text('Foto profil diperbarui.'), findsOneWidget);
  });

  testWidgets('Pengaturan membuka aksi dan konfirmasi keluar', (
    WidgetTester tester,
  ) async {
    int password = 0;
    int notifications = 0;
    int terms = 0;
    int logout = 0;

    await _pumpPhoneSize(
      tester,
      ProfileSettingsScreen(
        onChangePassword: () => password++,
        onNotifications: () => notifications++,
        onTerms: () => terms++,
        onLogout: () => logout++,
      ),
    );

    expect(find.byKey(const Key('profile_settings_screen')), findsOneWidget);
    expect(find.text('Ganti Password'), findsOneWidget);
    expect(find.text('Pemberitahuan'), findsOneWidget);
    expect(find.text('Syarat & Ketentuan'), findsOneWidget);
    expect(find.text('Buku Kita v1.1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_change_password')));
    await tester.pump();
    expect(password, 1);

    await tester.tap(find.byKey(const Key('profile_notifications')));
    await tester.pump();
    expect(notifications, 1);

    await tester.tap(find.byKey(const Key('profile_terms')));
    await tester.pump();
    expect(terms, 1);

    await tester.tap(find.byKey(const Key('profile_logout_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_logout_cancel')), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_logout_cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_logout_cancel')), findsNothing);
    expect(logout, 0);

    await tester.tap(find.byKey(const Key('profile_logout_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_logout_confirm')));
    await tester.pumpAndSettle();
    expect(logout, 1);
  });

  testWidgets('Ganti Password memvalidasi lalu menampilkan sukses', (
    WidgetTester tester,
  ) async {
    final ProfileMockDataSource dataSource = ProfileMockDataSource();

    await _pumpPhoneSize(
      tester,
      ChangePasswordScreen(
        controllerFactory: () => ChangePasswordController(
          changePassword: ChangePassword(ProfileRepositoryImpl(dataSource)),
        ),
      ),
    );

    expect(find.byKey(const Key('change_password_screen')), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('change_password_submit')),
    );
    await tester.tap(find.byKey(const Key('change_password_submit')));
    await tester.pump();

    expect(find.text('Password saat ini wajib diisi.'), findsOneWidget);
    expect(find.text('Password baru wajib diisi.'), findsOneWidget);
    expect(find.text('Konfirmasi password wajib diisi.'), findsOneWidget);

    await tester.enterText(
      _textFormFieldInside(const Key('change_password_current')),
      'password-lama',
    );
    await tester.enterText(
      _textFormFieldInside(const Key('change_password_new')),
      'password-baru',
    );
    await tester.enterText(
      _textFormFieldInside(const Key('change_password_confirm')),
      'password-baru',
    );
    await tester.ensureVisible(
      find.byKey(const Key('change_password_submit')),
    );
    await tester.tap(find.byKey(const Key('change_password_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('change_password_success')), findsOneWidget);
    expect(find.text('Password berhasil diperbarui'), findsOneWidget);
  });

  testWidgets('Notifikasi memuat toggle dan menyimpan preferensi', (
    WidgetTester tester,
  ) async {
    final ProfileMockDataSource dataSource = ProfileMockDataSource();
    final ProfileRepositoryImpl repository = ProfileRepositoryImpl(dataSource);

    await _pumpPhoneSize(
      tester,
      NotificationPreferencesScreen(
        controllerFactory: () => NotificationPreferencesController(
          getPreferences: GetNotificationPreferences(repository),
          updatePreferences: UpdateNotificationPreferences(repository),
        ),
      ),
    );

    expect(
      find.byKey(const Key('notification_preferences_screen')),
      findsOneWidget,
    );
    expect(find.text('Stok Menipis'), findsOneWidget);
    expect(find.text('Selisih Kas'), findsOneWidget);
    expect(find.text('Transaksi Harian'), findsOneWidget);

    Switch stock = tester.widget<Switch>(
      find.byKey(const Key('notification_stock_low')),
    );
    Switch cash = tester.widget<Switch>(
      find.byKey(const Key('notification_cash_difference')),
    );
    expect(stock.value, isTrue);
    expect(cash.value, isFalse);

    await tester.tap(find.byKey(const Key('notification_cash_difference')));
    await tester.pump();

    cash = tester.widget<Switch>(
      find.byKey(const Key('notification_cash_difference')),
    );
    expect(cash.value, isTrue);

    await tester.ensureVisible(
      find.byKey(const Key('notification_save_button')),
    );
    await tester.tap(find.byKey(const Key('notification_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Preferensi notifikasi disimpan.'), findsOneWidget);
  });

  testWidgets('Topik menampilkan kartu, mencari, dan membuka artikel', (
    WidgetTester tester,
  ) async {
    String? openedId;

    await _pumpPhoneSize(
      tester,
      HelpTopicsScreen(
        onArticleTap: (String id) => openedId = id,
        controllerFactory: () => HelpTopicsController(
          getTopics: const GetHelpTopics(
            HelpRepositoryImpl(HelpMockDataSource()),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('help_topics_screen')), findsOneWidget);
    expect(find.text('Topik'), findsOneWidget);
    expect(
      find.byKey(const Key('help_featured_topic_topik-transaksi')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('help_article_topik-order')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('help_see_all')), findsOneWidget);

    await tester.tap(find.byKey(const Key('help_see_all')));
    await tester.pump();
    expect(find.text('Ringkas'), findsOneWidget);
    expect(find.byKey(const Key('help_article_topik-stok')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('help_search_field')),
      'hutang',
    );
    await tester.pump();

    expect(find.byKey(const Key('help_see_all')), findsNothing);
    expect(
      find.byKey(const Key('help_article_topik-hutang-piutang')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('help_article_topik-order')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const Key('help_article_topik-hutang-piutang')),
    );
    await tester.pump();
    expect(openedId, 'topik-hutang-piutang');
  });

  testWidgets('Detail Topik menampilkan artikel dan umpan balik', (
    WidgetTester tester,
  ) async {
    await _pumpPhoneSize(
      tester,
      HelpDetailScreen(
        controllerFactory: () => HelpDetailController(
          getArticle: const GetHelpArticle(
            HelpRepositoryImpl(HelpMockDataSource()),
          ),
          articleId: 'topik-transaksi',
        ),
      ),
    );

    expect(find.byKey(const Key('help_detail_screen')), findsOneWidget);
    expect(find.text('Topik Detail'), findsOneWidget);
    expect(
      find.textContaining('Bagaimana cara mencatat dan menyesuaikan'),
      findsOneWidget,
    );
    expect(find.text('Ya'), findsOneWidget);
    expect(find.text('Tidak'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('help_feedback_yes')));
    await tester.tap(find.byKey(const Key('help_feedback_yes')));
    await tester.pump();

    expect(find.byKey(const Key('help_feedback_thanks')), findsOneWidget);
    expect(find.text('Terima kasih atas masukan Anda.'), findsOneWidget);
  });
}
