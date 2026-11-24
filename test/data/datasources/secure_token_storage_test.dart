// Test: SecureTokenStorage menyimpan JWT (soju_auth_token) dan peran sesi
// (soju_auth_role) melalui FlutterSecureStorage serta menghapus keduanya saat clear().

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/data/datasources/remote/secure_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureTokenStorage', () {
    late SecureTokenStorage storage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      storage = SecureTokenStorage(storage: const FlutterSecureStorage());
    });

    test('mengembalikan null sebelum token dan role ditulis', () async {
      expect(await storage.read(), isNull);
      expect(await storage.readRole(), isNull);
    });

    test('menyimpan dan membaca soju_auth_token serta soju_auth_role',
        () async {
      await storage.write('jwt-secret-token');
      await storage.writeRole('superAdmin');

      expect(await storage.read(), 'jwt-secret-token');
      expect(await storage.readRole(), 'superAdmin');

      const FlutterSecureStorage raw = FlutterSecureStorage();
      expect(await raw.read(key: 'soju_auth_token'), 'jwt-secret-token');
      expect(await raw.read(key: 'soju_auth_role'), 'superAdmin');
    });

    test('clear() menghapus kedua key soju_auth_token dan soju_auth_role',
        () async {
      await storage.write('jwt-secret-token');
      await storage.writeRole('customer');

      await storage.clear();

      expect(await storage.read(), isNull);
      expect(await storage.readRole(), isNull);

      const FlutterSecureStorage raw = FlutterSecureStorage();
      expect(await raw.read(key: 'soju_auth_token'), isNull);
      expect(await raw.read(key: 'soju_auth_role'), isNull);
    });
  });
}
