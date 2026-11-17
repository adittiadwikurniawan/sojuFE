import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/analytics_format.dart';
import '../models/analytics_summary.dart';
import '../models/analytics_transaction.dart';
import 'category_icon.dart';

/// Kartu rincian per kategori dengan isi yang bisa dilipat (frame `546:2937`,
/// node `546:3074` dan `546:3124`).
class CategoryBreakdownCard extends StatefulWidget {
  const CategoryBreakdownCard({
    super.key,
    required this.scale,
    required this.type,
    required this.items,
    required this.total,
    this.initiallyExpanded = true,
  });

  final double scale;
  final TransactionType type;
  final List<CategoryTotal> items;

  /// Total nominal untuk [type]; dasar persentase tiap kategori.
  final double total;

  final bool initiallyExpanded;

  @override
  State<CategoryBreakdownCard> createState() => _CategoryBreakdownCardState();
}

class _CategoryBreakdownCardState extends State<CategoryBreakdownCard> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _isIncome => widget.type == TransactionType.income;

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale;
    final Color accent = _isIncome ? SojuColors.chartGreen : SojuColors.expense;

    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              color: _isIncome ? SojuColors.incomeSoft : SojuColors.expenseSoft,
              padding: EdgeInsets.all(18 * scale),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 34 * scale,
                    height: 34 * scale,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isIncome
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      size: 18 * scale,
                      color: SojuColors.surface,
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _isIncome ? 'Sumber Pemasukan' : 'Sumber Pengeluaran',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.wordmarkFamily,
                            fontSize: 15.5 * scale,
                            fontWeight: FontWeight.w600,
                            color: SojuColors.analyticsTitle,
                          ),
                        ),
                        SizedBox(height: 2 * scale),
                        Text(
                          '${widget.items.length} '
                          '${_isIncome ? 'Aliran Dana' : 'Pos Anggaran'}',
                          style: TextStyle(
                            fontFamily: AppTypography.wordmarkFamily,
                            fontSize: 13.3 * scale,
                            fontWeight: FontWeight.w400,
                            color: SojuColors.analyticsLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    formatRupiah(
                      _isIncome ? widget.total : -widget.total,
                      withSign: !_isIncome,
                    ),
                    style: TextStyle(
                      fontFamily: AppTypography.wordmarkFamily,
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18 * scale,
                    color: SojuColors.analyticsLabel,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: EdgeInsets.all(18 * scale),
                    child: Column(
                      children: <Widget>[
                        for (int index = 0;
                            index < widget.items.length;
                            index++) ...<Widget>[
                          if (index > 0) SizedBox(height: 17.75 * scale),
                          _CategoryItem(
                            scale: scale,
                            item: widget.items[index],
                            total: widget.total,
                            accent: accent,
                          ),
                        ],
                        if (widget.items.isEmpty)
                          Text(
                            'Belum ada transaksi pada kategori ini',
                            style: TextStyle(
                              fontFamily: AppTypography.wordmarkFamily,
                              fontSize: 12.5 * scale,
                              color: SojuColors.analyticsMuted,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.scale,
    required this.item,
    required this.total,
    required this.accent,
  });

  final double scale;
  final CategoryTotal item;
  final double total;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final double share = item.shareOf(total);
    final double percent = share * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              categoryIconFor(item.category, item.type),
              size: 16 * scale,
              color: accent,
            ),
            SizedBox(width: 9 * scale),
            Expanded(
              child: Text(
                item.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.wordmarkFamily,
                  fontSize: 13.3 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF191C1E),
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              formatRupiah(item.amount),
              style: TextStyle(
                fontFamily: AppTypography.wordmarkFamily,
                fontSize: 13.3 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF191C1E),
              ),
            ),
            SizedBox(width: 7 * scale),
            Text(
              '(${percent.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontFamily: AppTypography.wordmarkFamily,
                fontSize: 11.1 * scale,
                fontWeight: FontWeight.w600,
                color: SojuColors.hint,
              ),
            ),
          ],
        ),
        SizedBox(height: 7 * scale),
        ClipRRect(
          borderRadius: BorderRadius.circular(5 * scale),
          child: Stack(
            children: <Widget>[
              Container(
                height: 9 * scale,
                color: SojuColors.track,
              ),
              FractionallySizedBox(
                widthFactor: share.clamp(0, 1),
                child: Container(
                  height: 9 * scale,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(5 * scale),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
