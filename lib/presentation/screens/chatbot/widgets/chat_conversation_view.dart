import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/ai_chat_entity.dart';
import '../models/chat_draft.dart';
import 'chat_draft_card.dart';

/// Tampilan percakapan Hybrid RAG AI SOJU (frame `546:4198`).
///
/// Menampilkan riwayat pesan live, badge jalur RAG, chip sitasi interaktif,
/// kartu draft aksi dengan konfirmasi manual, saran pertanyaan, dan composer.
class ChatConversationView extends StatefulWidget {
  const ChatConversationView({
    super.key,
    required this.scale,
    required this.messages,
    required this.suggestions,
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.onDismissError,
    this.onSend,
    this.onCitationTap,
    this.onConfirmDraft,
    this.onCorrectDraft,
    this.isConfirmingDraft,
    this.confirmedTransactionFor,
    this.composerController,
  });

  final double scale;
  final List<AiMessage> messages;
  final List<String> suggestions;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final VoidCallback? onDismissError;
  final ValueChanged<String>? onSend;
  final void Function(List<AiCitation> citations, String selectedId)?
      onCitationTap;
  final ValueChanged<AiActionDraft>? onConfirmDraft;
  final ValueChanged<AiActionDraft>? onCorrectDraft;
  final bool Function(String draftId)? isConfirmingDraft;
  final AiConfirmedTransaction? Function(String draftId)?
      confirmedTransactionFor;
  final TextEditingController? composerController;

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  TextEditingController? _internalController;
  final ScrollController _scroll = ScrollController();

  TextEditingController get _controller =>
      widget.composerController ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(ChatConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length ||
        widget.isSending != oldWidget.isSending) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) {
        return;
      }
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _submit() {
    if (widget.isSending) {
      return;
    }
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    widget.onSend?.call(text);
    _controller.clear();
    _scrollToBottom();
  }

  String? _formatTime(DateTime? dt) {
    if (dt == null) return null;
    final DateTime local = dt.toLocal();
    final String h = local.hour.toString().padLeft(2, '0');
    final String m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUserMessage = widget.messages.any(
      (AiMessage message) => message.author == AiMessageAuthor.user,
    );

    return Column(
      children: <Widget>[
        Expanded(
          child: widget.isLoading && widget.messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(SojuColors.primary),
                      ),
                      SizedBox(height: 12 * widget.scale),
                      Text(
                        'Memuat percakapan...',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12.5 * widget.scale,
                          color: SojuColors.analyticsMuted,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(
                    16 * widget.scale,
                    12 * widget.scale,
                    16 * widget.scale,
                    16 * widget.scale,
                  ),
                  children: <Widget>[
                    if (widget.errorMessage != null) ...<Widget>[
                      _ErrorBanner(
                        scale: widget.scale,
                        message: widget.errorMessage!,
                        onDismiss: widget.onDismissError,
                      ),
                      SizedBox(height: 12 * widget.scale),
                    ],
                    if (widget.messages.isEmpty)
                      _buildWelcomeBubble()
                    else
                      for (int index = 0;
                          index < widget.messages.length;
                          index++) ...<Widget>[
                        if (index > 0) SizedBox(height: 14 * widget.scale),
                        _buildMessage(index),
                      ],
                    if (widget.isSending) ...<Widget>[
                      SizedBox(height: 14 * widget.scale),
                      _buildThinkingBubble(),
                    ],
                    if (!hasUserMessage && !widget.isSending) ...<Widget>[
                      SizedBox(height: 18 * widget.scale),
                      _buildSuggestions(),
                    ],
                  ],
                ),
        ),
        _buildComposer(),
      ],
    );
  }

  Widget _buildWelcomeBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AiIdentity(
          scale: widget.scale,
          name: 'Soju AI',
          tagline: 'Asisten Hybrid RAG',
        ),
        SizedBox(height: 5 * widget.scale),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 13 * widget.scale,
            vertical: 10 * widget.scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            border: Border.all(color: SojuColors.hairline),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(4),
              topRight: Radius.circular(16 * widget.scale),
              bottomLeft: Radius.circular(16 * widget.scale),
              bottomRight: Radius.circular(16 * widget.scale),
            ),
          ),
          child: Text(
            'Halo! Saya Soju AI. Tanyakan ringkasan penjualan, SOP & katalog '
            'produk, atau minta saya siapkan draft transaksi hari ini.',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12.5 * widget.scale,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF191C1E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThinkingBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AiIdentity(
          scale: widget.scale,
          name: 'Soju AI',
          tagline: 'Asisten Hybrid RAG',
        ),
        SizedBox(height: 5 * widget.scale),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 13 * widget.scale,
            vertical: 10 * widget.scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            border: Border.all(color: SojuColors.hairline),
            borderRadius: BorderRadius.circular(16 * widget.scale),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 14 * widget.scale,
                height: 14 * widget.scale,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(SojuColors.primary),
                ),
              ),
              SizedBox(width: 8 * widget.scale),
              Text(
                'Soju AI sedang memproses...',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * widget.scale,
                  color: SojuColors.analyticsMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(int index) {
    final AiMessage message = widget.messages[index];
    final String? timeLabel = _formatTime(message.createdAt);
    final bool showIdentity = message.author != AiMessageAuthor.user &&
        (index == 0 ||
            widget.messages[index - 1].author == AiMessageAuthor.user);

    if (message.author == AiMessageAuthor.user) {
      return Align(
        alignment: Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: 0.82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 13 * widget.scale,
                  vertical: 10 * widget.scale,
                ),
                decoration: BoxDecoration(
                  color: SojuColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16 * widget.scale),
                    topRight: Radius.circular(16 * widget.scale),
                    bottomLeft: Radius.circular(16 * widget.scale),
                    bottomRight: Radius.circular(4 * widget.scale),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12.5 * widget.scale,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: const Color(0xFFFEFBFF),
                  ),
                ),
              ),
              if (timeLabel != null) ...<Widget>[
                SizedBox(height: 3 * widget.scale),
                Text(
                  timeLabel,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9 * widget.scale,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.analyticsLabel,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final bool isRefusal = message.routePath == AiRoutePath.refusal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showIdentity) ...<Widget>[
          _AiIdentity(
            scale: widget.scale,
            name: 'Soju AI',
            tagline: 'Asisten Hybrid RAG',
            routePath: message.routePath,
            timeLabel: timeLabel,
          ),
          SizedBox(height: 5 * widget.scale),
        ],
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 13 * widget.scale,
            vertical: 10 * widget.scale,
          ),
          decoration: BoxDecoration(
            color: isRefusal ? SojuColors.demoSoft : SojuColors.surface,
            border: Border.all(
              color: isRefusal ? SojuColors.demoBorder : SojuColors.hairline,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(showIdentity ? 4 : 16 * widget.scale),
              topRight: Radius.circular(16 * widget.scale),
              bottomLeft: Radius.circular(16 * widget.scale),
              bottomRight: Radius.circular(16 * widget.scale),
            ),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12.5 * widget.scale,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: isRefusal ? SojuColors.demoInk : const Color(0xFF191C1E),
            ),
          ),
        ),
        if (message.citations.isNotEmpty) ...<Widget>[
          SizedBox(height: 8 * widget.scale),
          Wrap(
            spacing: 6 * widget.scale,
            runSpacing: 6 * widget.scale,
            children: <Widget>[
              for (final AiCitation citation in message.citations)
                _CitationChip(
                  key: Key('ai_citation_chip_${citation.id}'),
                  scale: widget.scale,
                  citation: citation,
                  onTap: widget.onCitationTap == null
                      ? null
                      : () =>
                          widget.onCitationTap!(message.citations, citation.id),
                ),
            ],
          ),
        ],
        for (final AiActionDraft action in message.actions) ...<Widget>[
          SizedBox(height: 8 * widget.scale),
          _buildDraftCard(action),
        ],
      ],
    );
  }

  Widget _buildDraftCard(AiActionDraft action) {
    final AiConfirmedTransaction? confirmed =
        widget.confirmedTransactionFor?.call(action.id);
    final bool isConfirming =
        widget.isConfirmingDraft?.call(action.id) ?? false;
    final String arah = (action.payload['arah'] ?? '').toString().toUpperCase();
    final bool isExpense =
        action.intent.toUpperCase() == 'PEMBELIAN' || arah == 'PENGELUARAN';

    return ChatDraftCard(
      key: Key('ai_draft_card_${action.id}'),
      scale: widget.scale,
      draft: ChatDraft.fromActionDraft(action),
      summaryRows: action.summaryRows,
      totalAmountOverride: action.totalAmount,
      isExpense: isExpense,
      isConfirming: isConfirming,
      isConfirmed: confirmed != null,
      confirmedCode: confirmed?.code,
      canConfirm: action.isReadyToConfirm,
      missingFields: action.missingFields,
      onConfirm: widget.onConfirmDraft == null
          ? null
          : () => widget.onConfirmDraft!(action),
      onCorrect: widget.onCorrectDraft == null
          ? null
          : () => widget.onCorrectDraft!(action),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Coba tanyakan',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 10.5 * widget.scale,
            fontWeight: FontWeight.w600,
            color: SojuColors.analyticsMuted,
          ),
        ),
        SizedBox(height: 7 * widget.scale),
        Wrap(
          spacing: 8 * widget.scale,
          runSpacing: 8 * widget.scale,
          children: <Widget>[
            for (final String suggestion in widget.suggestions)
              _SuggestionChip(
                scale: widget.scale,
                label: suggestion,
                onTap: widget.onSend == null || widget.isSending
                    ? null
                    : () => widget.onSend!(suggestion),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildComposer() {
    return Container(
      key: const Key('chat_composer'),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24 * widget.scale),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12 * widget.scale,
          10 * widget.scale,
          12 * widget.scale,
          12 * widget.scale,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !widget.isSending,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * widget.scale,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF191C1E),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: SojuColors.chatSurface,
                  hintText:
                      'Tanya omzet, SOP, atau ketik catatan transaksi...',
                  hintMaxLines: 2,
                  hintStyle: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12 * widget.scale,
                    fontWeight: FontWeight.w400,
                    color: SojuColors.analyticsMuted,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14 * widget.scale,
                    vertical: 11 * widget.scale,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22 * widget.scale),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * widget.scale),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (
                BuildContext context,
                TextEditingValue value,
                Widget? child,
              ) {
                final bool enabled =
                    !widget.isSending && value.text.trim().isNotEmpty;
                return Semantics(
                  button: true,
                  label: 'Kirim pesan',
                  child: GestureDetector(
                    onTap: widget.isSending ? null : _submit,
                    child: Container(
                      width: 40 * widget.scale,
                      height: 40 * widget.scale,
                      decoration: BoxDecoration(
                        color:
                            enabled ? SojuColors.primary : SojuColors.hairline,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        size: 18 * widget.scale,
                        color:
                            enabled ? Colors.white : SojuColors.analyticsMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AiIdentity extends StatelessWidget {
  const _AiIdentity({
    required this.scale,
    required this.name,
    required this.tagline,
    this.routePath,
    this.timeLabel,
  });

  final double scale;
  final String name;
  final String tagline;
  final AiRoutePath? routePath;
  final String? timeLabel;

  @override
  Widget build(BuildContext context) {
    final bool showBadge =
        routePath != null && routePath != AiRoutePath.unknown;

    return Row(
      children: <Widget>[
        Image.asset(
          'assets/images/ai_sparkle.png',
          width: 16 * scale,
          height: 16 * scale,
          fit: BoxFit.contain,
        ),
        SizedBox(width: 4 * scale),
        Text(
          name,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 10.5 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191C1E),
          ),
        ),
        SizedBox(width: 5 * scale),
        if (showBadge)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6 * scale,
              vertical: 2 * scale,
            ),
            decoration: BoxDecoration(
              color: routePath == AiRoutePath.refusal
                  ? SojuColors.demoSoft
                  : SojuColors.infoSoft,
              borderRadius: BorderRadius.circular(100 * scale),
            ),
            child: Text(
              routePath!.labelId,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 8.5 * scale,
                fontWeight: FontWeight.w600,
                color: routePath == AiRoutePath.refusal
                    ? SojuColors.demoInk
                    : SojuColors.badgeBlue,
              ),
            ),
          )
        else
          Text(
            tagline,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 9 * scale,
              fontWeight: FontWeight.w400,
              color: SojuColors.analyticsMuted,
            ),
          ),
        const Spacer(),
        if (timeLabel != null)
          Text(
            timeLabel!,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 9 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.analyticsMuted,
            ),
          ),
      ],
    );
  }
}

class _CitationChip extends StatelessWidget {
  const _CitationChip({
    super.key,
    required this.scale,
    required this.citation,
    this.onTap,
  });

  final double scale;
  final AiCitation citation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Lihat sumber ${citation.chipLabel} ${citation.title}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100 * scale),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10 * scale,
            vertical: 5 * scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.infoSoft,
            borderRadius: BorderRadius.circular(100 * scale),
            border: Border.all(color: SojuColors.freeTableBlueBorder60),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                citation.isSqlTool
                    ? Icons.table_chart_outlined
                    : Icons.description_outlined,
                size: 12 * scale,
                color: SojuColors.badgeBlue,
              ),
              SizedBox(width: 4 * scale),
              Flexible(
                child: Text(
                  '${citation.chipLabel} ${citation.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.badgeBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.scale,
    required this.message,
    this.onDismiss,
  });

  final double scale;
  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 9 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.expenseSoft,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: SojuColors.notificationUrgentBg),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 16 * scale,
            color: SojuColors.notificationUrgent,
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 11 * scale,
                fontWeight: FontWeight.w500,
                color: SojuColors.notificationUrgentInk,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 16 * scale,
                color: SojuColors.notificationUrgentInk,
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.scale,
    required this.label,
    this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 8 * scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            borderRadius: BorderRadius.circular(100 * scale),
            border: Border.all(color: SojuColors.hairline),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 10.5 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.badgeBlue,
            ),
          ),
        ),
      ),
    );
  }
}
