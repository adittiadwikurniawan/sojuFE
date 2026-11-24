// Unit test: feature flag prototype penjualan.
//
// Default build tidak boleh menampilkan prototype di APK produksi.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/app/config/app_features.dart';

void main() {
  test('prototype penjualan nonaktif secara default', () {
    expect(const AppFeatures().salesChatPrototype, isFalse);
    expect(AppFeatures.fromEnvironment.salesChatPrototype, isFalse);
  });
}
