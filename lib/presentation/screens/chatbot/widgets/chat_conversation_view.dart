import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/chat_draft.dart';
import '../models/chatbot_view_data.dart';
import 'chat_draft_card.dart';

/// Tampilan percakapan Chatbot Soju (frame `546:4198`).
///
/// Menampilkan riwayat pesan, draft pencatatan, saran cepat, dan composer.
/// Pesan asisten tetap mock: layar hanya menampilkan data dari
/// [ChatbotViewData] dan meneruskan aksi lewat callback.
class ChatConversationView extends StatefulWidget {
  const ChatConversationView({
    super.key,
    required this.scale,
    required this.messages,
    required this.data,
    this.onSend,
    this.onSuggestion,
    this.onConfirmDraft,
    this.onCorrectDraft,
    this.onAttach,
  });

  final double scale;
  final List<ChatMessageData> messages;
  final ChatbotViewData data;
  final ValueChanged<String>? onSend;
  final ValueChanged<ChatSuggestionData>? onSuggestion;
  final ValueChanged<ChatDraft>? onConfirmDraft;
  final ValueChanged<ChatDraft>? onCorrectDraft;
  final VoidCallback? onAttach;

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(ChatConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    widget.onSend?.call(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUserMessage = widget.messages.any(
      (ChatMessageData message) => message.author == ChatAuthor.user,
    );

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(
              16 * widget.scale,
              12 * widget.scale,
              16 * widget.scale,
              16 * widget.scale,
            ),
            children: <Widget>[
              _DemoNotice(scale: widget.scale, text: widget.data.demoNotice),
              SizedBox(height: 14 * widget.scale),
              for (int index = 0;
                  index < widget.messages.length;
                  index++) ...<Widget>[
                if (index > 0) SizedBox(height: 14 * widget.scale),
                _buildMessage(index),
              ],
              if (!hasUserMessage) ...<Widget>[
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

  Widget _buildMessage(int index) {
    final ChatMessageData message = widget.messages[index];
    final bool showIdentity = message.author == ChatAuthor.assistant &&
        (index == 0 || widget.messages[index - 1].author == ChatAuthor.user);

    if (message.author == ChatAuthor.user) {
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
                  message.text,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12.5 * widget.scale,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: const Color(0xFFFEFBFF),
                  ),
                ),
              ),
              if (message.timeLabel != null) ...<Widget>[
                SizedBox(height: 3 * widget.scale),
                Text(
                  message.timeLabel!,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showIdentity) ...<Widget>[
          _AiIdentity(
            scale: widget.scale,
            name: widget.data.aiName,
            tagline: widget.data.aiTagline,
            timeLabel: message.timeLabel,
          ),
          SizedBox(height: 5 * widget.scale),
        ],
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 13 * widget.scale,
            vertical: 10 * widget.scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            border: Border.all(color: SojuColors.hairline),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(showIdentity ? 4 : 16 * widget.scale),
              topRight: Radius.circular(16 * widget.scale),
              bottomLeft: Radius.circular(16 * widget.scale),
              bottomRight: Radius.circular(16 * widget.scale),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12.5 * widget.scale,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF191C1E),
            ),
          ),
        ),
        if (message.draft != null) ...<Widget>[
          SizedBox(height: 8 * widget.scale),
          ChatDraftCard(
            scale: widget.scale,
            draft: message.draft!,
            onConfirm: widget.onConfirmDraft == null
                ? null
                : () => widget.onConfirmDraft!(message.draft!),
            onCorrect: widget.onCorrectDraft == null
                ? null
                : () => widget.onCorrectDraft!(message.draft!),
          ),
        ],
      ],
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
            for (final ChatSuggestionData suggestion in widget.data.suggestions)
              _SuggestionChip(
                scale: widget.scale,
                label: suggestion.label,
                onTap: widget.onSuggestion == null
                    ? null
                    : () => widget.onSuggestion!(suggestion),
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
            Semantics(
              button: true,
              label: 'Lampiran',
              child: GestureDetector(
                onTap: widget.onAttach,
                child: Container(
                  width: 40 * widget.scale,
                  height: 40 * widget.scale,
                  decoration: const BoxDecoration(
                    color: SojuColors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.attach_file,
                    size: 19 * widget.scale,
                    color: SojuColors.analyticsLabel,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * widget.scale),
            Expanded(
              child: TextField(
                controller: _controller,
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
                      'Ketik perintah atau tempel chat pesanan WhatsApp...',
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
                final bool enabled = value.text.trim().isNotEmpty;
                return Semantics(
                  button: true,
                  label: 'Kirim pesan',
                  child: GestureDetector(
                    onTap: _submit,
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
    this.timeLabel,
  });

  final double scale;
  final String name;
  final String tagline;
  final String? timeLabel;

  @override
  Widget build(BuildContext context) {
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

class _DemoNotice extends StatelessWidget {
  const _DemoNotice({required this.scale, required this.text});

  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.demoSoft,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: SojuColors.demoBorder),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 14 * scale,
            color: SojuColors.demoInk,
          ),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 10 * scale,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: SojuColors.demoInk,
              ),
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
