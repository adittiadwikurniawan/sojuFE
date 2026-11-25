// Unit test: controller prototype chat penjualan.
//
// Controller memakai repository fake in-memory. Tidak ada HTTP, dan test ini
// memastikan konfirmasi hanya simulasi — tidak ada pemanggilan backend.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/data/datasources/mock/sales_chat_mock_datasource.dart';
import 'package:soju_fe/domain/entities/sales_chat_entity.dart';
import 'package:soju_fe/domain/repositories/sales_chat_repository.dart';
import 'package:soju_fe/domain/usecases/sales_chat_usecases.dart';
import 'package:soju_fe/presentation/providers/sales_chat/sales_chat_controller.dart';

class _FakeSalesChatRepository implements SalesChatRepository {
  _FakeSalesChatRepository(this.draft);

  final SalesChatDraft? draft;
  int calls = 0;
  String? lastInput;

  @override
  Future<Result<SalesChatDraft?>> parseRecap(String input) async {
    calls++;
    lastInput = input;
    return Result<SalesChatDraft?>.success(draft);
  }
}

void main() {
  test('percakapan awal memakai draft contoh dan tidak mengklaim tersimpan',
      () {
    final SalesChatController controller = SalesChatController(
      parseRecap: const ParseSalesChatRecap(_NoopRepository()),
      initialDraft: SalesChatMockDataSource.sampleDraft,
      now: () => DateTime(2026, 11, 19, 14, 8),
    );
    addTearDown(controller.dispose);

    expect(controller.state.messages, hasLength(2));
    expect(controller.state.messages.first.author, SalesChatAuthor.user);
    expect(controller.state.messages.last.author, SalesChatAuthor.assistant);
    expect(controller.state.messages.last.draft, isNotNull);
    expect(controller.state.draft, isNotNull);
    expect(controller.state.isSimulationComplete, isFalse);
    expect(controller.state.messages.last.timeLabel, '14:08');
  });

  test('kirim pesan memakai usecase lokal dan menambahkan draft', () async {
    final _FakeSalesChatRepository repository = _FakeSalesChatRepository(
      SalesChatMockDataSource.sampleDraft,
    );
    final SalesChatController controller = SalesChatController(
      parseRecap: ParseSalesChatRecap(repository),
      now: () => DateTime(2026, 11, 19, 14, 8),
    );
    addTearDown(controller.dispose);

    await controller.sendMessage('Rekap contoh shift siang');

    expect(repository.calls, 1);
    expect(repository.lastInput, 'Rekap contoh shift siang');
    expect(controller.state.messages, hasLength(2));
    expect(controller.state.messages.first.author, SalesChatAuthor.user);
    expect(controller.state.messages.last.author, SalesChatAuthor.assistant);
    expect(controller.state.messages.last.draft, isNotNull);
    expect(controller.state.draft, isNotNull);
    expect(controller.state.status, SalesChatStatus.idle);
  });

  test('input tak dikenal tidak mengarang draft baru', () async {
    final _FakeSalesChatRepository repository = _FakeSalesChatRepository(null);
    final SalesChatController controller = SalesChatController(
      parseRecap: ParseSalesChatRecap(repository),
      now: () => DateTime(2026, 11, 19, 14, 8),
    );
    addTearDown(controller.dispose);

    await controller.sendMessage('Halo, ini bukan rekap penjualan.');

    expect(controller.state.messages, hasLength(2));
    expect(controller.state.messages.last.draft, isNull);
    expect(
      controller.state.messages.last.text,
      contains('belum bisa dibaca'),
    );
    expect(
      controller.state.messages.last.text,
      contains('Tidak ada data yang dikirim ke AI'),
    );
    expect(controller.state.draft, isNull);
  });

  test('koreksi hanya mengubah draft terakhir pada sesi lokal', () async {
    final SalesChatDraft initial = SalesChatMockDataSource.sampleDraft;
    final SalesChatDraft corrected = initial.copyWith(shift: 'Malam');
    final SalesChatController controller = SalesChatController(
      parseRecap: const ParseSalesChatRecap(_NoopRepository()),
      initialDraft: initial,
      now: () => DateTime(2026, 11, 19, 14, 8),
    );
    addTearDown(controller.dispose);

    controller.applyCorrection(corrected);

    expect(controller.state.draft, corrected);
    expect(controller.state.messages.last.draft, corrected);
    expect(controller.state.messages, hasLength(2));
    expect(controller.state.isSimulationComplete, isFalse);
  });

  test('konfirmasi draft valid hanya menghasilkan pesan simulasi', () async {
    final _FakeSalesChatRepository repository = _FakeSalesChatRepository(
      SalesChatMockDataSource.sampleDraft,
    );
    final SalesChatController controller = SalesChatController(
      parseRecap: ParseSalesChatRecap(repository),
      initialDraft: SalesChatMockDataSource.sampleDraft,
      now: () => DateTime(2026, 11, 19, 14, 8),
    );
    addTearDown(controller.dispose);

    final bool confirmed = controller.confirmSimulation();

    expect(confirmed, isTrue);
    expect(repository.calls, 0);
    expect(controller.state.isSimulationComplete, isTrue);
    expect(
      controller.state.simulationMessage,
      'Simulasi selesai — tidak masuk ke pembukuan.',
    );
    expect(controller.state.messages.last.isSimulationResult, isTrue);
    expect(controller.state.messages.last.text,
        controller.state.simulationMessage);
  });

  test('konfirmasi draft belum lengkap ditolak dan menjelaskan sebabnya', () {
    final SalesChatController controller = SalesChatController(
      parseRecap: const ParseSalesChatRecap(_NoopRepository()),
      initialDraft: SalesChatMockDataSource.incompleteSampleDraft,
      now: () => DateTime(2026, 11, 19, 14, 8),
    );
    addTearDown(controller.dispose);

    final bool confirmed = controller.confirmSimulation();

    expect(confirmed, isFalse);
    expect(controller.state.isSimulationComplete, isFalse);
    expect(controller.state.simulationMessage, isNull);
    expect(controller.state.errorMessage, contains('Lengkapi field'));
    expect(controller.state.messages, hasLength(2));
  });
}

class _NoopRepository implements SalesChatRepository {
  const _NoopRepository();

  @override
  Future<Result<SalesChatDraft?>> parseRecap(String input) async {
    return Result<SalesChatDraft?>.success(null);
  }
}
