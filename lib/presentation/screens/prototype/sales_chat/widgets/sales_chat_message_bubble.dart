import 'package:flutter/material.dart';

import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/soju_colors.dart';
import '../../../../../domain/entities/sales_chat_entity.dart';
import '../../../../providers/sales_chat/sales_chat_controller.dart';
import 'sales_draft_card.dart';

/// Satu pesan pada prototype chat penjualan.
class SalesChatMessageBubble extends StatelessWidget {
  const SalesChatMessageBubble({
    super.key,
    required this.scale,
    required this.message,
    this.onCorrect,
    this.onConfirm,
    this.isSimulationComplete = false,
    this.simulationMessage,
    this.errorMessage,
  });

  final double scale;
  final SalesChatMessage message;
  final ValueChanged<SalesChatDraft>? onCorrect;
  final VoidCallback? onConfirm;
  final bool isSimulationComplete;
  final String? simulationMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (message.author == SalesChatAuthor.user) {
      return _UserBubble(scale: scale, message: message);
    }
    return _AssistantBubble(
      scale: scale,
      message: message,
      onCorrect: onCorrect,
      onConfirm: onConfirm,
      isSimulationComplete: isSimulationComplete,
      simulationMessage: simulationMessage,
      errorMessage: errorMessage,
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.scale, required this.message});

  final double scale;
  final SalesChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 13 * scale,
                vertical: 10 * scale,
              ),
              decoration: BoxDecoration(
                color: SojuColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16 * scale),
                  topRight: Radius.circular(16 * scale),
                  bottomLeft: Radius.circular(16 * scale),
                  bottomRight: Radius.circular(4 * scale),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: const Color(0xFFFEFBFF),
                ),
              ),
            ),
            SizedBox(height: 3 * scale),
            Text(
              message.timeLabel,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 9 * scale,
                fontWeight: FontWeight.w600,
                color: SojuColors.analyticsLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({
    required this.scale,
    required this.message,
    this.onCorrect,
    this.onConfirm,
    this.isSimulationComplete = false,
    this.simulationMessage,
    this.errorMessage,
  });

  final double scale;
  final SalesChatMessage message;
  final ValueChanged<SalesChatDraft>? onCorrect;
  final VoidCallback? onConfirm;
  final bool isSimulationComplete;
  final String? simulationMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.asset(
              'assets/images/ai_sparkle.png',
              width: 15 * scale,
              height: 15 * scale,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 4 * scale),
            Text(
              'Soju',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 10.5 * scale,
                fontWeight: FontWeight.w700,
                color: SojuColors.notificationTitle,
              ),
            ),
            SizedBox(width: 5 * scale),
            Text(
              'Asisten dapur',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 9 * scale,
                fontWeight: FontWeight.w400,
                color: SojuColors.analyticsMuted,
              ),
            ),
            const Spacer(),
            Text(
              message.timeLabel,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 9 * scale,
                fontWeight: FontWeight.w600,
                color: SojuColors.analyticsMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: 5 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 13 * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            border: Border.all(color: SojuColors.hairline),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4 * scale),
              topRight: Radius.circular(16 * scale),
              bottomLeft: Radius.circular(16 * scale),
              bottomRight: Radius.circular(16 * scale),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF191C1E),
            ),
          ),
        ),
        if (message.draft != null) ...<Widget>[
          SizedBox(height: 8 * scale),
          SalesDraftCard(
            scale: scale,
            draft: message.draft!,
            onCorrect:
                onCorrect == null ? null : () => onCorrect!(message.draft!),
            onConfirm: onConfirm,
            isSimulationComplete: isSimulationComplete,
            simulationMessage: simulationMessage,
            errorMessage: errorMessage,
          ),
        ],
      ],
    );
  }
}
