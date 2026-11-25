// lib/domain/repositories/customer_profile_repository.dart
//
// Kontrak repository profil dan kata sandi pelanggan (TASK-025).

import '../../core/common/result.dart';
import '../entities/customer_profile_entity.dart';

abstract class CustomerProfileRepository {
  /// Mengambil data profil pelanggan aktif (`GET /api/customer/profil`).
  Future<Result<CustomerProfile>> fetchProfile();

  /// Memperbarui data profil pelanggan (`PATCH /api/customer/profil`).
  Future<Result<CustomerProfile>> updateProfile(
    CustomerProfileUpdateDraft draft,
  );

  /// Mengubah password pelanggan (`POST /api/customer/ubah-password`).
  Future<Result<String>> changePassword(CustomerChangePasswordDraft draft);
}
