// lib/data/repositories/ai_chat_repository_impl.dart
//
// Implementasi AiChatRepository untuk `/api/v1/ai/*` dan
// konfirmasi draft transaksi `POST /api/v1/transactions`.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/ai_chat_entity.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../datasources/interfaces/ai_chat_datasource.dart';
import '../models/ai/ai_chat_models.dart';
import '../models/api_envelope_model.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  const AiChatRepositoryImpl(this._dataSource);

  final AiChatDataSource _dataSource;

  @override
  Future<Result<List<AiConversationSummary>>> fetchConversations({
    int? limit,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchConversationsRaw(
        limit: limit,
      );
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result<List<AiConversationSummary>>.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Daftar percakapan AI tidak valid.',
          ),
        );
      }

      final Object? data = envelope.data;
      final List<Object?> items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['data'] is List) {
        items = data['data'] as List<Object?>;
      } else {
        return Result<List<AiConversationSummary>>.failure(
          const ParsingFailure(),
        );
      }

      final List<AiConversationSummary> conversations = items
          .whereType<Map<Object?, Object?>>()
          .map(_normalizeMap)
          .map(
            (Map<String, Object?> map) =>
                AiConversationSummaryModel.fromJson(map).toEntity(),
          )
          .toList(growable: false);

      return Result<List<AiConversationSummary>>.success(conversations);
    } on AppFailure catch (failure) {
      return Result<List<AiConversationSummary>>.failure(failure);
    } catch (_) {
      return Result<List<AiConversationSummary>>.failure(
        const NetworkFailure(),
      );
    }
  }

  @override
  Future<Result<AiConversationDetail>> fetchConversationDetail(
    int conversationId,
  ) async {
    try {
      final Map<String, Object?> raw =
          await _dataSource.fetchConversationDetailRaw(conversationId);
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data is! Map) {
        return Result<AiConversationDetail>.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Detail percakapan AI tidak valid.',
          ),
        );
      }

      final Map<String, Object?> data = _normalizeMap(
        envelope.data as Map<Object?, Object?>,
      );
      return Result<AiConversationDetail>.success(
        AiConversationDetailModel.fromJson(data).toEntity(),
      );
    } on AppFailure catch (failure) {
      return Result<AiConversationDetail>.failure(failure);
    } catch (_) {
      return Result<AiConversationDetail>.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AiChatReply>> sendMessage({
    required String message,
    int? conversationId,
  }) async {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return Result<AiChatReply>.failure(
        const ServerFailure(
          statusCode: 400,
          message: 'Pesan tidak boleh kosong.',
        ),
      );
    }

    try {
      final Map<String, Object?> raw = await _dataSource.sendChatMessageRaw(
        message: trimmed,
        conversationId: conversationId,
      );
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data is! Map) {
        return Result<AiChatReply>.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Balasan Asisten AI tidak valid.',
          ),
        );
      }

      final Map<String, Object?> data = _normalizeMap(
        envelope.data as Map<Object?, Object?>,
      );
      return Result<AiChatReply>.success(
        AiChatReplyModel.fromJson(data).toEntity(),
      );
    } on AppFailure catch (failure) {
      return Result<AiChatReply>.failure(failure);
    } catch (_) {
      return Result<AiChatReply>.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AiConfirmedTransaction>> confirmDraftTransaction(
    AiActionDraft draft,
  ) async {
    if (!draft.isReadyToConfirm) {
      final String missing = draft.missingFields.isEmpty
          ? 'data wajib belum lengkap'
          : draft.missingFields.join(', ');
      return Result<AiConfirmedTransaction>.failure(
        ServerFailure(
          statusCode: 400,
          message: 'Draft belum siap disimpan ($missing).',
        ),
      );
    }

    final Map<String, Object?> payload = Map<String, Object?>.of(draft.payload);
    final Object? rawJenisId =
        payload['jenis_transaksi_id'] ?? payload['jenisTransaksiId'];
    final Object rawNominal = payload['nominal'] ?? draft.totalAmount;
    final Object? rawTanggal = payload['tanggal'];

    if (rawTanggal == null ||
        rawTanggal.toString().trim().isEmpty ||
        rawJenisId == null ||
        (rawNominal is num && rawNominal <= 0)) {
      return Result<AiConfirmedTransaction>.failure(
        const ServerFailure(
          statusCode: 400,
          message:
              'Tanggal, jenis transaksi, dan nominal wajib lengkap sebelum menyimpan.',
        ),
      );
    }

    payload['jenis_transaksi_id'] = rawJenisId;
    payload['nominal'] = rawNominal;
    payload['sumber_input'] = 'AI';
    payload['sumberInput'] = 'AI';

    try {
      final Map<String, Object?> raw =
          await _dataSource.confirmDraftTransactionRaw(payload);
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data is! Map) {
        return Result<AiConfirmedTransaction>.failure(
          EnvelopeFailure(
            message:
                envelope.message ?? 'Gagal menyimpan transaksi dari draft AI.',
          ),
        );
      }

      final Map<String, Object?> data = _normalizeMap(
        envelope.data as Map<Object?, Object?>,
      );
      return Result<AiConfirmedTransaction>.success(
        AiConfirmedTransactionModel.fromJson(
          data,
          message: envelope.message ?? 'Transaksi berhasil dicatat.',
        ).toEntity(),
      );
    } on AppFailure catch (failure) {
      return Result<AiConfirmedTransaction>.failure(failure);
    } catch (_) {
      return Result<AiConfirmedTransaction>.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AiReindexResult>> triggerReindex() async {
    try {
      final Map<String, Object?> raw = await _dataSource.triggerReindexRaw();
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data is! Map) {
        return Result<AiReindexResult>.failure(
          EnvelopeFailure(
            message: envelope.message ??
                'Gagal menjalankan reindex basis pengetahuan AI.',
          ),
        );
      }

      final Map<String, Object?> data = _normalizeMap(
        envelope.data as Map<Object?, Object?>,
      );
      return Result<AiReindexResult>.success(
        AiReindexResultModel.fromJson(
          data,
          message: envelope.message ??
              'Reindex basis pengetahuan AI berhasil dijalankan.',
        ).toEntity(),
      );
    } on AppFailure catch (failure) {
      return Result<AiReindexResult>.failure(failure);
    } catch (_) {
      return Result<AiReindexResult>.failure(const NetworkFailure());
    }
  }

  Map<String, Object?> _normalizeMap(Map<Object?, Object?> raw) {
    return raw.map(
      (Object? key, Object? value) =>
          MapEntry<String, Object?>(key.toString(), value),
    );
  }
}
