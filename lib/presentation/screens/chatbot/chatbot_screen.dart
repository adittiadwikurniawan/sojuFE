import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../widgets/bottom_glass_overlay.dart';
import 'models/chat_draft.dart';
import 'models/chatbot_view_data.dart';
import 'widgets/chat_conversation_view.dart';
import 'widgets/chat_history_section.dart';
import 'widgets/chat_quick_action_cards.dart';
import 'widgets/chatbot_top_bar.dart';

/// Layar Chatbot Soju (frame Figma `546:3687`, `546:4198`, `546:4098`).
///
/// Halaman utama menampilkan salam, alat cepat, dan riwayat percakapan.
/// "Lihat Semua" memperluas riwayat tanpa berpindah halaman. Membuka riwayat,
/// alat cepat, atau "Tambah Chat" menampilkan percakapan di layar yang sama.
///
/// AI masih **mock**: balasan berasal dari [ChatbotViewData], tidak ada
/// pemanggilan API, dan konfirmasi draft hanya menampilkan pesan mode demo.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({
    super.key,
    this.data = ChatbotViewData.sample,
    this.onBack,
    this.onNotificationTap,
    this.onQuickAction,
    this.onHistoryTap,
    this.onSendMessage,
    this.onSuggestionTap,
    this.onDraftConfirm,
    this.onDraftCorrect,
    this.onAttach,
  });

  final ChatbotViewData data;

  /// Navigasi kembali dari halaman utama. Pemanggil dapat mengarahkan ke
  /// halaman sebelumnya atau Beranda.
  final VoidCallback? onBack;

  final VoidCallback? onNotificationTap;
  final ValueChanged<ChatQuickActionData>? onQuickAction;
  final ValueChanged<ChatHistoryEntryData>? onHistoryTap;
  final ValueChanged<String>? onSendMessage;
  final ValueChanged<ChatSuggestionData>? onSuggestionTap;
  final ValueChanged<ChatDraft>? onDraftConfirm;
  final ValueChanged<ChatDraft>? onDraftCorrect;
  final VoidCallback? onAttach;

  /// Lebar desain acuan (frame Figma 430px).
  static const double _designWidth = 430;

  /// Jumlah baris riwayat saat belum diperluas.
  static const int _collapsedHistoryCount = 4;

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  bool _historyExpanded = false;
  ChatConversationData? _activeConversation;
  List<ChatMessageData> _messages = const <ChatMessageData>[];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _activeConversation == null,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (_activeConversation != null) {
          _closeConversation();
        }
      },
      child: Scaffold(
        backgroundColor: SojuColors.homeBackground,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = math.min(constraints.maxWidth, 480);
            final double scale = width / ChatbotScreen._designWidth;
            final double topInset = MediaQuery.of(context).padding.top;

            return Center(
              child: SizedBox(
                width: width,
                child: Column(
                  children: <Widget>[
                    ChatbotTopBar(
                      scale: scale,
                      topInset: topInset,
                      onBack: _handleBack,
                      onNotificationTap: widget.onNotificationTap ??
                          () => _showSnack(
                                'Mode demo — belum ada notifikasi baru.',
                              ),
                    ),
                    Expanded(
                      child: _activeConversation == null
                          ? _buildHome(scale)
                          : ChatConversationView(
                              key: ValueKey<String>(_activeConversation!.title),
                              scale: scale,
                              messages: _messages,
                              data: widget.data,
                              onSend: _sendMessage,
                              onSuggestion: _sendSuggestion,
                              onConfirmDraft: _confirmDraft,
                              onCorrectDraft: _correctDraft,
                              onAttach: widget.onAttach ??
                                  () => _showSnack(
                                        'Mode demo — lampiran belum tersedia.',
                                      ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHome(double scale) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 12 * scale,
          bottom: kBottomContentInset * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Text(
                widget.data.greeting,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1.42,
                  color: const Color(0xFF1B1B1D),
                ),
              ),
            ),
            SizedBox(height: 18 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Text(
                'Alat Cepat',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1B1D),
                ),
              ),
            ),
            SizedBox(height: 10 * scale),
            ChatQuickActionCards(
              scale: scale,
              actions: widget.data.quickActions,
              onTap: _openQuickAction,
            ),
            SizedBox(height: 32 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: ChatHistorySection(
                scale: scale,
                entries: widget.data.history,
                expanded: _historyExpanded,
                collapsedCount: ChatbotScreen._collapsedHistoryCount,
                onToggle: () {
                  setState(() {
                    _historyExpanded = !_historyExpanded;
                  });
                },
                onTap: _openHistory,
              ),
            ),
            SizedBox(height: 16 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: _TambahChatButton(
                scale: scale,
                onTap: () => _startConversation(null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openQuickAction(ChatQuickActionData action) {
    widget.onQuickAction?.call(action);
    _startConversation(action.conversation);
  }

  void _openHistory(ChatHistoryEntryData entry) {
    widget.onHistoryTap?.call(entry);
    _startConversation(entry.conversation);
  }

  void _startConversation(ChatConversationData? conversation) {
    final String time = _currentTimeLabel();
    setState(() {
      if (conversation == null) {
        _messages = <ChatMessageData>[
          ChatMessageData(
            author: ChatAuthor.assistant,
            text: widget.data.newChatGreeting,
            timeLabel: time,
          ),
        ];
        _activeConversation = const ChatConversationData(
          title: 'Chat Baru',
          messages: <ChatMessageData>[],
        );
      } else {
        _messages = List<ChatMessageData>.of(conversation.messages);
        _activeConversation = conversation;
      }
    });
  }

  void _sendMessage(String text) {
    final String time = _currentTimeLabel();
    setState(() {
      _messages = <ChatMessageData>[
        ..._messages,
        ChatMessageData(
          author: ChatAuthor.user,
          text: text,
          timeLabel: time,
        ),
        ChatMessageData(
          author: ChatAuthor.assistant,
          text: widget.data.demoReply,
          timeLabel: time,
        ),
      ];
    });
    widget.onSendMessage?.call(text);
  }

  void _sendSuggestion(ChatSuggestionData suggestion) {
    final String time = _currentTimeLabel();
    setState(() {
      _messages = <ChatMessageData>[
        ..._messages,
        ChatMessageData(
          author: ChatAuthor.user,
          text: suggestion.label,
          timeLabel: time,
        ),
        ChatMessageData(
          author: ChatAuthor.assistant,
          text: suggestion.reply,
          timeLabel: time,
        ),
      ];
    });
    widget.onSuggestionTap?.call(suggestion);
  }

  void _confirmDraft(ChatDraft draft) {
    widget.onDraftConfirm?.call(draft);
    _showSnack(widget.data.confirmDemoMessage);
  }

  void _correctDraft(ChatDraft draft) {
    widget.onDraftCorrect?.call(draft);
    _showSnack(widget.data.correctDemoMessage);
  }

  void _closeConversation() {
    setState(() {
      _activeConversation = null;
      _messages = const <ChatMessageData>[];
    });
  }

  void _handleBack() {
    if (_activeConversation != null) {
      _closeConversation();
      return;
    }
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _showSnack(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _currentTimeLabel() {
    final DateTime now = DateTime.now();
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TambahChatButton extends StatelessWidget {
  const _TambahChatButton({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SojuColors.primary,
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Text(
            'Tambah Chat',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
