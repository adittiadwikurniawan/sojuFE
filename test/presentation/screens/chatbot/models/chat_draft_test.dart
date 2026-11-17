// Unit test: model & perhitungan draft Chatbot Soju.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/chatbot/models/chat_draft.dart';
import 'package:soju_fe/presentation/screens/chatbot/models/chatbot_view_data.dart';

void main() {
  group('ChatDraft', () {
    test('menghitung total, kuantitas, dan porsi metode pembayaran', () {
      const ChatDraft draft = ChatDraft(
        badge: 'Belum disimpan',
        dateLabel: '14 Okt 2026',
        shiftLabel: 'Shift Siang',
        totalLabel: 'TOTAL PEMASUKAN KASIR',
        breakdownTitle: 'Rincian Menu Terjual',
        items: <ChatDraftItem>[
          ChatDraftItem(
            name: 'Bento',
            quantity: 2,
            unit: 'porsi',
            unitPrice: 35000,
            method: ChatPaymentMethod.qris,
          ),
          ChatDraftItem(
            name: 'Es Teh',
            quantity: 1,
            unit: 'gelas',
            unitPrice: 15000,
            method: ChatPaymentMethod.cash,
          ),
        ],
        confirmLabel: 'Konfirmasi & Simpan',
        correctLabel: 'Koreksi',
        note: 'Belum disimpan.',
      );

      expect(draft.itemCount, 2);
      expect(draft.totalQuantity, 3);
      expect(draft.total, 85000);
      expect(draft.qrisTotal, 70000);
      expect(draft.cashTotal, 15000);
      expect(draft.qrisShare, closeTo(0.8235, 0.0001));
      expect(draft.cashShare, closeTo(0.1765, 0.0001));
      expect(draft.title, 'Rincian Menu Terjual (2 Pos)');
      expect(draft.totalRupiah, '+ Rp 85.000');
      expect(
        draft.items.first.quantityLabel,
        '2 porsi × @Rp 35.000',
      );
      expect(draft.items.first.amountLabel, 'Rp 70.000');
      expect(draft.items.first.methodLabel, 'QRIS Kasir');
      expect(draft.items.last.methodLabel, 'Cash Tunai');
    });

    test('draft kosong tidak membagi dengan nol', () {
      const ChatDraft empty = ChatDraft(
        badge: 'Belum disimpan',
        dateLabel: '14 Okt 2026',
        shiftLabel: 'Shift Siang',
        totalLabel: 'TOTAL PEMASUKAN KASIR',
        breakdownTitle: 'Rincian Menu Terjual',
        items: <ChatDraftItem>[],
        confirmLabel: 'Konfirmasi & Simpan',
        correctLabel: 'Koreksi',
        note: 'Belum disimpan.',
      );

      expect(empty.total, 0);
      expect(empty.qrisShare, 0);
      expect(empty.cashShare, 0);
      expect(empty.title, 'Rincian Menu Terjual (0 Pos)');
      expect(empty.totalRupiah, 'Rp 0');
      expect(empty.qrisLabel, 'QRIS: Rp 0 (0%)');
    });

    test('data contoh Figma memakai nominal hasil hitung', () {
      final ChatDraft draft = ChatbotViewData
          .sample.history.first.conversation.messages.last.draft!;

      expect(draft.badge, 'Belum disimpan');
      expect(draft.total, 1375000);
      expect(draft.qrisTotal, 1050000);
      expect(draft.cashTotal, 325000);
      expect(draft.title, 'Rincian Menu Terjual (3 Pos)');
      expect(draft.metaLabel, '14 Okt 2026 • Shift Siang');
      expect(draft.totalRupiah, '+ Rp 1.375.000');
      expect(draft.qrisLabel, 'QRIS: Rp 1.050.000 (76%)');
      expect(draft.cashLabel, 'Tunai Kasir: Rp 325.000 (24%)');
      expect(draft.items.first.quantityLabel, '30 porsi × @Rp 35.000');
    });
  });
}
