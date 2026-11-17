import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/dashboard_view_data.dart';

/// Kartu asisten AI "Tanya BukuKita AI" (frame `546:1616`, node
/// `546:1617`): judul gradien, pil perintah cepat, dan kotak input.
class AiAssistantCard extends StatelessWidget {
  const AiAssistantCard({
    super.key,
    required this.scale,
    required this.data,
    this.onQuickCommand,
    this.onSubmit,
  });

  final double scale;
  final AssistantCardData data;

  /// Dipanggil saat salah satu pil perintah cepat ditekan.
  final ValueChanged<AssistantCommandData>? onQuickCommand;

  /// Dipanggil saat isi kotak input dikirim.
  final ValueChanged<String>? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 202 * scale,
      padding: EdgeInsets.fromLTRB(
        34 * scale,
        19 * scale,
        16 * scale,
        13 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(30 * scale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                'assets/images/ai_sparkle.png',
                width: 27 * scale,
                height: 24.3 * scale,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) =>
                      SojuColors.aiTitle.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.wordmarkFamily,
                      fontSize: 21 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5 * scale),
          SizedBox(
            width: 251 * scale,
            child: Text(
              data.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.wordmarkFamily,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w400,
                height: 1.63,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 5 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < data.quickCommands.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(width: 11 * scale),
                  _Pill(
                    scale: scale,
                    command: data.quickCommands[i],
                    background: i == 0 ? SojuColors.pill : SojuColors.field,
                    onTap: onQuickCommand,
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          _CommandInput(
            scale: scale,
            hint: data.inputHint,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.scale,
    required this.command,
    required this.background,
    this.onTap,
  });

  final double scale;
  final AssistantCommandData command;
  final Color background;
  final ValueChanged<AssistantCommandData>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(command),
      child: Container(
        height: 32 * scale,
        padding: EdgeInsets.symmetric(horizontal: 9.1 * scale),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(100 * scale),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(command.icon, size: 13 * scale, color: Colors.black),
            SizedBox(width: 4.6 * scale),
            Text(
              command.label,
              style: TextStyle(
                fontFamily: AppTypography.wordmarkFamily,
                fontSize: command.labelSize * scale,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandInput extends StatefulWidget {
  const _CommandInput({
    required this.scale,
    required this.hint,
    this.onSubmit,
  });

  final double scale;
  final String hint;
  final ValueChanged<String>? onSubmit;

  @override
  State<_CommandInput> createState() => _CommandInputState();
}

class _CommandInputState extends State<_CommandInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    widget.onSubmit?.call(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37 * widget.scale,
      padding: EdgeInsets.symmetric(horizontal: 9.1 * widget.scale),
      decoration: BoxDecoration(
        gradient: SojuColors.aiInput,
        borderRadius: BorderRadius.circular(30 * widget.scale),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.mic_none,
            size: 15 * widget.scale,
            color: Colors.white,
          ),
          SizedBox(width: 4.6 * widget.scale),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12 * widget.scale,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * widget.scale,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.6 * widget.scale),
          GestureDetector(
            onTap: _submit,
            child: Icon(
              Icons.send,
              size: 12 * widget.scale,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
