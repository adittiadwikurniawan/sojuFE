// lib/data/models/customer/customer_profile_models.dart
//
// Model serialisasi profil pelanggan dari API (`GET/PATCH /api/customer/profil`).

import '../../../domain/entities/customer_profile_entity.dart';

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

String _asString(Object? value, [String fallback = '']) {
  if (value is String) return value;
  if (value == null) return fallback;
  return value.toString();
}

bool _asBool(Object? value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return fallback;
}

DateTime? _asDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}

class CustomerProfileModel {
  const CustomerProfileModel({
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

  factory CustomerProfileModel.fromJson(Map<String, Object?> json) {
    return CustomerProfileModel(
      id: _asInt(json['id']),
      name: _asString(json['nama'] ?? json['name']),
      email: _asString(json['email']),
      phone: _asString(json['noTelepon'] ?? json['phone']),
      address: _asString(json['alamat'] ?? json['address']),
      promotionAllowed:
          _asBool(json['promosiDiizinkan'] ?? json['promotionAllowed']),
      emailVerifiedAt: _asDateTime(
        json['emailTerverifikasiPada'] ?? json['emailVerifiedAt'],
      ),
      createdAt: _asDateTime(json['dibuatPada'] ?? json['createdAt']),
      lastLoginAt:
          _asDateTime(json['terakhirMasukPada'] ?? json['lastLoginAt']),
    );
  }

  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final bool promotionAllowed;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  CustomerProfile toEntity() {
    return CustomerProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      promotionAllowed: promotionAllowed,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'nama': name,
      'email': email,
      'noTelepon': phone,
      'alamat': address,
      'promosiDiizinkan': promotionAllowed,
      'emailTerverifikasiPada': emailVerifiedAt?.toIso8601String(),
      'dibuatPada': createdAt?.toIso8601String(),
      'terakhirMasukPada': lastLoginAt?.toIso8601String(),
    };
  }
}
