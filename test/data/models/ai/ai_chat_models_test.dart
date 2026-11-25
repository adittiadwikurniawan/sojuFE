// Unit test: DTO parsing Hybrid RAG AI (`ai_chat_models.dart`).

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/data/models/ai/ai_chat_models.dart';
import 'package:soju_fe/domain/entities/ai_chat_entity.dart';

void main() {
  group('AiCitationModel', () {
    test('mem-parse DocumentCitation dengan judul, snippet, dan skor', () {
      final AiCitation citation = AiCitationModel.fromJson(<String, Object?>{
        'id': 'D1',
        'documentId': 12,
        'chunkId': 34,
        'title': 'SOP Penanganan Komplain Pelanggan',
        'sourceType': 'SOP',
        'sourceRef': 'sop-komplain.md',
        'roleScope': 'ALL_ADMIN',
        'snippet': 'Tanggapi komplain maksimal 15 menit dan tawarkan penggantian.',
        'score': 0.89,
      }).toEntity();

      expect(citation.id, 'D1');
      expect(citation.chipLabel, '[D1]');
      expect(citation.title, 'SOP Penanganan Komplain Pelanggan');
      expect(citation.sourceType, 'SOP');
      expect(citation.sourceTypeLabel, 'SOP');
      expect(citation.isSqlTool, isFalse);
      expect(citation.score, closeTo(0.89, 0.001));
      expect(citation.excerpt, contains('maksimal 15 menit'));
    });

    test('mem-parse SqlCitation menggunakan label dan querySummary', () {
      final AiCitation citation = AiCitationModel.fromJson(<String, Object?>{
        'id': 'SQL-1',
        'sourceType': 'SQL_TOOL',
        'toolName': 'getSalesSummary',
        'label': 'Ringkasan Penjualan Hari Ini',
        'querySummary': 'Agregasi transaksi PEMASUKAN tanggal 2026-11-25',
        'executedAt': '2026-11-25T04:00:00.000Z',
      }).toEntity();

      expect(citation.id, 'SQL-1');
      expect(citation.isSqlTool, isTrue);
      expect(citation.sourceTypeLabel, 'Data SQL');
      expect(citation.title, 'Ringkasan Penjualan Hari Ini');
      expect(citation.excerpt, contains('Agregasi transaksi'));
      expect(citation.executedAt, isNotNull);
    });
  });

  group('AiChatReplyModel & AiActionDraftModel', () {
    test('mem-parse balasan ACTION_DRAFT beserta payload dan item', () {
      final AiChatReply reply = AiChatReplyModel.fromJson(<String, Object?>{
        'conversationId': 7,
        'title': 'Catat penjualan bento',
        'routePath': 'ACTION_DRAFT',
        'reply': 'Draft penjualan siap dikonfirmasi.',
        'citations': <Object?>[],
        'actions': <Object?>[
          <String, Object?>{
            'id': 'draft-1',
            'type': 'CREATE_TRANSACTION',
            'intent': 'PENJUALAN',
            'requiresConfirmation': true,
            'endpoint': '/api/v1/transactions',
            'method': 'POST',
            'title': 'Draft Penjualan Kasir',
            'sheet': 'Transaksi',
            'summaryRows': <Object?>[
              <String, Object?>{'label': 'Metode', 'value': 'TUNAI'},
            ],
            'total': 'Rp 175.000',
            'totalAmount': 175000,
            'badge': 'Belum disimpan',
            'dateLabel': '25 Nov 2026',
            'shiftLabel': 'Shift Siang',
            'totalLabel': 'TOTAL PEMASUKAN KASIR',
            'breakdownTitle': 'Rincian Menu Terjual',
            'items': <Object?>[
              <String, Object?>{
                'produkId': 3,
                'nama': 'Bento Ayam Bakar',
                'jumlah': 5,
                'satuan': 'porsi',
                'hargaSatuan': 35000,
                'subtotal': 175000,
                'metode': 'CASH',
              },
            ],
            'confirmLabel': 'Konfirmasi & Simpan',
            'correctLabel': 'Koreksi Jumlah / Harga',
            'note': 'Draft belum disimpan ke pembukuan.',
            'payload': <String, Object?>{
              'tanggal': '2026-11-25',
              'jenis_transaksi_id': 1,
              'nominal': 175000,
              'sumber_input': 'AI',
            },
            'isReadyToConfirm': true,
            'missingFields': <Object?>[],
          },
        ],
      }).toEntity();

      expect(reply.conversationId, 7);
      expect(reply.routePath, AiRoutePath.actionDraft);
      expect(reply.actions, hasLength(1));
      final AiActionDraft draft = reply.actions.first;
      expect(draft.requiresConfirmation, isTrue);
      expect(draft.isReadyToConfirm, isTrue);
      expect(draft.totalAmount, 175000);
      expect(draft.items.first.name, 'Bento Ayam Bakar');
      expect(draft.payload['jenis_transaksi_id'], 1);
    });
  });

  group('AiReindexResultModel', () {
    test('mem-parse ringkasan hasil reindex basis pengetahuan AI', () {
      final AiReindexResult result = AiReindexResultModel.fromJson(
        <String, Object?>{
          'documentsProcessed': 14,
          'chunksCreated': 42,
          'piiRedactedChunks': 2,
          'sources': <String, Object?>{
            'documents': 5,
            'products': 7,
            'cms': 2,
          },
        },
        message: 'Reindex basis pengetahuan AI berhasil dijalankan',
      ).toEntity();

      expect(result.documentsProcessed, 14);
      expect(result.chunksCreated, 42);
      expect(result.piiRedactedChunks, 2);
      expect(result.documentsCount, 5);
      expect(result.productsCount, 7);
      expect(result.cmsCount, 2);
    });
  });
}
