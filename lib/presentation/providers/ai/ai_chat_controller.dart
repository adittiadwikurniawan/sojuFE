// lib/presentation/providers/ai/ai_chat_controller.dart
//
// ChangeNotifier controller untuk layar Hybrid RAG AI Admin (`TASK-028`).
//
// Mengelola:
// - Riwayat percakapan (`GET /api/v1/ai/conversations` & `/:id`)
// - Pengiriman pesan live (`POST /api/v1/ai/chat`) dengan sitasi & draft aksi
// - Konfirmasi manual draft transaksi (`POST /api/v1/transactions`)
// - Reindex basis pengetahuan AI (`POST /api/v1/ai/reindex`, `SUPER_ADMIN`)

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/ai_chat_entity.dart';
import '../../../domain/usecases/ai_chat_usecases.dart';

const Object _unset = Object();

@immutable
class AiChatState {
  const AiChatState({
    this.conversations = const <AiConversationSummary>[],
    this.isLoadingHistory = false,
    this.historyError,
    this.isInConversation = false,
    this.activeConversationId,
    this.activeConversationTitle = 'Chat Baru',
    this.messages = const <AiMessage>[],
    this.isLoadingConversation = false,
    this.isSending = false,
    this.conversationError,
    this.confirmingDraftIds = const <String>{},
    this.confirmedDrafts = const <String, AiConfirmedTransaction>{},
    this.isReindexing = false,
  });

  final List<AiConversationSummary> conversations;
  final bool isLoadingHistory;
  final String? historyError;

  final bool isInConversation;
  final int? activeConversationId;
  final String activeConversationTitle;
  final List<AiMessage> messages;
  final bool isLoadingConversation;
  final bool isSending;
  final String? conversationError;

  final Set<String> confirmingDraftIds;
  final Map<String, AiConfirmedTransaction> confirmedDrafts;
  final bool isReindexing;

  bool isConfirmingDraft(String draftId) => confirmingDraftIds.contains(draftId);

  bool isDraftConfirmed(String draftId) => confirmedDrafts.containsKey(draftId);

  AiConfirmedTransaction? confirmedTransactionFor(String draftId) =>
      confirmedDrafts[draftId];

  AiChatState copyWith({
    List<AiConversationSummary>? conversations,
    bool? isLoadingHistory,
    Object? historyError = _unset,
    bool? isInConversation,
    Object? activeConversationId = _unset,
    String? activeConversationTitle,
    List<AiMessage>? messages,
    bool? isLoadingConversation,
    bool? isSending,
    Object? conversationError = _unset,
    Set<String>? confirmingDraftIds,
    Map<String, AiConfirmedTransaction>? confirmedDrafts,
    bool? isReindexing,
  }) {
    return AiChatState(
      conversations: conversations ?? this.conversations,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      historyError: identical(historyError, _unset)
          ? this.historyError
          : historyError as String?,
      isInConversation: isInConversation ?? this.isInConversation,
      activeConversationId: identical(activeConversationId, _unset)
          ? this.activeConversationId
          : activeConversationId as int?,
      activeConversationTitle:
          activeConversationTitle ?? this.activeConversationTitle,
      messages: messages ?? this.messages,
      isLoadingConversation:
          isLoadingConversation ?? this.isLoadingConversation,
      isSending: isSending ?? this.isSending,
      conversationError: identical(conversationError, _unset)
          ? this.conversationError
          : conversationError as String?,
      confirmingDraftIds: confirmingDraftIds ?? this.confirmingDraftIds,
      confirmedDrafts: confirmedDrafts ?? this.confirmedDrafts,
      isReindexing: isReindexing ?? this.isReindexing,
    );
  }
}

class AiChatController extends ChangeNotifier {
  AiChatController({
    required GetAiConversations getConversations,
    required GetAiConversationDetail getConversationDetail,
    required SendAiChatMessage sendChatMessage,
    required ConfirmAiDraftTransaction confirmDraftTransaction,
    required TriggerAiReindex triggerReindex,
  })  : _getConversations = getConversations,
        _getConversationDetail = getConversationDetail,
        _sendChatMessage = sendChatMessage,
        _confirmDraftTransaction = confirmDraftTransaction,
        _triggerReindex = triggerReindex;

  final GetAiConversations _getConversations;
  final GetAiConversationDetail _getConversationDetail;
  final SendAiChatMessage _sendChatMessage;
  final ConfirmAiDraftTransaction _confirmDraftTransaction;
  final TriggerAiReindex _triggerReindex;

  AiChatState _state = const AiChatState();
  bool _disposed = false;
  int _tempIdCounter = -1;

  AiChatState get state => _state;

  /// Memuat daftar riwayat percakapan milik admin yang sedang login.
  Future<void> loadConversations({int? limit}) async {
    _updateState(
      _state.copyWith(
        isLoadingHistory: true,
        historyError: null,
      ),
    );

    final Result<List<AiConversationSummary>> result =
        await _getConversations(limit: limit);

    result.fold(
      onSuccess: (List<AiConversationSummary> items) {
        _updateState(
          _state.copyWith(
            conversations: List<AiConversationSummary>.unmodifiable(items),
            isLoadingHistory: false,
            historyError: null,
          ),
        );
      },
      onFailure: (AppFailure failure) {
        _updateState(
          _state.copyWith(
            isLoadingHistory: false,
            historyError: failure.message,
          ),
        );
      },
    );
  }

  /// Membuka percakapan baru kosong.
  void startNewConversation() {
    _updateState(
      _state.copyWith(
        isInConversation: true,
        activeConversationId: null,
        activeConversationTitle: 'Chat Baru',
        messages: const <AiMessage>[],
        isLoadingConversation: false,
        conversationError: null,
      ),
    );
  }

  /// Membuka riwayat percakapan berdasarkan ringkasannya dan memuat pesan dari backend.
  Future<void> openConversation(AiConversationSummary summary) async {
    _updateState(
      _state.copyWith(
        isInConversation: true,
        activeConversationId: summary.id,
        activeConversationTitle: summary.title,
        messages: const <AiMessage>[],
        isLoadingConversation: true,
        conversationError: null,
      ),
    );

    final Result<AiConversationDetail> result =
        await _getConversationDetail(summary.id);

    result.fold(
      onSuccess: (AiConversationDetail detail) {
        _updateState(
          _state.copyWith(
            activeConversationId: detail.id,
            activeConversationTitle: detail.title,
            messages: List<AiMessage>.unmodifiable(detail.messages),
            isLoadingConversation: false,
            conversationError: null,
          ),
        );
      },
      onFailure: (AppFailure failure) {
        _updateState(
          _state.copyWith(
            isLoadingConversation: false,
            conversationError: failure.message,
          ),
        );
      },
    );
  }

  /// Kembali ke halaman utama AI (salam, alat cepat, dan riwayat).
  void closeConversation() {
    _updateState(
      _state.copyWith(
        isInConversation: false,
        activeConversationId: null,
        activeConversationTitle: 'Chat Baru',
        messages: const <AiMessage>[],
        isLoadingConversation: false,
        conversationError: null,
      ),
    );
  }

  /// Mengirim pesan ke Hybrid RAG AI (`POST /api/v1/ai/chat`).
  Future<bool> sendMessage(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || _state.isSending) {
      return false;
    }

    final int tempUserId = _tempIdCounter--;
    final AiMessage optimisticUser = AiMessage(
      id: tempUserId,
      conversationId: _state.activeConversationId ?? 0,
      author: AiMessageAuthor.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    final List<AiMessage> previousMessages = _state.messages;
    _updateState(
      _state.copyWith(
        isInConversation: true,
        messages: List<AiMessage>.unmodifiable(
          <AiMessage>[...previousMessages, optimisticUser],
        ),
        isSending: true,
        conversationError: null,
      ),
    );

    final Result<AiChatReply> result = await _sendChatMessage(
      message: trimmed,
      conversationId: _state.activeConversationId,
    );

    bool succeeded = false;
    result.fold(
      onSuccess: (AiChatReply reply) {
        succeeded = true;
        final AiMessage userMsg = reply.userMessage ??
            AiMessage(
              id: tempUserId,
              conversationId: reply.conversationId,
              author: AiMessageAuthor.user,
              content: trimmed,
              createdAt: optimisticUser.createdAt,
            );
        final AiMessage assistantMsg = reply.assistantMessage ??
            AiMessage(
              id: _tempIdCounter--,
              conversationId: reply.conversationId,
              author: AiMessageAuthor.assistant,
              content: reply.reply,
              routePath: reply.routePath,
              citations: reply.citations,
              actions: reply.actions,
              createdAt: DateTime.now(),
            );

        final List<AiMessage> nextMessages = <AiMessage>[
          ...previousMessages,
          userMsg,
          assistantMsg,
        ];

        final List<AiConversationSummary> nextConversations =
            _upsertConversationSummary(
          existing: _state.conversations,
          conversationId: reply.conversationId,
          title: reply.title,
          lastMessagePreview: assistantMsg.content,
          messageCount: nextMessages.length,
        );

        _updateState(
          _state.copyWith(
            activeConversationId: reply.conversationId,
            activeConversationTitle: reply.title,
            messages: List<AiMessage>.unmodifiable(nextMessages),
            conversations:
                List<AiConversationSummary>.unmodifiable(nextConversations),
            isSending: false,
            conversationError: null,
          ),
        );
      },
      onFailure: (AppFailure failure) {
        _updateState(
          _state.copyWith(
            messages: List<AiMessage>.unmodifiable(previousMessages),
            isSending: false,
            conversationError: failure.message,
          ),
        );
      },
    );

    return succeeded;
  }

  /// Mengonfirmasi draft transaksi secara eksplisit ke `POST /api/v1/transactions`.
  Future<Result<AiConfirmedTransaction>> confirmDraft(
    AiActionDraft draft,
  ) async {
    if (_state.isDraftConfirmed(draft.id)) {
      return Result<AiConfirmedTransaction>.success(
        _state.confirmedDrafts[draft.id]!,
      );
    }
    if (_state.isConfirmingDraft(draft.id)) {
      return Result<AiConfirmedTransaction>.failure(
        const ServerFailure(statusCode: 409, message: 'Draft sedang diproses.'),
      );
    }

    final Set<String> nextConfirming = Set<String>.of(_state.confirmingDraftIds)
      ..add(draft.id);
    _updateState(
      _state.copyWith(
        confirmingDraftIds: Set<String>.unmodifiable(nextConfirming),
        conversationError: null,
      ),
    );

    final Result<AiConfirmedTransaction> result =
        await _confirmDraftTransaction(draft);

    final Set<String> doneConfirming = Set<String>.of(_state.confirmingDraftIds)
      ..remove(draft.id);

    result.fold(
      onSuccess: (AiConfirmedTransaction confirmed) {
        final Map<String, AiConfirmedTransaction> nextConfirmed =
            Map<String, AiConfirmedTransaction>.of(_state.confirmedDrafts)
              ..[draft.id] = confirmed;
        _updateState(
          _state.copyWith(
            confirmingDraftIds: Set<String>.unmodifiable(doneConfirming),
            confirmedDrafts:
                Map<String, AiConfirmedTransaction>.unmodifiable(nextConfirmed),
          ),
        );
      },
      onFailure: (AppFailure failure) {
        _updateState(
          _state.copyWith(
            confirmingDraftIds: Set<String>.unmodifiable(doneConfirming),
            conversationError: failure.message,
          ),
        );
      },
    );

    return result;
  }

  /// Memicu reindex basis pengetahuan AI (`POST /api/v1/ai/reindex`, `SUPER_ADMIN`).
  Future<Result<AiReindexResult>> triggerReindex() async {
    if (_state.isReindexing) {
      return Result<AiReindexResult>.failure(
        const ServerFailure(
          statusCode: 409,
          message: 'Proses reindex basis pengetahuan AI sedang berjalan.',
        ),
      );
    }

    _updateState(_state.copyWith(isReindexing: true));

    final Result<AiReindexResult> result = await _triggerReindex();

    _updateState(_state.copyWith(isReindexing: false));
    return result;
  }

  void clearConversationError() {
    if (_state.conversationError != null) {
      _updateState(_state.copyWith(conversationError: null));
    }
  }

  void clearHistoryError() {
    if (_state.historyError != null) {
      _updateState(_state.copyWith(historyError: null));
    }
  }

  List<AiConversationSummary> _upsertConversationSummary({
    required List<AiConversationSummary> existing,
    required int conversationId,
    required String title,
    required String lastMessagePreview,
    required int messageCount,
  }) {
    final DateTime now = DateTime.now();
    final AiConversationSummary updated = AiConversationSummary(
      id: conversationId,
      title: title,
      messageCount: messageCount,
      lastMessagePreview: lastMessagePreview,
      updatedAt: now,
    );
    return <AiConversationSummary>[
      updated,
      ...existing.where((AiConversationSummary c) => c.id != conversationId),
    ];
  }

  void _updateState(AiChatState next) {
    if (_disposed) {
      return;
    }
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
