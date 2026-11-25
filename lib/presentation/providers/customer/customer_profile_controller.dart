// lib/presentation/providers/customer/customer_profile_controller.dart
//
// Controller profil & ganti kata sandi pelanggan SOJU (TASK-025).

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../domain/entities/customer_profile_entity.dart';
import '../../../domain/usecases/customer_profile_usecases.dart';

class CustomerProfileController extends ChangeNotifier {
  CustomerProfileController({
    required GetCustomerProfile getProfile,
    required UpdateCustomerProfile updateProfile,
    required ChangeCustomerPassword changePassword,
    CustomerProfile? initialProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _changePassword = changePassword,
        _profile = initialProfile;

  final GetCustomerProfile _getProfile;
  final UpdateCustomerProfile _updateProfile;
  final ChangeCustomerPassword _changePassword;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  CustomerProfile? _profile;

  String? _errorMessage;
  String? _successMessage;

  String? _passwordError;
  String? _passwordSuccess;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isChangingPassword => _isChangingPassword;
  CustomerProfile? get profile => _profile;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get passwordError => _passwordError;
  String? get passwordSuccess => _passwordSuccess;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _passwordError = null;
    _passwordSuccess = null;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final Result<CustomerProfile> result = await _getProfile();
    _isLoading = false;

    if (result.isSuccess) {
      _profile = result.valueOrNull;
      _errorMessage = null;
    } else {
      _errorMessage = result.failureOrNull?.message ??
          'Gagal memuat profil akun. Ketuk untuk coba lagi.';
    }
    notifyListeners();
  }

  Future<bool> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    bool? promotionAllowed,
  }) async {
    final String cleanName = name.trim();
    final String cleanEmail = email.trim().toLowerCase();
    final String cleanPhone = phone.trim();
    final String cleanAddress = address.trim();

    if (cleanName.isEmpty) {
      _errorMessage = 'Nama lengkap wajib diisi';
      notifyListeners();
      return false;
    }
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      _errorMessage = 'Alamat email tidak valid';
      notifyListeners();
      return false;
    }
    if (cleanPhone.isEmpty) {
      _errorMessage = 'Nomor telepon wajib diisi';
      notifyListeners();
      return false;
    }
    if (cleanAddress.isEmpty) {
      _errorMessage = 'Alamat pengiriman wajib diisi';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final Result<CustomerProfile> result = await _updateProfile(
      CustomerProfileUpdateDraft(
        name: cleanName,
        email: cleanEmail,
        phone: cleanPhone,
        address: cleanAddress,
        promotionAllowed: promotionAllowed,
      ),
    );

    _isSaving = false;
    if (result.isSuccess && result.valueOrNull != null) {
      _profile = result.valueOrNull;
      _successMessage = 'Profil berhasil diperbarui';
      notifyListeners();
      return true;
    }

    _errorMessage = result.failureOrNull?.message ??
        'Gagal memperbarui profil. Silakan coba lagi.';
    notifyListeners();
    return false;
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final String current = currentPassword.trim();
    final String next = newPassword.trim();
    final String confirm = confirmPassword.trim();

    if (current.isEmpty) {
      _passwordError = 'Password saat ini wajib diisi';
      notifyListeners();
      return false;
    }
    if (next.length < 8) {
      _passwordError = 'Password baru minimal 8 karakter';
      notifyListeners();
      return false;
    }
    if (next != confirm) {
      _passwordError = 'Konfirmasi password baru tidak cocok';
      notifyListeners();
      return false;
    }

    _isChangingPassword = true;
    _passwordError = null;
    _passwordSuccess = null;
    notifyListeners();

    final Result<String> result = await _changePassword(
      CustomerChangePasswordDraft(
        currentPassword: current,
        newPassword: next,
      ),
    );

    _isChangingPassword = false;
    if (result.isSuccess) {
      _passwordSuccess = result.valueOrNull ?? 'Password berhasil diperbarui';
      notifyListeners();
      return true;
    }

    _passwordError = result.failureOrNull?.message ??
        'Gagal mengubah password. Pastikan password lama sesuai.';
    notifyListeners();
    return false;
  }
}
