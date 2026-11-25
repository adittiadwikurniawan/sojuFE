// lib/core/services/token_storage/token_storage.dart
//
// Kontrak penyimpanan token JWT (ARCHITECTURE.md §2.6).
//
// Implementasi secure storage berada di `data/datasources/remote/`.
// Token tidak boleh disimpan di SharedPreferences atau source code.

/// Penyimpanan token & peran sesi.
abstract interface class TokenStorage {
  /// Token tersimpan, atau `null` bila belum login.
  Future<String?> read();

  /// Menyimpan token setelah login/daftar berhasil.
  Future<void> write(String token);

  /// Peran sesi tersimpan (`superAdmin`, `admin`, `customer`), atau `null`.
  Future<String?> readRole();

  /// Menyimpan peran sesi setelah login/daftar berhasil.
  Future<void> writeRole(String role);

  /// Menghapus token dan peran saat logout atau sesi ditolak server (401).
  Future<void> clear();
}
