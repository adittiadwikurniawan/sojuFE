import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/chatbot_view_data.dart';

/// Bagian "Riwayat" pada halaman utama chatbot.
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
    this.onToggle,
    this.onTap,
  });

  final double scale;
  final List<ChatHistoryEntryData> entries;
  final bool expanded;
  final int collapsedCount;
  final VoidCallback? onToggle;
  final ValueChanged<ChatHistoryEntryData>? onTap;

  @override
  Widget build(BuildContext context) {
    final List<ChatHistoryEntryData> visible = expanded
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
        for (int index = 0; index < visible.length; index++) ...<Widget>[
          if (index > 0) SizedBox(height: 12 * scale),
          _HistoryRow(
            scale: scale,
            entry: visible[index],
            onTap: onTap == null ? null : () => onTap!(visible[index]),
          ),
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
  final ChatHistoryEntryData entry;
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
