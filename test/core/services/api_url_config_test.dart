// Test: AppConfig menormalkan API_BASE_URL (origin-only maupun berakhiran /api/v1).

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/app/config/app_config.dart';

void main() {
  group('AppConfig URL normalization', () {
    test('normalizeApiOrigin membersihkan trailing slash dan /api/v1', () {
      expect(
        AppConfig.normalizeApiOrigin('http://localhost:4000'),
        'http://localhost:4000',
      );
      expect(
        AppConfig.normalizeApiOrigin('http://localhost:4000/'),
        'http://localhost:4000',
      );
      expect(
        AppConfig.normalizeApiOrigin('http://localhost:4000/api/v1'),
        'http://localhost:4000',
      );
      expect(
        AppConfig.normalizeApiOrigin('http://localhost:4000/api/v1/'),
        'http://localhost:4000',
      );
      expect(
        AppConfig.normalizeApiOrigin('  https://api.soju.id/api/v1///  '),
        'https://api.soju.id',
      );
      expect(AppConfig.normalizeApiOrigin('   '), '');
    });

    test('apiBaseUrl selalu konsisten dengan apiOrigin + /api/v1', () {
      expect(AppConfig.apiOrigin, isNotEmpty);
      expect(AppConfig.apiOrigin.endsWith('/api/v1'), isFalse);
      expect(AppConfig.apiBaseUrl, '${AppConfig.apiOrigin}/api/v1');
      expect(AppConfig.hasApiBaseUrl, isTrue);
    });
  });
}
