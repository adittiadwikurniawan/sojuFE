// lib/data/datasources/mock/admin_users_mock_datasource.dart
//
// Mock datasource fallback untuk Manajemen Multi-User Admin (Phase A / test terisolasi).

import '../interfaces/admin_users_datasource.dart';

class AdminUsersMockDataSource implements AdminUsersDataSource {
  AdminUsersMockDataSource();

  int _nextId = 4;

  final List<Map<String, Object?>> _users = <Map<String, Object?>>[
    <String, Object?>{
      'id': 1,
      'nama': 'Dea Super Admin',
      'email': 'superadmin@sojucorp.com',
      'peran': 'SUPER_ADMIN',
      'aktif': true,
      'terakhirMasukPada': '2026-11-24T08:30:00.000Z',
      'dibuatOleh': null,
      'dibuatPada': '2026-01-01T00:00:00.000Z',
      'diubahPada': '2026-11-24T08:30:00.000Z',
    },
    <String, Object?>{
      'id': 2,
      'nama': 'Budi Operasional',
      'email': 'admin@sojucorp.com',
      'peran': 'ADMIN',
      'aktif': true,
      'terakhirMasukPada': '2026-11-23T14:15:00.000Z',
      'dibuatOleh': 1,
      'dibuatPada': '2026-02-10T09:00:00.000Z',
      'diubahPada': '2026-11-23T14:15:00.000Z',
    },
    <String, Object?>{
      'id': 3,
      'nama': 'Sari Kasir',
      'email': 'sari.kasir@sojucorp.com',
      'peran': 'ADMIN',
      'aktif': false,
      'terakhirMasukPada': null,
      'dibuatOleh': 1,
      'dibuatPada': '2026-03-05T10:00:00.000Z',
      'diubahPada': '2026-10-01T12:00:00.000Z',
    },
  ];

  @override
  Future<Map<String, Object?>> fetchUsersRaw({
    String? search,
    String? role,
    bool? isActive,
  }) async {
    final String q = (search ?? '').trim().toLowerCase();
    final List<Map<String, Object?>> filtered = _users.where((Map<String, Object?> u) {
      if (q.isNotEmpty) {
        final String nama = (u['nama'] as String? ?? '').toLowerCase();
        final String email = (u['email'] as String? ?? '').toLowerCase();
        if (!nama.contains(q) && !email.contains(q)) return false;
      }
      if (role != null && role.isNotEmpty && u['peran'] != role) {
        return false;
      }
      if (isActive != null && u['aktif'] != isActive) {
        return false;
      }
      return true;
    }).map((Map<String, Object?> u) => Map<String, Object?>.from(u)).toList();

    return <String, Object?>{
      'success': true,
      'data': filtered,
    };
  }

  @override
  Future<Map<String, Object?>> createUserRaw({
    required String name,
    required String email,
    String? password,
    required String role,
    bool sendInvite = false,
  }) async {
    final String now = DateTime.now().toUtc().toIso8601String();
    final Map<String, Object?> created = <String, Object?>{
      'id': _nextId++,
      'nama': name.trim(),
      'email': email.trim().toLowerCase(),
      'peran': role,
      'aktif': true,
      'terakhirMasukPada': null,
      'dibuatOleh': 1,
      'dibuatPada': now,
      'diubahPada': now,
    };
    _users.add(created);
    return <String, Object?>{
      'success': true,
      'data': Map<String, Object?>.from(created),
      'message': sendInvite
          ? 'Akun Admin berhasil dibuat dan email undangan telah dikirim'
          : 'Akun Admin berhasil dibuat',
    };
  }

  @override
  Future<Map<String, Object?>> updateUserRaw({
    required int userId,
    String? name,
    String? email,
    String? role,
  }) async {
    final int idx = _users.indexWhere((Map<String, Object?> u) => u['id'] == userId);
    if (idx < 0) {
      return <String, Object?>{
        'success': false,
        'message': 'Akun admin tidak ditemukan',
      };
    }
    final Map<String, Object?> updated = Map<String, Object?>.from(_users[idx]);
    if (name != null) updated['nama'] = name.trim();
    if (email != null) updated['email'] = email.trim().toLowerCase();
    if (role != null) updated['peran'] = role;
    updated['diubahPada'] = DateTime.now().toUtc().toIso8601String();
    _users[idx] = updated;
    return <String, Object?>{
      'success': true,
      'data': Map<String, Object?>.from(updated),
      'message': 'Data akun admin berhasil diperbarui',
    };
  }

  @override
  Future<Map<String, Object?>> updateUserStatusRaw({
    required int userId,
    required bool isActive,
  }) async {
    final int idx = _users.indexWhere((Map<String, Object?> u) => u['id'] == userId);
    if (idx < 0) {
      return <String, Object?>{
        'success': false,
        'message': 'Akun admin tidak ditemukan',
      };
    }
    final Map<String, Object?> updated = Map<String, Object?>.from(_users[idx]);
    updated['aktif'] = isActive;
    updated['diubahPada'] = DateTime.now().toUtc().toIso8601String();
    _users[idx] = updated;
    return <String, Object?>{
      'success': true,
      'data': Map<String, Object?>.from(updated),
      'message': isActive
          ? 'Akun admin berhasil diaktifkan'
          : 'Akun admin berhasil dinonaktifkan',
    };
  }

  @override
  Future<Map<String, Object?>> softDisableUserRaw({
    required int userId,
  }) {
    return updateUserStatusRaw(userId: userId, isActive: false);
  }

  @override
  Future<Map<String, Object?>> triggerPasswordResetRaw({
    required int userId,
  }) async {
    final int idx = _users.indexWhere((Map<String, Object?> u) => u['id'] == userId);
    if (idx < 0) {
      return <String, Object?>{
        'success': false,
        'message': 'Akun admin tidak ditemukan',
      };
    }
    final Map<String, Object?> target = _users[idx];
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'userId': target['id'],
        'email': target['email'],
      },
      'message': 'Tautan reset password telah dikirim ke email admin.',
    };
  }
}
