// Unit test: controller profil, password, notifikasi, dan bantuan.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/data/datasources/mock/help_mock_datasource.dart';
import 'package:soju_fe/data/datasources/mock/profile_mock_datasource.dart';
import 'package:soju_fe/data/repositories/help_repository_impl.dart';
import 'package:soju_fe/data/repositories/profile_repository_impl.dart';
import 'package:soju_fe/domain/entities/profile_entity.dart';
import 'package:soju_fe/domain/usecases/help_usecases.dart';
import 'package:soju_fe/domain/usecases/profile_usecases.dart';
import 'package:soju_fe/presentation/providers/profile/change_password_controller.dart';
import 'package:soju_fe/presentation/providers/profile/help_detail_controller.dart';
import 'package:soju_fe/presentation/providers/profile/help_topics_controller.dart';
import 'package:soju_fe/presentation/providers/profile/notification_preferences_controller.dart';
import 'package:soju_fe/presentation/providers/profile/profile_controller.dart';

ProfileController _profileController(ProfileMockDataSource dataSource) {
  final ProfileRepositoryImpl repository = ProfileRepositoryImpl(dataSource);
  return ProfileController(
    getProfile: GetProfile(repository),
    updateProfile: UpdateProfile(repository),
    updateProfilePhoto: UpdateProfilePhoto(repository),
  );
}

void main() {
  group('ProfileController', () {
    test('memuat profil dan menyimpan perubahan data', () async {
      final ProfileMockDataSource dataSource = ProfileMockDataSource();
      final ProfileController controller = _profileController(dataSource);
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.state.profile?.name, 'Adittia');
      expect(controller.state.profile?.email, 'adittia@sojucorp.com');
      expect(controller.state.profile?.avatarAsset, isNotNull);
      expect(controller.state.status, ProfileStatus.ready);

      final bool saved = await controller.save(
        const ProfileUpdateDraft(
          name: 'Soju Corp',
          email: 'sojucorp@gmail.com',
          phone: '0812 0000 1111',
        ),
      );

      expect(saved, isTrue);
      expect(controller.state.profile?.name, 'Soju Corp');
      expect(controller.state.profile?.email, 'sojucorp@gmail.com');
      expect(controller.state.profile?.phone, '0812 0000 1111');
      expect(controller.state.status, ProfileStatus.ready);
    });

    test('mengganti dan menghapus foto profil', () async {
      final ProfileMockDataSource dataSource = ProfileMockDataSource();
      final ProfileController controller = _profileController(dataSource);
      addTearDown(controller.dispose);

      await controller.load();

      final bool changed = await controller.updatePhoto(
        const ProfilePhotoDraft(assetPath: 'assets/images/avatar_profil.png'),
      );
      expect(changed, isTrue);
      expect(controller.state.profile?.avatarAsset, isNotNull);

      final bool removed = await controller.updatePhoto(
        const ProfilePhotoDraft(remove: true),
      );
      expect(removed, isTrue);
      expect(controller.state.profile?.avatarAsset, isNull);
      expect(controller.state.profile?.avatarUrl, isNull);
      expect(controller.state.isUploadingPhoto, isFalse);
    });
  });

  group('ChangePasswordController', () {
    test('menolak isian kosong dan password baru yang terlalu pendek',
        () async {
      final ProfileMockDataSource dataSource = ProfileMockDataSource();
      final ChangePasswordController controller = ChangePasswordController(
        changePassword: ChangePassword(ProfileRepositoryImpl(dataSource)),
      );
      addTearDown(controller.dispose);

      expect(await controller.submit(), isFalse);
      expect(controller.state.currentError, isNotNull);
      expect(controller.state.newError, isNotNull);
      expect(controller.state.confirmError, isNotNull);

      controller.updateCurrentPassword('password-lama');
      controller.updateNewPassword('pendek');
      controller.updateConfirmPassword('pendek');

      expect(await controller.submit(), isFalse);
      expect(controller.state.newError, 'Password baru minimal 8 karakter.');
    });

    test('menolak konfirmasi yang tidak cocok', () async {
      final ProfileMockDataSource dataSource = ProfileMockDataSource();
      final ChangePasswordController controller = ChangePasswordController(
        changePassword: ChangePassword(ProfileRepositoryImpl(dataSource)),
      );
      addTearDown(controller.dispose);

      controller.updateCurrentPassword('password-lama');
      controller.updateNewPassword('password-baru');
      controller.updateConfirmPassword('password-lain');

      expect(await controller.submit(), isFalse);
      expect(controller.state.confirmError, 'Konfirmasi password tidak cocok.');
    });

    test('mengirim password baru yang valid', () async {
      final ProfileMockDataSource dataSource = ProfileMockDataSource();
      final ChangePasswordController controller = ChangePasswordController(
        changePassword: ChangePassword(ProfileRepositoryImpl(dataSource)),
      );
      addTearDown(controller.dispose);

      controller.updateCurrentPassword('password-lama');
      controller.updateNewPassword('password-baru');
      controller.updateConfirmPassword('password-baru');

      expect(await controller.submit(), isTrue);
      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.successMessage, isNotNull);
    });
  });

  group('NotificationPreferencesController', () {
    test('memuat, mengubah, dan menyimpan preferensi', () async {
      final ProfileMockDataSource dataSource = ProfileMockDataSource();
      final ProfileRepositoryImpl repository = ProfileRepositoryImpl(
        dataSource,
      );
      final NotificationPreferencesController controller =
          NotificationPreferencesController(
        getPreferences: GetNotificationPreferences(repository),
        updatePreferences: UpdateNotificationPreferences(repository),
      );
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.state.saved?.stockLow, isTrue);
      expect(controller.state.saved?.cashDifference, isFalse);
      expect(controller.state.saved?.dailyTransaction, isFalse);

      controller.toggleCashDifference(true);
      controller.toggleDailyTransaction(true);
      expect(controller.state.hasChanges, isTrue);

      expect(await controller.save(), isTrue);
      expect(controller.state.saved?.cashDifference, isTrue);
      expect(controller.state.saved?.dailyTransaction, isTrue);
      expect(controller.state.hasChanges, isFalse);
    });
  });

  group('HelpTopicsController', () {
    test('memuat topik, membuka semua, dan mencari', () async {
      final HelpTopicsController controller = HelpTopicsController(
        getTopics: const GetHelpTopics(
          HelpRepositoryImpl(HelpMockDataSource()),
        ),
      );
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.state.topics.length, 6);
      expect(controller.featuredTopics.length, 2);
      expect(controller.visibleArticleTopics.length, 2);
      expect(controller.canShowAll, isTrue);

      controller.toggleShowAll();
      expect(controller.visibleArticleTopics.length, 4);

      controller.setQuery('hutang');
      expect(controller.filteredTopics.length, 1);
      expect(controller.filteredTopics.first.title, contains('hutang'));

      controller.setQuery('tidak-ada');
      expect(controller.hasResults, isFalse);
    });
  });

  group('HelpDetailController', () {
    test('memuat artikel dan menyimpan umpan balik', () async {
      final HelpDetailController controller = HelpDetailController(
        getArticle: const GetHelpArticle(
          HelpRepositoryImpl(HelpMockDataSource()),
        ),
        articleId: 'topik-transaksi',
      );
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.state.article?.title, contains('Buku Kita'));
      expect(controller.state.article?.paragraphs.length, 2);

      controller.submitFeedback(helpful: true);
      expect(controller.state.feedbackSubmitted, isTrue);
      expect(controller.state.feedbackHelpful, isTrue);
    });

    test('menampilkan galat untuk artikel yang tidak ada', () async {
      final HelpDetailController controller = HelpDetailController(
        getArticle: const GetHelpArticle(
          HelpRepositoryImpl(HelpMockDataSource()),
        ),
        articleId: 'tidak-ada',
      );
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.state.hasError, isTrue);
      expect(controller.state.errorMessage, contains('tidak ditemukan'));
    });
  });
}
