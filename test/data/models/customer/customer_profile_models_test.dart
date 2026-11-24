// test/data/models/customer/customer_profile_models_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/data/models/customer/customer_profile_models.dart';
import 'package:soju_fe/domain/entities/customer_profile_entity.dart';

void main() {
  group('CustomerProfileModel', () {
    test('parses full customer profile JSON into CustomerProfile entity', () {
      final Map<String, Object?> json = <String, Object?>{
        'id': 7,
        'nama': 'Aditya Dwi',
        'email': 'aditya@example.com',
        'noTelepon': '08987654321',
        'alamat': 'Jl. Tebet Barat No. 8',
        'promosiDiizinkan': true,
        'emailTerverifikasiPada': '2026-11-20T10:00:00.000Z',
        'dibuatPada': '2026-11-15T08:00:00.000Z',
        'terakhirMasukPada': '2026-11-25T00:30:00.000Z',
      };

      final CustomerProfileModel model = CustomerProfileModel.fromJson(json);
      final CustomerProfile profile = model.toEntity();

      expect(profile.id, 7);
      expect(profile.name, 'Aditya Dwi');
      expect(profile.email, 'aditya@example.com');
      expect(profile.phone, '08987654321');
      expect(profile.address, 'Jl. Tebet Barat No. 8');
      expect(profile.promotionAllowed, isTrue);
      expect(profile.isEmailVerified, isTrue);
      expect(profile.initials, 'AD');
      expect(profile.emailVerifiedAt, DateTime.parse('2026-11-20T10:00:00.000Z'));
    });

    test('calculates initials for single or multi-part names', () {
      const CustomerProfile p1 = CustomerProfile(
        id: 1,
        name: 'Budi',
        email: 'budi@test.com',
        phone: '123',
        address: 'Addr',
      );
      expect(p1.initials, 'B');

      const CustomerProfile p2 = CustomerProfile(
        id: 2,
        name: 'Budi Santoso Putra',
        email: 'budi@test.com',
        phone: '123',
        address: 'Addr',
      );
      expect(p2.initials, 'BP');

      const CustomerProfile p3 = CustomerProfile(
        id: 3,
        name: '',
        email: 'budi@test.com',
        phone: '123',
        address: 'Addr',
      );
      expect(p3.initials, '?');
    });

    test('serializes CustomerProfileUpdateDraft into json correctly', () {
      const CustomerProfileUpdateDraft draft = CustomerProfileUpdateDraft(
        name: ' Budi New ',
        email: ' BUDI@TEST.COM ',
        phone: ' 08123 ',
        address: ' Jl. Melati ',
        promotionAllowed: false,
      );

      final Map<String, Object?> json = draft.toJson();
      expect(json['nama'], 'Budi New');
      expect(json['email'], 'budi@test.com');
      expect(json['noTelepon'], '08123');
      expect(json['alamat'], 'Jl. Melati');
      expect(json['promosiDiizinkan'], isFalse);
    });

    test('serializes CustomerChangePasswordDraft into json correctly', () {
      const CustomerChangePasswordDraft draft = CustomerChangePasswordDraft(
        currentPassword: 'oldSecret123',
        newPassword: 'newSecret456',
      );

      final Map<String, Object?> json = draft.toJson();
      expect(json['passwordLama'], 'oldSecret123');
      expect(json['passwordBaru'], 'newSecret456');
    });
  });
}
