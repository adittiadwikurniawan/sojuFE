// lib/domain/entities/customer_profile_entity.dart
//
// Entity domain untuk profil pelanggan SOJU dan perubahan akun (TASK-025).

import 'package:flutter/foundation.dart';

/// Entity profil pelanggan yang sinkron dengan `/api/customer/profil`.
@immutable
class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.promotionAllowed = false,
    this.emailVerifiedAt,
    this.createdAt,
    this.lastLoginAt,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final bool promotionAllowed;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  bool get isEmailVerified => emailVerifiedAt != null;

  String get initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  CustomerProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    bool? promotionAllowed,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return CustomerProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      promotionAllowed: promotionAllowed ?? this.promotionAllowed,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// Draf pembaruan data profil pelanggan ke `PATCH /api/customer/profil`.
@immutable
class CustomerProfileUpdateDraft {
  const CustomerProfileUpdateDraft({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.promotionAllowed,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final bool? promotionAllowed;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'nama': name.trim(),
      'email': email.trim().toLowerCase(),
      'noTelepon': phone.trim(),
      'alamat': address.trim(),
      if (promotionAllowed != null) 'promosiDiizinkan': promotionAllowed,
    };
  }
}

/// Draf ubah password pelanggan ke `POST /api/customer/ubah-password`.
@immutable
class CustomerChangePasswordDraft {
  const CustomerChangePasswordDraft({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'passwordLama': currentPassword,
      'passwordBaru': newPassword,
    };
  }
}
