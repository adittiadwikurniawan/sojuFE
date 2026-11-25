import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Kartu "Alat Cepat" pada halaman utama Hybrid RAG AI.
@immutable
class AiQuickActionItem {
  const AiQuickActionItem({
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.icon,
    required this.prompt,
    this.primary = false,
  });

  final String title;
  final String description;
  final String ctaLabel;
  final IconData icon;

  /// Prompt Bahasa Indonesia yang dikirim ke `/api/v1/ai/chat`.
  final String prompt;

  /// Kartu pertama memakai tombol biru, kartu lain abu-abu (Figma).
  final bool primary;
}

/// Deretan kartu "Alat Cepat" (frame `546:3687`, node `546:3725`).
///
/// Tiga kartu berjalan horizontal; kartu pertama memakai tombol biru seperti
/// desain, kartu lain memakai tombol abu-abu.
class ChatQuickActionCards extends StatelessWidget {
  const ChatQuickActionCards({
    super.key,
    required this.scale,
    required this.actions,
    this.onTap,
  });

  final double scale;
  final List<AiQuickActionItem> actions;
  final ValueChanged<AiQuickActionItem>? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 146 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: actions.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(width: 17 * scale),
        itemBuilder: (BuildContext context, int index) {
          final AiQuickActionItem action = actions[index];
          return _QuickActionCard(
            scale: scale,
            action: action,
            onTap: onTap == null ? null : () => onTap!(action),
          );
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.scale,
    required this.action,
    this.onTap,
  });

  final double scale;
  final AiQuickActionItem action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${action.title}. ${action.ctaLabel}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 146 * scale,
          padding: EdgeInsets.fromLTRB(
            10 * scale,
            12 * scale,
            10 * scale,
            8 * scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            borderRadius: BorderRadius.circular(21 * scale),
            border: Border.all(color: const Color(0xFFF5F5F5)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14000000),
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(action.icon, size: 19 * scale, color: Colors.black),
              SizedBox(height: 7 * scale),
              Text(
                action.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                  color: const Color(0xFF1B1B1D),
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                action.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 8.5 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 30 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: action.primary
                      ? SojuColors.primary
                      : SojuColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    action.ctaLabel,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 11.5 * scale,
                      fontWeight: FontWeight.w600,
                      color: action.primary ? Colors.white : Colors.black,
                    ),
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
