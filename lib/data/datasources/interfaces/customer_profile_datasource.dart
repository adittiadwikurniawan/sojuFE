// lib/data/datasources/interfaces/customer_profile_datasource.dart
//
// Antarmuka datasource profil pelanggan (TASK-025).

abstract class CustomerProfileDataSource {
  /// Mengambil profil akun pelanggan (`GET /api/customer/profil`).
  Future<Map<String, Object?>> fetchProfile();

  /// Memperbarui profil pelanggan (`PATCH /api/customer/profil`).
  Future<Map<String, Object?>> updateProfile(Map<String, Object?> payload);

  /// Mengubah password pelanggan (`POST /api/customer/ubah-password`).
  Future<Map<String, Object?>> changePassword(Map<String, Object?> payload);
}
