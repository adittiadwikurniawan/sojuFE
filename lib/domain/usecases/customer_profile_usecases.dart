// lib/domain/usecases/customer_profile_usecases.dart
//
// Usecase profil pelanggan (TASK-025): baca profil, ubah profil, ubah password.

import '../../core/common/result.dart';
import '../entities/customer_profile_entity.dart';
import '../repositories/customer_profile_repository.dart';

class GetCustomerProfile {
  const GetCustomerProfile(this._repository);

  final CustomerProfileRepository _repository;

  Future<Result<CustomerProfile>> call() {
    return _repository.fetchProfile();
  }
}

class UpdateCustomerProfile {
  const UpdateCustomerProfile(this._repository);

  final CustomerProfileRepository _repository;

  Future<Result<CustomerProfile>> call(CustomerProfileUpdateDraft draft) {
    return _repository.updateProfile(draft);
  }
}

class ChangeCustomerPassword {
  const ChangeCustomerPassword(this._repository);

  final CustomerProfileRepository _repository;

  Future<Result<String>> call(CustomerChangePasswordDraft draft) {
    return _repository.changePassword(draft);
  }
}
