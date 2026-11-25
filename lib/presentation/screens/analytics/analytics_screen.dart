import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../providers/transactions/transactions_controller.dart';
import '../../widgets/activity_tile.dart';
import '../../widgets/bar_chart_card.dart';
import '../../widgets/bottom_glass_overlay.dart';
import '../../widgets/date_filter_card.dart';
import '../../widgets/soju_date_calendar_sheet.dart';
import '../dashboard/models/dashboard_view_data.dart';
import 'models/analytics_export_request.dart';
import 'models/analytics_filter.dart';
import 'models/analytics_format.dart';
import 'models/analytics_summary.dart';
import 'models/analytics_transaction.dart';
import 'models/analytics_view_data.dart';
import 'widgets/analytics_filter_chips.dart';
import 'widgets/analytics_search_bar.dart';
import 'widgets/analytics_top_bar.dart';
import 'widgets/cash_flow_donut_card.dart';
import 'widgets/category_breakdown_card.dart';
import 'widgets/category_icon.dart';
import 'widgets/summary_hero_card.dart';
import 'widgets/transaction_tile.dart';

/// Layar Analytics (frame Figma `546:2937`).
///
/// Menampilkan ringkasan pemasukan/pengeluaran, proporsi arus kas, tren
/// harian, rincian per kategori, dan daftar transaksi yang diinput. Semua
/// angka dihitung dari [AnalyticsViewData] + [AnalyticsFilter], sehingga
/// pemetaan DTO API cukup menghasilkan model tampilan ini.
///
/// Bila [controllerFactory] diberikan, layar terhubung ke [TransactionsController]
/// dan merender status loading, data, empty, serta error/retry.
///
/// Ekspor Excel sengaja berupa callback [onExportExcel] agar pembuatan berkas
/// tetap di lapisan data/API (tidak ada dependensi Excel di UI).
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    super.key,
    this.data,
    this.controllerFactory,
    this.onExportExcel,
    this.onTransactionTap,
    this.onBack,
    this.onNotificationTap,
    this.onAddTap,
    this.activities,
    this.onActivityTap,
    this.onSeeAllActivities,
  });

  /// Data tampilan; bawaannya [AnalyticsViewData.sample].
  final AnalyticsViewData? data;

  /// Factory untuk controller transaksi operasional.
  final TransactionsController Function()? controllerFactory;

  /// Dipanggil saat pengguna meminta ekspor Excel.
  final Future<void> Function(AnalyticsExportRequest request)? onExportExcel;

  final ValueChanged<AnalyticsTransaction>? onTransactionTap;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAddTap;

  /// Aktivitas terbaru; bawaannya data contoh Beranda.
  final List<DashboardActivityData>? activities;

  /// Membuka detail satu aktivitas.
  final ValueChanged<DashboardActivityData>? onActivityTap;

  /// Aksi "Lihat Semua" pada bagian aktivitas.
  final VoidCallback? onSeeAllActivities;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionsController? _controller;

  AnalyticsViewData get _currentData =>
      _controller?.state.viewData ?? widget.data ?? AnalyticsViewData.sample;

  AnalyticsFilter _filter = const AnalyticsFilter();
  late DateTime _visibleMonth;
  bool _userChangedMonth = false;

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final AnalyticsViewData initial =
        widget.data ?? AnalyticsViewData.sample;
    _visibleMonth = DateTime(initial.month.year, initial.month.month);

    if (widget.controllerFactory != null) {
      _controller = widget.controllerFactory!();
      _controller!.addListener(_onControllerStateChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller?.load();
        }
      });
    }
  }

  void _onControllerStateChanged() {
    if (!mounted) return;
    final DateTime? dataMonth = _controller?.state.viewData?.month;
    if (dataMonth != null && !_userChangedMonth) {
      setState(() {
        _visibleMonth = DateTime(dataMonth.year, dataMonth.month);
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerStateChanged);
    _searchController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      return AnimatedBuilder(
        animation: _controller!,
        builder: (BuildContext context, Widget? _) {
          return _buildScreen(context, state: _controller!.state);
        },
      );
    }
    return _buildScreen(context);
  }

  Widget _buildScreen(BuildContext context, {TransactionsState? state}) {
    final AnalyticsViewData data =
        state?.viewData ?? widget.data ?? AnalyticsViewData.sample;

    final DateTime currentMonth = _visibleMonth;
    final DateTimeRange monthRange = monthRangeOf(currentMonth);
    final DateTimeRange range = _filter.range ?? monthRange;
    final AnalyticsFilter effectiveFilter = _filter.withRange(range);

    final List<AnalyticsTransaction> visible = data.transactions
        .where(effectiveFilter.matches)
        .toList()
      ..sort((AnalyticsTransaction a, AnalyticsTransaction b) =>
          b.date.compareTo(a.date));

    final AnalyticsSummary summary = AnalyticsSummary.from(visible);
    final AnalyticsSummary previous = AnalyticsSummary.from(
      data.transactions.where(
        AnalyticsFilter(
          range: previousRangeOf(range),
          type: _filter.type,
          category: _filter.category,
          query: _filter.query,
        ).matches,
      ),
    );
    final double growth = percentageChange(summary.income, previous.income);

    final List<CategoryTotal> expenseCategories =
        categoryTotals(visible, TransactionType.expense);
    final List<CategoryTotal> incomeCategories =
        categoryTotals(visible, TransactionType.income);
    final int categoryCount =
        expenseCategories.length + incomeCategories.length;

    final String dateLabel = _filter.range == null
        ? formatMonthYear(currentMonth)
        : formatDateRange(_filter.range!);

    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = math.min(constraints.maxWidth, 480);
          final double scale = width / 430;
          final double topInset = MediaQuery.of(context).padding.top;

          return Center(
            child: SizedBox(
              width: width,
              child: Column(
                children: <Widget>[
                  AnalyticsTopBar(
                    scale: scale,
                    topInset: topInset,
                    onBack: widget.onBack,
                    onNotificationTap: widget.onNotificationTap,
                    onAddTap: widget.onAddTap,
                  ),
                  Expanded(
                    child: ifContent(
                      state: state,
                      scale: scale,
                      range: range,
                      visible: visible,
                      summary: summary,
                      growth: growth,
                      dateLabel: dateLabel,
                      categoryCount: categoryCount,
                      expenseCategories: expenseCategories,
                      incomeCategories: incomeCategories,
                      data: data,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget ifContent({
    TransactionsState? state,
    required double scale,
    required DateTimeRange range,
    required List<AnalyticsTransaction> visible,
    required AnalyticsSummary summary,
    required double growth,
    required String dateLabel,
    required int categoryCount,
    required List<CategoryTotal> expenseCategories,
    required List<CategoryTotal> incomeCategories,
    required AnalyticsViewData data,
  }) {
    if (state != null && state.status == TransactionsStatus.loading) {
      return _buildLoadingState(scale);
    }
    if (state != null && state.status == TransactionsStatus.error) {
      return _buildErrorState(scale, state.errorMessage);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        18 * scale,
        16 * scale,
        kBottomContentInset * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnalyticsSearchBar(
            scale: scale,
            controller: _searchController,
            hint: data.searchHint,
            showClear: _filter.query.isNotEmpty,
            onChanged: _onQueryChanged,
            onClear: _clearQuery,
            isExporting: _isExporting,
            onExport: () => _export(range, visible, summary),
          ),
          SizedBox(height: 16 * scale),
          AnalyticsFilterChips(
            scale: scale,
            totalCount: visible.length,
            type: _filter.type,
            category: _filter.category,
            dateLabel: _filter.range == null
                ? null
                : formatDateRange(_filter.range!),
            onTypeChanged: (TransactionType? type) {
              setState(() {
                _filter = _filter.withType(type);
              });
            },
            onCategoryTap: () => _pickCategory(range),
            onReset: _resetAll,
          ),
          SizedBox(height: 14 * scale),
          DateFilterCard(
            scale: scale,
            label: dateLabel,
            onTap: _pickDateRange,
            onPreviousMonth: () => _changeMonth(-1),
            onNextMonth: () => _changeMonth(1),
          ),
          SizedBox(height: 14 * scale),
          SummaryHeroCard(scale: scale, summary: summary),
          SizedBox(height: 18 * scale),
          CashFlowDonutCard(scale: scale, summary: summary),
          SizedBox(height: 18 * scale),
          BarChartCard(
            scale: scale,
            data: _buildChartData(
              range: range,
              summary: summary,
              visible: visible,
              growth: growth,
            ),
          ),
          SizedBox(height: 22 * scale),
          _SectionHeading(
            scale: scale,
            title: 'Rincian Transaksi',
            trailing: '$categoryCount Kategori Aktif',
          ),
          SizedBox(height: 12 * scale),
          CategoryBreakdownCard(
            scale: scale,
            type: TransactionType.expense,
            items: expenseCategories,
            total: summary.expense,
          ),
          SizedBox(height: 10 * scale),
          CategoryBreakdownCard(
            scale: scale,
            type: TransactionType.income,
            items: incomeCategories,
            total: summary.income,
          ),
          SizedBox(height: 22 * scale),
          _SectionHeading(
            scale: scale,
            title: 'Daftar Transaksi',
            trailing: '${visible.length} Transaksi',
          ),
          SizedBox(height: 12 * scale),
          _buildTransactionList(scale, visible, state: state),
          SizedBox(height: 22 * scale),
          _buildActivityHeader(scale),
          SizedBox(height: 12 * scale),
          _buildActivityList(scale),
        ],
      ),
    );
  }

  Widget _buildLoadingState(double scale) {
    return Center(
      key: const Key('analytics_loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: SojuColors.primary),
          SizedBox(height: 12 * scale),
          Text(
            'Memuat data transaksi...',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14 * scale,
              color: SojuColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(double scale, String? errorMessage) {
    return Center(
      key: const Key('analytics_error'),
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 48 * scale,
              color: SojuColors.expense,
            ),
            SizedBox(height: 12 * scale),
            Text(
              errorMessage ?? 'Gagal memuat data transaksi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: SojuColors.ink,
              ),
            ),
            SizedBox(height: 16 * scale),
            ElevatedButton(
              key: const Key('analytics_retry_button'),
              onPressed: () => _controller?.load(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SojuColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData({
    required DateTimeRange range,
    required AnalyticsSummary summary,
    required List<AnalyticsTransaction> visible,
    required double growth,
  }) {
    final DateTime end = dateOnly(range.end);
    final DateTime start = DateTime(end.year, end.month, end.day - 6);
    final List<DailyTotal> daily = dailyTotals(visible, start: start, end: end);

    final int maxThousands = daily.fold<int>(
      0,
      (int max, DailyTotal day) => math.max(
        max,
        math.max((day.income / 1000).ceil(), (day.expense / 1000).ceil()),
      ),
    );

    final DateTimeRange fullMonth = monthRangeOf(_visibleMonth);
    final bool isFullMonth =
        dateOnly(range.start) == dateOnly(fullMonth.start) &&
            dateOnly(range.end) == dateOnly(fullMonth.end);

    return BarChartData(
      title: 'Tren Arus Kas Harian',
      total: formatRupiah(summary.income),
      dateLabel:
          isFullMonth ? formatMonthYear(_visibleMonth) : formatDateRange(range),
      growth: formatPercentChange(growth),
      growthPositive: growth >= 0,
      axisMax: niceAxisMax(maxThousands),
      primaryLegend: 'Pengeluaran',
      secondaryLegend: 'Pemasukan',
      valueFormatter: formatChartValue,
      days: <BarChartDay>[
        for (final DailyTotal day in daily)
          BarChartDay(
            label: weekdayShort(day.date),
            primary: (day.expense / 1000).ceil(),
            secondary: (day.income / 1000).ceil(),
          ),
      ],
    );
  }

  Widget _buildTransactionList(
    double scale,
    List<AnalyticsTransaction> visible, {
    TransactionsState? state,
  }) {
    if (visible.isEmpty) {
      final bool isLiveEmpty =
          state != null && state.status == TransactionsStatus.empty;
      return Container(
        key: isLiveEmpty ? const Key('analytics_empty') : null,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 18 * scale,
          vertical: 28 * scale,
        ),
        decoration: BoxDecoration(
          color: SojuColors.surface,
          borderRadius: BorderRadius.circular(18 * scale),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.receipt_long_outlined,
              size: 34 * scale,
              color: SojuColors.analyticsMuted,
            ),
            SizedBox(height: 8 * scale),
            Text(
              isLiveEmpty
                  ? 'Belum ada data transaksi'
                  : 'Belum ada transaksi pada filter ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
                color: SojuColors.ink,
              ),
            ),
            SizedBox(height: 10 * scale),
            if (isLiveEmpty && _controller != null)
              OutlinedButton(
                key: const Key('analytics_empty_retry_button'),
                onPressed: () => _controller?.load(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SojuColors.primary,
                  side: const BorderSide(color: SojuColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                ),
                child: const Text('Muat Ulang'),
              )
            else
              TextButton(
                onPressed: _resetAll,
                child: const Text('Reset filter'),
              ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int index = 0; index < visible.length; index++) ...<Widget>[
            if (index > 0)
              const Divider(
                  height: 1, thickness: 1, color: SojuColors.hairline),
            TransactionTile(
              scale: scale,
              transaction: visible[index],
              onTap: widget.onTransactionTap == null
                  ? null
                  : () => widget.onTransactionTap!(visible[index]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityHeader(double scale) {
    return Row(
      children: <Widget>[
        Text(
          'Aktivitas',
          style: TextStyle(
            fontFamily: AppTypography.wordmarkFamily,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: widget.onSeeAllActivities,
          child: Text(
            'Lihat Semua',
            style: TextStyle(
              fontFamily: AppTypography.wordmarkFamily,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: SojuColors.badgeBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList(double scale) {
    final List<DashboardActivityData> activities =
        widget.activities ?? DashboardViewData.sample.activities;
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < activities.length; i++) {
      if (i > 0) {
        children.add(SizedBox(height: 8 * scale));
        children.add(
          Container(
            height: 1,
            color: const Color(0xCCC1C1C1),
          ),
        );
        children.add(SizedBox(height: 8 * scale));
      }
      final DashboardActivityData activity = activities[i];
      children.add(
        ActivityTile(
          scale: scale,
          data: activity,
          onDetail: widget.onActivityTap == null
              ? null
              : () => widget.onActivityTap!(activity),
        ),
      );
    }

    return Column(children: children);
  }

  void _onQueryChanged(String value) {
    setState(() {
      _filter = _filter.withQuery(value);
    });
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() {
      _filter = _filter.withQuery('');
    });
  }

  void _resetAll() {
    _searchController.clear();
    setState(() {
      _filter = const AnalyticsFilter();
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _userChangedMonth = true;
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _filter = _filter.withRange(null);
    });
  }

  Future<void> _pickDateRange() async {
    final SojuDateSelection? result = await showSojuDateCalendarSheet(
      context,
      initialMonth: _visibleMonth,
      initialRange: _filter.range,
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _filter = _filter.withRange(result.range);
      if (result.range != null) {
        _visibleMonth = DateTime(
          result.range!.start.year,
          result.range!.start.month,
        );
      }
    });
  }

  Future<void> _pickCategory(DateTimeRange range) async {
    final Map<String, _CategoryOption> options = <String, _CategoryOption>{};
    for (final AnalyticsTransaction transaction in _currentData.transactions) {
      if (!AnalyticsFilter(range: range).matches(transaction)) {
        continue;
      }
      final _CategoryOption? current = options[transaction.category];
      options[transaction.category] = _CategoryOption(
        category: transaction.category,
        type: transaction.type,
        amount: (current?.amount ?? 0) + transaction.amount,
        count: (current?.count ?? 0) + 1,
      );
    }
    final List<_CategoryOption> sorted = options.values.toList()
      ..sort((_CategoryOption a, _CategoryOption b) =>
          b.amount.compareTo(a.amount));

    final _CategorySelection? result =
        await showModalBottomSheet<_CategorySelection>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _CategorySheet(
        options: sorted,
        selected: _filter.category,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _filter = _filter.withCategory(result.category);
    });
  }

  Future<void> _export(
    DateTimeRange range,
    List<AnalyticsTransaction> visible,
    AnalyticsSummary summary,
  ) async {
    final AnalyticsExportRequest request = AnalyticsExportRequest(
      range: range,
      transactions: List<AnalyticsTransaction>.unmodifiable(visible),
      summary: summary,
      type: _filter.type,
      category: _filter.category,
      query: _filter.query,
    );
    final Future<void> Function(AnalyticsExportRequest)? handler =
        widget.onExportExcel;
    if (handler == null) {
      _showSnack('Ekspor Excel belum tersambung ke API.');
      return;
    }
    setState(() => _isExporting = true);
    try {
      await handler(request);
      _showSnack('Ekspor Excel siap diunduh.');
    } catch (error) {
      _showSnack('Gagal mengekspor Excel: $error');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.scale,
    required this.title,
    required this.trailing,
  });

  final double scale;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.wordmarkFamily,
              fontSize: 20 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.analyticsTitle,
            ),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            fontFamily: AppTypography.wordmarkFamily,
            fontSize: 11.1 * scale,
            fontWeight: FontWeight.w600,
            color: SojuColors.analyticsMuted,
          ),
        ),
      ],
    );
  }
}

@immutable
class _CategoryOption {
  const _CategoryOption({
    required this.category,
    required this.type,
    required this.amount,
    required this.count,
  });

  final String category;
  final TransactionType type;
  final double amount;
  final int count;
}

@immutable
class _CategorySelection {
  const _CategorySelection(this.category);

  final String? category;
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.options, required this.selected});

  final List<_CategoryOption> options;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: SojuColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: SojuColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Filter kategori',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  _tile(
                    context,
                    label: 'Semua kategori',
                    icon: Icons.apps,
                    color: SojuColors.inkMuted,
                    trailing: '',
                    isSelected: selected == null,
                    onTap: () => Navigator.of(context)
                        .pop(const _CategorySelection(null)),
                  ),
                  for (final _CategoryOption option in options)
                    _tile(
                      context,
                      label: option.category,
                      icon: categoryIconFor(option.category, option.type),
                      color: option.type == TransactionType.income
                          ? SojuColors.chartGreen
                          : SojuColors.expense,
                      trailing: '${option.count}x • '
                          '${formatCompactRupiah(option.amount)}',
                      isSelected: selected == option.category,
                      onTap: () => Navigator.of(context)
                          .pop(_CategorySelection(option.category)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String trailing,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: SojuColors.ink,
        ),
      ),
      subtitle: trailing.isEmpty
          ? null
          : Text(
              trailing,
              style: const TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12,
                color: SojuColors.analyticsMuted,
              ),
            ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: SojuColors.primary)
          : null,
    );
  }
}
