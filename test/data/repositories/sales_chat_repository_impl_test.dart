// Unit test: mock datasource + repository prototype chat penjualan.
//
// Tidak ada HTTP: seluruh fixture berasal dari datasource lokal. Test ini
// memastikan draft lengkap, draft belum lengkap, dan input tak dikenal tidak
// dipaksa menjadi draft.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/data/datasources/mock/sales_chat_mock_datasource.dart';
import 'package:soju_fe/data/repositories/sales_chat_repository_impl.dart';
import 'package:soju_fe/domain/entities/sales_chat_entity.dart';

void main() {
  late SalesChatRepositoryImpl repository;

  setUp(() {
    repository = const SalesChatRepositoryImpl(SalesChatMockDataSource());
  });

  test('contoh lengkap menghasilkan draft yang bisa dikonfirmasi', () async {
    final Result<SalesChatDraft?> result = await repository.parseRecap(
      SalesChatMockDataSource.sampleInput,
    );

    expect(result.isSuccess, isTrue);
    final SalesChatDraft draft = result.valueOrNull!;
    expect(draft.itemTotal, 1375000);
    expect(draft.paymentTotal, 1375000);
    expect(draft.missingFields, isEmpty);
    expect(draft.canConfirm, isTrue);
  });

  test('contoh tanpa pembayaran tetap draft belum lengkap', () async {
    final Result<SalesChatDraft?> result = await repository.parseRecap(
      SalesChatMockDataSource.incompleteSampleInput,
    );

    expect(result.isSuccess, isTrue);
    final SalesChatDraft draft = result.valueOrNull!;
    expect(draft.shift, isNull);
    expect(draft.payments, isEmpty);
    expect(draft.missingFields, contains('Shift'));
    expect(draft.missingFields, contains('Metode pembayaran'));
    expect(draft.canConfirm, isFalse);
  });

  test('input bebas tidak dipaksa menjadi draft', () async {
    final Result<SalesChatDraft?> result = await repository.parseRecap(
      'Halo, tolong catat penjualan hari ini.',
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, isNull);
  });
}
