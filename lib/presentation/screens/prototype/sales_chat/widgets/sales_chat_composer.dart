import 'package:flutter/material.dart';

import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/soju_colors.dart';

/// Composer prototype chat penjualan.
///
/// Satu kartu solid tanpa glassmorphism. Tinggi dijaga ringkas agar area
/// percakapan tetap luas dan composer tidak tertutup keyboard.
class SalesChatComposer extends StatefulWidget {
  const SalesChatComposer({
    super.key,
    required this.scale,
    this.onSend,
    this.isSending = false,
  });

  final double scale;
  final ValueChanged<String>? onSend;
  final bool isSending;

  @override
  State<SalesChatComposer> createState() => _SalesChatComposerState();
}

class _SalesChatComposerState extends State<SalesChatComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) {
      return;
    }
    widget.onSend?.call(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sales_chat_composer'),
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        border: Border(
          top: BorderSide(color: SojuColors.hairline, width: 0.8),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12 * widget.scale,
            9 * widget.scale,
            12 * widget.scale,
            9 * widget.scale,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: const Key('sales_chat_input'),
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
                    color: SojuColors.notificationTitle,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: SojuColors.chatSurface,
                    hintText:
                        'Tempel rekap penjualan atau chat pesanan WhatsApp',
                    hintMaxLines: 2,
                    hintStyle: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 11.5 * widget.scale,
                      fontWeight: FontWeight.w400,
                      color: SojuColors.analyticsMuted,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14 * widget.scale,
                      vertical: 12 * widget.scale,
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
                      value.text.trim().isNotEmpty && !widget.isSending;
                  return Semantics(
                    button: true,
                    enabled: enabled,
                    label: 'Kirim pesan',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: enabled ? _submit : null,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          key: const Key('sales_chat_send'),
                          width: 42 * widget.scale,
                          height: 42 * widget.scale,
                          decoration: BoxDecoration(
                            color: enabled
                                ? SojuColors.primary
                                : SojuColors.hairline,
                            shape: BoxShape.circle,
                          ),
                          child: widget.isSending
                              ? Padding(
                                  padding: EdgeInsets.all(11 * widget.scale),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: SojuColors.surface,
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 19 * widget.scale,
                                  color: enabled
                                      ? SojuColors.surface
                                      : SojuColors.analyticsMuted,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
