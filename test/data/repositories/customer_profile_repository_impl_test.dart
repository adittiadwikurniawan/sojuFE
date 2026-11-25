// test/data/repositories/customer_profile_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/data/datasources/interfaces/customer_profile_datasource.dart';
import 'package:soju_fe/data/repositories/customer_profile_repository_impl.dart';
import 'package:soju_fe/domain/entities/customer_profile_entity.dart';

class _FakeCustomerProfileDataSource implements CustomerProfileDataSource {
  Map<String, Object?>? profileResponse;
  Map<String, Object?>? updateResponse;
  Map<String, Object?>? changePasswordResponse;
  AppFailure? errorToThrow;
  Map<String, Object?>? capturedUpdatePayload;
  Map<String, Object?>? capturedPasswordPayload;

  @override
  Future<Map<String, Object?>> fetchProfile() async {
    if (errorToThrow != null) throw errorToThrow!;
    return profileResponse ??
        <String, Object?>{
          'status': 'success',
          'data': <String, Object?>{
            'id': 1,
            'nama': 'Pelanggan Test',
            'email': 'pelanggan@test.com',
            'noTelepon': '081234567890',
            'alamat': 'Jl. Kemang',
            'promosiDiizinkan': true,
          },
        };
  }

  @override
  Future<Map<String, Object?>> updateProfile(Map<String, Object?> payload) async {
    capturedUpdatePayload = payload;
    if (errorToThrow != null) throw errorToThrow!;
    return updateResponse ??
        <String, Object?>{
          'status': 'success',
          'message': 'Profil berhasil diperbarui',
          'data': <String, Object?>{
            'id': 1,
            'nama': payload['nama'] ?? 'Pelanggan Test',
            'email': payload['email'] ?? 'pelanggan@test.com',
            'noTelepon': payload['noTelepon'] ?? '081234567890',
            'alamat': payload['alamat'] ?? 'Jl. Kemang',
            'promosiDiizinkan': payload['promosiDiizinkan'] ?? true,
          },
        };
  }

  @override
  Future<Map<String, Object?>> changePassword(Map<String, Object?> payload) async {
    capturedPasswordPayload = payload;
    if (errorToThrow != null) throw errorToThrow!;
    return changePasswordResponse ??
        <String, Object?>{
          'status': 'success',
          'message': 'Password berhasil diperbarui',
          'data': null,
        };
  }
}

void main() {
  late _FakeCustomerProfileDataSource dataSource;
  late CustomerProfileRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeCustomerProfileDataSource();
    repository = CustomerProfileRepositoryImpl(dataSource);
  });

  group('CustomerProfileRepositoryImpl.fetchProfile', () {
    test('returns CustomerProfile on successful fetch', () async {
      final Result<CustomerProfile> result = await repository.fetchProfile();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.name, 'Pelanggan Test');
      expect(result.valueOrNull?.email, 'pelanggan@test.com');
    });

    test('returns FailureResult when fetch fails with AppFailure', () async {
      dataSource.errorToThrow = const UnauthorizedFailure(
        message: 'Login customer diperlukan',
      );

      final Result<CustomerProfile> result = await repository.fetchProfile();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      expect(result.failureOrNull?.message, 'Login customer diperlukan');
    });
  });

  group('CustomerProfileRepositoryImpl.updateProfile', () {
    test('submits draft and returns updated CustomerProfile', () async {
      const CustomerProfileUpdateDraft draft = CustomerProfileUpdateDraft(
        name: 'Nama Baru',
        email: 'baru@test.com',
        phone: '0899999999',
        address: 'Jl. Sudirman',
        promotionAllowed: false,
      );

      final Result<CustomerProfile> result = await repository.updateProfile(draft);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.name, 'Nama Baru');
      expect(dataSource.capturedUpdatePayload?['nama'], 'Nama Baru');
      expect(dataSource.capturedUpdatePayload?['promosiDiizinkan'], isFalse);
    });

    test('returns FailureResult on 409 conflict email already used', () async {
      dataSource.errorToThrow = const ServerFailure(
        statusCode: 409,
        message: 'Email sudah digunakan akun lain',
      );

      const CustomerProfileUpdateDraft draft = CustomerProfileUpdateDraft(
        name: 'Nama Baru',
        email: 'used@test.com',
        phone: '0899999999',
        address: 'Jl. Sudirman',
      );

      final Result<CustomerProfile> result = await repository.updateProfile(draft);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, 'Email sudah digunakan akun lain');
    });
  });

  group('CustomerProfileRepositoryImpl.changePassword', () {
    test('submits password draft and returns success message', () async {
      const CustomerChangePasswordDraft draft = CustomerChangePasswordDraft(
        currentPassword: 'currentPassword123',
        newPassword: 'newPassword123',
      );

      final Result<String> result = await repository.changePassword(draft);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 'Password berhasil diperbarui');
      expect(dataSource.capturedPasswordPayload?['passwordLama'], 'currentPassword123');
      expect(dataSource.capturedPasswordPayload?['passwordBaru'], 'newPassword123');
    });

    test('returns FailureResult on wrong current password', () async {
      dataSource.errorToThrow = const ServerFailure(
        statusCode: 400,
        message: 'Password lama salah',
      );

      const CustomerChangePasswordDraft draft = CustomerChangePasswordDraft(
        currentPassword: 'wrongPassword',
        newPassword: 'newPassword123',
      );

      final Result<String> result = await repository.changePassword(draft);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, 'Password lama salah');
    });
  });
}
