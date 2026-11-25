import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../data/data_providers.dart';
import '../../../domain/entities/ai_chat_entity.dart';
import '../../../domain/entities/auth_session_entity.dart';
import '../../providers/ai/ai_chat_controller.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'widgets/ai_citations_sheet.dart';
import 'widgets/chat_conversation_view.dart';
import 'widgets/chat_history_section.dart';
import 'widgets/chat_quick_action_cards.dart';
import 'widgets/chatbot_top_bar.dart';

/// Layar Hybrid RAG AI Admin SOJU (`TASK-028`).
///
/// Terhubung langsung ke `/api/v1/ai/chat`, `/api/v1/ai/conversations`,
/// `/api/v1/ai/conversations/:id`, `POST /api/v1/transactions` (konfirmasi
/// manual draft aksi), serta `POST /api/v1/ai/reindex` khusus `SUPER_ADMIN`.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({
    super.key,
    this.controllerFactory,
    this.currentUser,
    this.isSuperAdmin = false,
    this.onBack,
    this.onNotificationTap,
  });

  final AiChatController Function()? controllerFactory;
  final AuthUser? currentUser;
  final bool isSuperAdmin;

  /// Navigasi kembali dari halaman utama AI (mis. kembali ke Beranda).
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;

  /// Lebar desain acuan (frame Figma 430px).
  static const double _designWidth = 430;

  /// Jumlah baris riwayat saat belum diperluas.
  static const int _collapsedHistoryCount = 4;

  static const String greeting =
      'Halo! Saya siap bantu analisis data, jawab SOP, dan catat transaksi bisnis kamu hari ini';

  static const List<AiQuickActionItem> quickActions = <AiQuickActionItem>[
    AiQuickActionItem(
      title: 'Catat Penjualan',
      description: 'Buat draft transaksi penjualan cepat lewat chat AI.',
      ctaLabel: 'Catat Sales',
      icon: Icons.account_balance_wallet_outlined,
      prompt: 'Catat penjualan hari ini',
      primary: true,
    ),
    AiQuickActionItem(
      title: 'Ringkasan Omzet',
      description: 'Cek total omzet, pengeluaran, dan pesanan terbaru.',
      ctaLabel: 'Cek Omzet',
      icon: Icons.analytics_outlined,
      prompt: 'Ringkasan penjualan dan omzet hari ini',
    ),
    AiQuickActionItem(
      title: 'Tanya SOP & Produk',
      description: 'Cari panduan operasional, FAQ, dan detail produk SOJU.',
      ctaLabel: 'Tanya SOP',
      icon: Icons.menu_book_outlined,
      prompt: 'Apa saja SOP operasional SOJU?',
    ),
  ];

  static const List<String> suggestions = <String>[
    'Ringkasan penjualan hari ini',
    'Berapa omzet minggu ini?',
    'Catat penjualan bento 5 porsi tunai',
    'Bagaimana SOP penanganan komplain?',
  ];

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final AiChatController _controller;
  final TextEditingController _composerController = TextEditingController();
  bool _historyExpanded = false;

  bool get _canReindex =>
      widget.isSuperAdmin || (widget.currentUser?.role.isSuperAdmin ?? false);

  @override
  void initState() {
    super.initState();
    _controller =
        (widget.controllerFactory ?? DataProviders.createAiChatController)();
    _controller.addListener(_onControllerChanged);
    _controller.loadConversations();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _composerController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AiChatState state = _controller.state;

    return PopScope(
      canPop: !state.isInConversation,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (state.isInConversation) {
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
                      onNotificationTap: widget.onNotificationTap,
                      showReindexButton: _canReindex,
                      isReindexing: state.isReindexing,
                      onReindexTap: _handleReindexTap,
                    ),
                    Expanded(
                      child: !state.isInConversation
                          ? _buildHome(scale, state)
                          : ChatConversationView(
                              key: ValueKey<String>(
                                'chat-${state.activeConversationId ?? 'new'}',
                              ),
                              scale: scale,
                              messages: state.messages,
                              suggestions: ChatbotScreen.suggestions,
                              isLoading: state.isLoadingConversation,
                              isSending: state.isSending,
                              errorMessage: state.conversationError,
                              onDismissError: _controller.clearConversationError,
                              onSend: _handleSendMessage,
                              onCitationTap: _openCitationsSheet,
                              onConfirmDraft: _handleConfirmDraft,
                              onCorrectDraft: _handleCorrectDraft,
                              isConfirmingDraft: state.isConfirmingDraft,
                              confirmedTransactionFor:
                                  state.confirmedTransactionFor,
                              composerController: _composerController,
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

  Widget _buildHome(double scale, AiChatState state) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return RefreshIndicator(
      onRefresh: () => _controller.loadConversations(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            top: 12 * scale,
            bottom: kBottomNavBarHeight * scale + bottomInset + 24 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: Text(
                  ChatbotScreen.greeting,
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
                actions: ChatbotScreen.quickActions,
                onTap: _openQuickAction,
              ),
              SizedBox(height: 32 * scale),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: ChatHistorySection(
                  scale: scale,
                  entries: state.conversations,
                  expanded: _historyExpanded,
                  collapsedCount: ChatbotScreen._collapsedHistoryCount,
                  isLoading: state.isLoadingHistory,
                  errorMessage: state.historyError,
                  onRetry: () => _controller.loadConversations(),
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
                  onTap: () {
                    _composerController.clear();
                    _controller.startNewConversation();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQuickAction(AiQuickActionItem action) {
    _composerController.clear();
    _controller.startNewConversation();
    _controller.sendMessage(action.prompt);
  }

  void _openHistory(AiConversationSummary entry) {
    _composerController.clear();
    _controller.openConversation(entry);
  }

  void _handleSendMessage(String text) {
    _controller.sendMessage(text);
  }

  void _openCitationsSheet(List<AiCitation> citations, String selectedId) {
    showAiCitationsSheet(
      context,
      citations: citations,
      selectedCitationId: selectedId,
    );
  }

  Future<void> _handleConfirmDraft(AiActionDraft draft) async {
    final Result<AiConfirmedTransaction> result =
        await _controller.confirmDraft(draft);
    if (!mounted) {
      return;
    }
    result.fold(
      onSuccess: (AiConfirmedTransaction tx) {
        final String codeSuffix = tx.code.isEmpty ? '' : ' (${tx.code})';
        _showSnack('Transaksi berhasil disimpan$codeSuffix.');
      },
      onFailure: (AppFailure failure) {
        _showSnack(failure.message);
      },
    );
  }

  void _handleCorrectDraft(AiActionDraft draft) {
    final String prefix = 'Koreksi draft ${draft.title}: ';
    _composerController.text = prefix;
    _composerController.selection = TextSelection.collapsed(
      offset: prefix.length,
    );
    _showSnack('Silakan ubah jumlah, harga, atau rincian lalu kirim pesan.');
  }

  Future<void> _handleReindexTap() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Perbarui Indeks AI?'),
          content: const Text(
            'Proses ini akan mengindeks ulang dokumen SOP, katalog produk, '
            'dan konten CMS ke basis pengetahuan AI SOJU.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: SojuColors.primary,
              ),
              child: const Text('Jalankan Reindex'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final Result<AiReindexResult> result = await _controller.triggerReindex();
    if (!mounted) {
      return;
    }
    result.fold(
      onSuccess: (AiReindexResult data) {
        _showSnack(
          'Reindex selesai: ${data.documentsProcessed} dokumen '
          '(${data.chunksCreated} potongan teks) diperbarui.',
        );
      },
      onFailure: (AppFailure failure) {
        _showSnack(failure.message);
      },
    );
  }

  void _closeConversation() {
    _composerController.clear();
    _controller.closeConversation();
  }

  void _handleBack() {
    if (_controller.state.isInConversation) {
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
