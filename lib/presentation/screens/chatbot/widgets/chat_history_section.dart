import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/ai_chat_entity.dart';

/// Bagian "Riwayat" pada halaman utama chatbot (live `/api/v1/ai/conversations`).
///
/// "Lihat Semua" memperluas daftar di halaman yang sama (tanpa navigasi),
/// dari [collapsedCount] baris menjadi seluruh [entries].
class ChatHistorySection extends StatelessWidget {
  const ChatHistorySection({
    super.key,
    required this.scale,
    required this.entries,
    required this.expanded,
    this.collapsedCount = 4,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onToggle,
    this.onTap,
  });

  final double scale;
  final List<AiConversationSummary> entries;
  final bool expanded;
  final int collapsedCount;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onToggle;
  final ValueChanged<AiConversationSummary>? onTap;

  @override
  Widget build(BuildContext context) {
    final List<AiConversationSummary> visible = expanded
        ? entries
        : entries.take(collapsedCount).toList(growable: false);
    final bool canExpand = entries.length > collapsedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 40 * scale,
          child: Row(
            children: <Widget>[
              Text(
                'Riwayat',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1B1D),
                ),
              ),
              const Spacer(),
              if (canExpand)
                Semantics(
                  button: true,
                  label:
                      expanded ? 'Sembunyikan riwayat' : 'Lihat semua riwayat',
                  child: GestureDetector(
                    onTap: onToggle,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4 * scale,
                        vertical: 10 * scale,
                      ),
                      child: Text(
                        expanded ? 'Sembunyikan' : 'Lihat Semua',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.badgeBlue,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 4 * scale),
        if (isLoading && entries.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 20 * scale),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 16 * scale,
                  height: 16 * scale,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(SojuColors.primary),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Text(
                  'Memuat riwayat percakapan...',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12 * scale,
                    color: SojuColors.analyticsMuted,
                  ),
                ),
              ],
            ),
          )
        else if (errorMessage != null && entries.isEmpty)
          Container(
            padding: EdgeInsets.all(14 * scale),
            decoration: BoxDecoration(
              color: SojuColors.expenseSoft,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: SojuColors.notificationUrgentBg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  errorMessage!,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12 * scale,
                    color: SojuColors.notificationUrgentInk,
                  ),
                ),
                if (onRetry != null) ...<Widget>[
                  SizedBox(height: 8 * scale),
                  TextButton.icon(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: SojuColors.badgeBlue,
                    ),
                    icon: Icon(Icons.refresh, size: 15 * scale),
                    label: Text(
                      'Coba Lagi',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else if (visible.isEmpty)
          Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: SojuColors.surface,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: SojuColors.hairline),
            ),
            child: Text(
              'Belum ada riwayat percakapan. Tekan Tambah Chat untuk mulai bertanya ke Soju AI.',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12 * scale,
                height: 1.45,
                color: SojuColors.analyticsMuted,
              ),
            ),
          )
        else ...<Widget>[
          for (int index = 0; index < visible.length; index++) ...<Widget>[
            if (index > 0) SizedBox(height: 12 * scale),
            _HistoryRow(
              scale: scale,
              entry: visible[index],
              onTap: onTap == null ? null : () => onTap!(visible[index]),
            ),
          ],
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.scale,
    required this.entry,
    this.onTap,
  });

  final double scale;
  final AiConversationSummary entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.chatRow,
      borderRadius: BorderRadius.circular(10 * scale),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 46 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.chat_bubble_outline,
                  size: 20 * scale,
                  color: const Color(0xFF1B1B1D),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18 * scale,
                  color: const Color(0x66000000),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
