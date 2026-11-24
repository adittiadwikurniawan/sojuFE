// lib/domain/repositories/sales_chat_repository.dart
//
// Kontrak repository prototype chat penjualan harian/shift.
//
// Prototype hanya meminta draft lokal. Tidak ada metode mutasi karena
// endpoint AI dan keputusan mapping draft ke transaksi belum tersedia.

import '../../core/common/result.dart';
import '../entities/sales_chat_entity.dart';

/// Repository draft chat penjualan.
abstract interface class SalesChatRepository {
  /// Menyusun draft dari input percakapan.
  ///
  /// `Result.success(null)` berarti input belum bisa dipetakan pada mode
  /// demo; UI harus menampilkan penjelasan, bukan mengarang draft.
  Future<Result<SalesChatDraft?>> parseRecap(String input);
}
