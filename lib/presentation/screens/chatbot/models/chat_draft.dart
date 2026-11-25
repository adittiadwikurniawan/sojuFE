import 'package:flutter/material.dart';

import '../../../../domain/entities/ai_chat_entity.dart';
import '../../../utils/format.dart';

/// Metode pembayaran pada draft pencatatan penjualan.
enum ChatPaymentMethod { qris, cash }

/// Satu baris menu pada draft pencatatan.
@immutable
class ChatDraftItem {
  const ChatDraftItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.method,
    this.icon = Icons.restaurant,
  });

  final String name;

  /// Jumlah porsi/gelas yang terjual.
  final int quantity;

  /// Satuan tampilan, mis. `porsi` atau `gelas`.
  final String unit;

  /// Harga satuan dalam rupiah penuh.
  final int unitPrice;

  final ChatPaymentMethod method;
  final IconData icon;

  /// Nominal baris dihitung dari jumlah × harga satuan.
  int get amount => quantity * unitPrice;

  String get quantityLabel => '$quantity $unit × @${formatRupiah(unitPrice)}';

  String get amountLabel => formatRupiah(amount);

  String get methodLabel =>
      method == ChatPaymentMethod.qris ? 'QRIS Kasir' : 'Cash Tunai';
}

/// Draft pencatatan yang ditampilkan di dalam percakapan.
///
/// Seluruh total dan porsi pembayaran adalah nilai turunan dari [items],
/// sehingga data API cukup mengirim rincian menu tanpa angka ringkasan.
@immutable
class ChatDraft {
  const ChatDraft({
    required this.badge,
    required this.dateLabel,
    required this.shiftLabel,
    required this.totalLabel,
    required this.breakdownTitle,
    required this.items,
    required this.confirmLabel,
    required this.correctLabel,
    required this.note,
  });

  /// Label status, mis. `Belum disimpan`.
  final String badge;

  final String dateLabel;
  final String shiftLabel;

  /// Judul nominal utama, mis. `TOTAL PEMASUKAN KASIR`.
  final String totalLabel;

  /// Judul rincian, mis. `Rincian Menu Terjual`.
  final String breakdownTitle;

  final List<ChatDraftItem> items;
  final String confirmLabel;
  final String correctLabel;

  /// Catatan bahwa draft belum masuk ke pembukuan.
  final String note;

  int get itemCount => items.length;

  int get totalQuantity =>
      items.fold<int>(0, (int sum, ChatDraftItem item) => sum + item.quantity);

  int get total =>
      items.fold<int>(0, (int sum, ChatDraftItem item) => sum + item.amount);

  int totalFor(ChatPaymentMethod method) => items
      .where((ChatDraftItem item) => item.method == method)
      .fold<int>(0, (int sum, ChatDraftItem item) => sum + item.amount);

  int get qrisTotal => totalFor(ChatPaymentMethod.qris);

  int get cashTotal => totalFor(ChatPaymentMethod.cash);

  double get qrisShare => total == 0 ? 0 : qrisTotal / total;

  double get cashShare => total == 0 ? 0 : cashTotal / total;

  String get totalRupiah => formatRupiah(total, withSign: true);

  /// `Rincian Menu Terjual (3 Pos)`.
  String get title => '$breakdownTitle ($itemCount Pos)';

  String get qrisLabel =>
      'QRIS: ${formatRupiah(qrisTotal)} (${formatPercent(qrisShare)})';

  String get cashLabel =>
      'Tunai Kasir: ${formatRupiah(cashTotal)} (${formatPercent(cashShare)})';

  /// `14 Okt 2026 • Shift Siang`.
  String get metaLabel => '$dateLabel • $shiftLabel';

  /// Mengonversi [AiActionDraft] dari backend Hybrid RAG menjadi [ChatDraft].
  factory ChatDraft.fromActionDraft(AiActionDraft action) {
    final List<ChatDraftItem> mappedItems = action.items
        .map(
          (AiDraftLineItem item) => ChatDraftItem(
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            unitPrice: item.unitPrice,
            method: item.method.toUpperCase() == 'QRIS'
                ? ChatPaymentMethod.qris
                : ChatPaymentMethod.cash,
          ),
        )
        .toList(growable: false);

    return ChatDraft(
      badge: action.badge,
      dateLabel: action.dateLabel,
      shiftLabel: action.shiftLabel,
      totalLabel: action.totalLabel,
      breakdownTitle: action.breakdownTitle,
      items: mappedItems,
      confirmLabel: action.confirmLabel,
      correctLabel: action.correctLabel,
      note: action.note,
    );
  }
}
