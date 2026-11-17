import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/chat_draft.dart';

/// Kartu draft pencatatan di dalam percakapan (komponen `546:4098`).
///
/// Angka total, porsi QRIS/tunai, dan label rincian berasal dari
/// [ChatDraft] sehingga tidak ada nominal ringkasan yang di-hardcode.
/// Tombol aksi hanya memicu callback; layar menampilkan pesan mode demo.
class ChatDraftCard extends StatelessWidget {
  const ChatDraftCard({
    super.key,
    required this.scale,
    required this.draft,
    this.onConfirm,
    this.onCorrect,
  });

  final double scale;
  final ChatDraft draft;
  final VoidCallback? onConfirm;
  final VoidCallback? onCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: SojuColors.hairline),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          SizedBox(height: 10 * scale),
          _buildHero(),
          SizedBox(height: 12 * scale),
          Text(
            draft.title,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF191C1E),
            ),
          ),
          SizedBox(height: 7 * scale),
          for (int index = 0; index < draft.items.length; index++) ...<Widget>[
            if (index > 0) SizedBox(height: 6 * scale),
            _DraftItemRow(scale: scale, item: draft.items[index]),
          ],
          SizedBox(height: 10 * scale),
          _buildSplit(),
          SizedBox(height: 12 * scale),
          _buildButtons(),
          SizedBox(height: 8 * scale),
          Text(
            draft.note,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 9 * scale,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: SojuColors.analyticsMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8 * scale,
            vertical: 3 * scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.draftBadge,
            borderRadius: BorderRadius.circular(100 * scale),
          ),
          child: Text(
            draft.badge,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 8.5 * scale,
              fontWeight: FontWeight.w700,
              color: SojuColors.draftBadgeInk,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Icon(
          Icons.schedule,
          size: 11 * scale,
          color: SojuColors.analyticsLabel,
        ),
        SizedBox(width: 3 * scale),
        Expanded(
          child: Text(
            draft.metaLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 8.5 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.analyticsLabel,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: SojuColors.chatSurface,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  draft.totalLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 8.5 * scale,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.analyticsLabel,
                  ),
                ),
                SizedBox(height: 2 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    draft.totalRupiah,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 19 * scale,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.cash,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
              color: SojuColors.cash,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(
              Icons.south_west,
              size: 18 * scale,
              color: const Color(0xFFF4FFF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplit() {
    const Color qrisColor = SojuColors.qris;
    const Color cashColor = SojuColors.cash;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: SojuColors.chatSurface,
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _SplitLegend(
                  scale: scale,
                  color: qrisColor,
                  label: draft.qrisLabel,
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _SplitLegend(
                  scale: scale,
                  color: cashColor,
                  label: draft.cashLabel,
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(100 * scale),
                child: SizedBox(
                  height: 7 * scale,
                  child: Row(
                    children: <Widget>[
                      if (draft.qrisTotal > 0)
                        SizedBox(
                          width: constraints.maxWidth * draft.qrisShare,
                          child: Container(color: qrisColor),
                        ),
                      if (draft.cashTotal > 0)
                        SizedBox(
                          width: constraints.maxWidth * draft.cashShare,
                          child: Container(color: cashColor),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        Semantics(
          button: true,
          child: GestureDetector(
            onTap: onConfirm,
            child: Container(
              height: 42 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SojuColors.primary,
                borderRadius: BorderRadius.circular(100 * scale),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 15 * scale,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    draft.confirmLabel,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 11.5 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 6 * scale),
        Semantics(
          button: true,
          child: GestureDetector(
            onTap: onCorrect,
            child: Container(
              height: 40 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SojuColors.hairline,
                borderRadius: BorderRadius.circular(100 * scale),
              ),
              child: Text(
                draft.correctLabel,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 10.5 * scale,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.analyticsLabel,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DraftItemRow extends StatelessWidget {
  const _DraftItemRow({required this.scale, required this.item});

  final double scale;
  final ChatDraftItem item;

  @override
  Widget build(BuildContext context) {
    final Color methodColor = item.method == ChatPaymentMethod.qris
        ? SojuColors.qris
        : SojuColors.cash;

    return Container(
      padding: EdgeInsets.all(7 * scale),
      decoration: BoxDecoration(
        color: SojuColors.draftRow,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 26 * scale,
            height: 26 * scale,
            decoration: BoxDecoration(
              color: SojuColors.hairline,
              borderRadius: BorderRadius.circular(7 * scale),
            ),
            child: Icon(
              item.icon,
              size: 14 * scale,
              color: SojuColors.badgeBlue,
            ),
          ),
          SizedBox(width: 7 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 10.5 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                SizedBox(height: 1 * scale),
                Text(
                  item.quantityLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9 * scale,
                    fontWeight: FontWeight.w400,
                    color: SojuColors.analyticsLabel,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                item.amountLabel,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 10.5 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF191C1E),
                ),
              ),
              SizedBox(height: 1 * scale),
              Text(
                item.methodLabel,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 8.5 * scale,
                  fontWeight: FontWeight.w500,
                  color: methodColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitLegend extends StatelessWidget {
  const _SplitLegend({
    required this.scale,
    required this.color,
    required this.label,
  });

  final double scale;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 7 * scale,
          height: 7 * scale,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4 * scale),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 8.5 * scale,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
