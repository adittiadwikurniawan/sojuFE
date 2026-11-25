import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../providers/dashboard/dashboard_controller.dart';
import '../../utils/format.dart';
import '../../widgets/activity_tile.dart';
import '../../widgets/bottom_glass_overlay.dart';
import '../../widgets/profile_menu.dart';
import '../../widgets/soju_date_calendar_sheet.dart';
import '../profile/models/profile_view_data.dart';
import 'models/dashboard_view_data.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/metric_card.dart';
import 'widgets/revenue_chart_card.dart';

/// Layar Beranda (frame Figma `546:1616`).
///
/// Seluruh isi layar berasal dari [DashboardViewData]. Secara bawaan dipakai
/// [DashboardViewData.sample] hasil slicing Figma; saat controller live
/// diberikan melalui [controllerFactory], layar akan membaca state live REST
/// dengan status loading, data, empty, dan error/retry.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.data = DashboardViewData.sample,
    this.controllerFactory,
    this.onMenuTap,
    this.onAvatarTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.onQuickCommand,
    this.onSendCommand,
    this.onSeeAllActivities,
    this.onActivityDetail,
    this.onAnalyticsTap,
    this.profile = ProfileViewData.sample,
    this.onViewProfile,
    this.onLogout,
  });

  final DashboardViewData data;
  final DashboardController Function()? controllerFactory;
  final VoidCallback? onMenuTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final ValueChanged<AssistantCommandData>? onQuickCommand;
  final ValueChanged<String>? onSendCommand;
  final VoidCallback? onSeeAllActivities;
  final ValueChanged<DashboardActivityData>? onActivityDetail;

  /// Membuka Analytics dari kartu Total Penghasilan.
  final VoidCallback? onAnalyticsTap;

  /// Akun aktif untuk menu Profil / Menu Akun.
  final ProfileViewData profile;

  /// Membuka layar detail profil dari menu avatar.
  final VoidCallback? onViewProfile;

  /// Aksi setelah pengguna mengonfirmasi Keluar.
  final VoidCallback? onLogout;

  /// Lebar desain acuan (frame Figma 430px).
  static const double _designWidth = 430;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTimeRange? _selectedRange;
  DashboardController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controllerFactory != null) {
      _controller = widget.controllerFactory!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller?.load();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _dateLabel(DashboardViewData data) {
    final DateTimeRange? range = _selectedRange;
    return range == null
        ? data.revenue.dateLabel
        : formatDateRange(range);
  }

  Future<void> _pickDate() async {
    final SojuDateSelection? result = await showSojuDateCalendarSheet(
      context,
      initialMonth: _selectedRange?.start ?? DateTime.now(),
      initialRange: _selectedRange,
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() => _selectedRange = result.range);
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double contentWidth = math.min(constraints.maxWidth, 480);
            final double scale = contentWidth / DashboardScreen._designWidth;

            if (_controller != null) {
              return AnimatedBuilder(
                animation: _controller!,
                builder: (BuildContext context, Widget? _) {
                  return _buildLayout(
                    context,
                    constraints,
                    contentWidth,
                    scale,
                    topInset,
                    state: _controller!.state,
                  );
                },
              );
            }

            return _buildLayout(
              context,
              constraints,
              contentWidth,
              scale,
              topInset,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLayout(
    BuildContext context,
    BoxConstraints constraints,
    double contentWidth,
    double scale,
    double topInset, {
    DashboardState? state,
  }) {
    final DashboardViewData effectiveData =
        state?.viewData ?? widget.data;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: contentWidth,
        height: constraints.maxHeight,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DashboardTopBar(
                scale: scale,
                topInset: topInset,
                searchHint: effectiveData.searchHint,
                avatarAsset: effectiveData.avatarAsset,
                onMenuTap: widget.onMenuTap,
                onAvatarTap: widget.onAvatarTap ??
                    () => showProfileMenu(
                          context,
                          data: widget.profile,
                          onViewProfile: widget.onViewProfile,
                          onLogout: widget.onLogout,
                        ),
                onSearchTap: widget.onSearchTap,
                onNotificationTap: widget.onNotificationTap,
              ),
              if (state != null && state.status == DashboardStatus.loading)
                _buildLoadingState(scale)
              else if (state != null && state.status == DashboardStatus.error)
                _buildErrorState(scale, state.errorMessage)
              else ...<Widget>[
                SizedBox(height: 16 * scale),
                _buildMetrics(scale, effectiveData),
                SizedBox(height: 32 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                  ),
                  child: RevenueChartCard(
                    scale: scale,
                    data: _selectedRange == null
                        ? effectiveData.revenue
                        : effectiveData.revenue.copyWith(
                            dateLabel: _dateLabel(effectiveData),
                          ),
                    onTap: widget.onAnalyticsTap ??
                        widget.onSeeAllActivities,
                    onDateTap: _pickDate,
                  ),
                ),
                SizedBox(height: 32 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                  ),
                  child: AiAssistantCard(
                    scale: scale,
                    data: effectiveData.assistant,
                    onQuickCommand: widget.onQuickCommand,
                    onSubmit: widget.onSendCommand,
                  ),
                ),
                SizedBox(height: 15 * scale),
                _buildActivitiesHeader(scale),
                SizedBox(height: 15 * scale),
                _buildActivities(scale, effectiveData),
                // Ruang agar item terakhir bisa digulir melewati
                // lapisan kaca di bawah.
                SizedBox(height: kBottomContentInset * scale),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(double scale) {
    return Padding(
      key: const Key('dashboard_loading'),
      padding: EdgeInsets.symmetric(vertical: 80 * scale),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(color: SojuColors.primary),
            SizedBox(height: 12 * scale),
            Text(
              'Memuat ringkasan operasional...',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 14 * scale,
                color: SojuColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(double scale, String? errorMessage) {
    return Padding(
      key: const Key('dashboard_error'),
      padding: EdgeInsets.all(24 * scale),
      child: Center(
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
              errorMessage ?? 'Gagal memuat ringkasan operasional.',
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
              key: const Key('dashboard_retry_button'),
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

  Widget _buildInlineEmptyActivities(double scale) {
    return Container(
      key: const Key('dashboard_empty'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 24 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.dashboard_outlined,
            size: 36 * scale,
            color: SojuColors.inkMuted,
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Belum ada aktivitas operasional',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              color: SojuColors.ink,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Aktivitas kas dan pesanan terbaru akan otomatis muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12.5 * scale,
              color: SojuColors.inkMuted,
            ),
          ),
          if (_controller != null) ...<Widget>[
            SizedBox(height: 14 * scale),
            OutlinedButton(
              key: const Key('dashboard_empty_retry_button'),
              onPressed: () => _controller?.load(),
              style: OutlinedButton.styleFrom(
                foregroundColor: SojuColors.primary,
                side: const BorderSide(color: SojuColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetrics(double scale, DashboardViewData data) {
    return SizedBox(
      height: 116 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: data.metrics.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(width: 12 * scale),
        itemBuilder: (BuildContext context, int index) {
          final DashboardMetricData metric = data.metrics[index];
          return MetricCard(
            scale: scale,
            title: metric.title,
            value: metric.value,
            note: metric.note,
            titleSize: metric.titleSize,
          );
        },
      ),
    );
  }

  Widget _buildActivitiesHeader(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Row(
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
      ),
    );
  }

  Widget _buildActivities(double scale, DashboardViewData data) {
    if (data.activities.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        child: _buildInlineEmptyActivities(scale),
      );
    }

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < data.activities.length; i++) {
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
      final DashboardActivityData activity = data.activities[i];
      children.add(
        ActivityTile(
          scale: scale,
          data: activity,
          onDetail: widget.onActivityDetail == null
              ? null
              : () => widget.onActivityDetail!(activity),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Column(children: children),
    );
  }
}
