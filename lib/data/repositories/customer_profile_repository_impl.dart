// lib/data/repositories/customer_profile_repository_impl.dart
//
// Implementasi CustomerProfileRepository (TASK-025).

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/customer_profile_entity.dart';
import '../../../domain/repositories/customer_profile_repository.dart';
import '../datasources/interfaces/customer_profile_datasource.dart';
import '../models/customer/customer_profile_models.dart';

class CustomerProfileRepositoryImpl implements CustomerProfileRepository {
  const CustomerProfileRepositoryImpl(this._dataSource);

  final CustomerProfileDataSource _dataSource;

  @override
  Future<Result<CustomerProfile>> fetchProfile() async {
    try {
      final Map<String, Object?> response = await _dataSource.fetchProfile();
      final Object? raw = response['data'];
      if (raw is! Map<String, Object?>) {
        return Result<CustomerProfile>.failure(const ParsingFailure());
      }
      final CustomerProfileModel model = CustomerProfileModel.fromJson(raw);
      return Result<CustomerProfile>.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result<CustomerProfile>.failure(failure);
    } catch (e) {
      return Result<CustomerProfile>.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CustomerProfile>> updateProfile(
    CustomerProfileUpdateDraft draft,
  ) async {
    try {
      final Map<String, Object?> response = await _dataSource.updateProfile(
        draft.toJson(),
      );
      final Object? raw = response['data'];
      if (raw is! Map<String, Object?>) {
        return Result<CustomerProfile>.failure(const ParsingFailure());
      }
      final CustomerProfileModel model = CustomerProfileModel.fromJson(raw);
      return Result<CustomerProfile>.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result<CustomerProfile>.failure(failure);
    } catch (e) {
      return Result<CustomerProfile>.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> changePassword(
    CustomerChangePasswordDraft draft,
  ) async {
    try {
      final Map<String, Object?> response = await _dataSource.changePassword(
        draft.toJson(),
      );
      final String message =
          (response['message'] as String?)?.trim() ?? 'Password berhasil diperbarui';
      return Result<String>.success(message);
    } on AppFailure catch (failure) {
      return Result<String>.failure(failure);
    } catch (e) {
      return Result<String>.failure(ServerFailure(message: e.toString()));
    }
  }
}
