// test/presentation/providers/customer/customer_profile_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/customer_profile_entity.dart';
import 'package:soju_fe/domain/repositories/customer_profile_repository.dart';
import 'package:soju_fe/domain/usecases/customer_profile_usecases.dart';
import 'package:soju_fe/presentation/providers/customer/customer_profile_controller.dart';

class _FakeProfileRepo implements CustomerProfileRepository {
  Result<CustomerProfile>? profileResult;
  Result<CustomerProfile>? updateResult;
  Result<String>? passwordResult;
  CustomerProfileUpdateDraft? capturedUpdateDraft;
  CustomerChangePasswordDraft? capturedPasswordDraft;

  @override
  Future<Result<CustomerProfile>> fetchProfile() async {
    return profileResult ??
        Result<CustomerProfile>.success(
          const CustomerProfile(
            id: 1,
            name: 'Budi Santoso',
            email: 'budi@test.com',
            phone: '0812345678',
            address: 'Jl. Senopati No. 1',
            promotionAllowed: true,
          ),
        );
  }

  @override
  Future<Result<CustomerProfile>> updateProfile(
    CustomerProfileUpdateDraft draft,
  ) async {
    capturedUpdateDraft = draft;
    return updateResult ??
        Result<CustomerProfile>.success(
          CustomerProfile(
            id: 1,
            name: draft.name,
            email: draft.email,
            phone: draft.phone,
            address: draft.address,
            promotionAllowed: draft.promotionAllowed ?? true,
          ),
        );
  }

  @override
  Future<Result<String>> changePassword(
    CustomerChangePasswordDraft draft,
  ) async {
    capturedPasswordDraft = draft;
    return passwordResult ??
        Result<String>.success('Password berhasil diperbarui');
  }
}

void main() {
  late _FakeProfileRepo repo;
  late CustomerProfileController controller;

  setUp(() {
    repo = _FakeProfileRepo();
    controller = CustomerProfileController(
      getProfile: GetCustomerProfile(repo),
      updateProfile: UpdateCustomerProfile(repo),
      changePassword: ChangeCustomerPassword(repo),
    );
  });

  tearDown(() => controller.dispose());

  group('CustomerProfileController.loadProfile', () {
    test('loads profile successfully and populates state', () async {
      await controller.loadProfile();

      expect(controller.isLoading, isFalse);
      expect(controller.profile?.name, 'Budi Santoso');
      expect(controller.profile?.email, 'budi@test.com');
      expect(controller.errorMessage, isNull);
    });

    test('sets errorMessage when loading profile fails', () async {
      repo.profileResult = Result<CustomerProfile>.failure(
        const ServerFailure(statusCode: 500, message: 'Server error profil'),
      );

      await controller.loadProfile();

      expect(controller.isLoading, isFalse);
      expect(controller.profile, isNull);
      expect(controller.errorMessage, 'Server error profil');
    });
  });

  group('CustomerProfileController.saveProfile', () {
    test('validates fields and returns false with error on invalid input', () async {
      // Empty name
      bool ok = await controller.saveProfile(
        name: '',
        email: 'budi@test.com',
        phone: '123',
        address: 'Jl. A',
      );
      expect(ok, isFalse);
      expect(controller.errorMessage, 'Nama lengkap wajib diisi');

      // Invalid email
      ok = await controller.saveProfile(
        name: 'Budi',
        email: 'invalid-email',
        phone: '123',
        address: 'Jl. A',
      );
      expect(ok, isFalse);
      expect(controller.errorMessage, 'Alamat email tidak valid');

      // Empty phone
      ok = await controller.saveProfile(
        name: 'Budi',
        email: 'budi@test.com',
        phone: '',
        address: 'Jl. A',
      );
      expect(ok, isFalse);
      expect(controller.errorMessage, 'Nomor telepon wajib diisi');

      // Empty address
      ok = await controller.saveProfile(
        name: 'Budi',
        email: 'budi@test.com',
        phone: '123',
        address: '',
      );
      expect(ok, isFalse);
      expect(controller.errorMessage, 'Alamat pengiriman wajib diisi');
    });

    test('updates profile successfully on valid input', () async {
      final bool ok = await controller.saveProfile(
        name: 'Budi Baru',
        email: 'budi.baru@test.com',
        phone: '0899999999',
        address: 'Jl. Sudirman Baru',
        promotionAllowed: false,
      );

      expect(ok, isTrue);
      expect(controller.profile?.name, 'Budi Baru');
      expect(controller.profile?.email, 'budi.baru@test.com');
      expect(controller.successMessage, 'Profil berhasil diperbarui');
      expect(repo.capturedUpdateDraft?.promotionAllowed, isFalse);
    });

    test('handles repository update failure', () async {
      repo.updateResult = Result<CustomerProfile>.failure(
        const ServerFailure(statusCode: 409, message: 'Email sudah terdaftar'),
      );

      final bool ok = await controller.saveProfile(
        name: 'Budi',
        email: 'budi@test.com',
        phone: '081',
        address: 'Jl. A',
      );

      expect(ok, isFalse);
      expect(controller.errorMessage, 'Email sudah terdaftar');
    });
  });

  group('CustomerProfileController.updatePassword', () {
    test('validates password inputs client-side', () async {
      // Empty current password
      bool ok = await controller.updatePassword(
        currentPassword: '',
        newPassword: 'passwordBaru123',
        confirmPassword: 'passwordBaru123',
      );
      expect(ok, isFalse);
      expect(controller.passwordError, 'Password saat ini wajib diisi');

      // Short new password
      ok = await controller.updatePassword(
        currentPassword: 'currentPassword123',
        newPassword: 'short',
        confirmPassword: 'short',
      );
      expect(ok, isFalse);
      expect(controller.passwordError, 'Password baru minimal 8 karakter');

      // Mismatched confirm password
      ok = await controller.updatePassword(
        currentPassword: 'currentPassword123',
        newPassword: 'newPassword123',
        confirmPassword: 'differentPassword123',
      );
      expect(ok, isFalse);
      expect(controller.passwordError, 'Konfirmasi password baru tidak cocok');
    });

    test('successfully updates password and stores success message', () async {
      final bool ok = await controller.updatePassword(
        currentPassword: 'currentPassword123',
        newPassword: 'newPassword123',
        confirmPassword: 'newPassword123',
      );

      expect(ok, isTrue);
      expect(controller.passwordSuccess, 'Password berhasil diperbarui');
      expect(repo.capturedPasswordDraft?.currentPassword, 'currentPassword123');
      expect(repo.capturedPasswordDraft?.newPassword, 'newPassword123');
    });

    test('handles wrong current password failure from backend', () async {
      repo.passwordResult = Result<String>.failure(
        const ServerFailure(statusCode: 400, message: 'Password lama tidak sesuai'),
      );

      final bool ok = await controller.updatePassword(
        currentPassword: 'wrongPassword',
        newPassword: 'newPassword123',
        confirmPassword: 'newPassword123',
      );

      expect(ok, isFalse);
      expect(controller.passwordError, 'Password lama tidak sesuai');
    });
  });
}
