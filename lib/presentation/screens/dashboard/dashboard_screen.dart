import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../utils/format.dart';
import '../../widgets/bottom_glass_overlay.dart';
import '../../widgets/profile_menu.dart';
import '../../widgets/soju_date_calendar_sheet.dart';
import '../profile/models/profile_view_data.dart';
import 'models/dashboard_view_data.dart';
import 'widgets/activity_tile.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/metric_card.dart';
import 'widgets/revenue_chart_card.dart';

/// Layar Beranda (frame Figma `546:1616`).
///
/// Seluruh isi layar berasal dari [DashboardViewData]. Secara bawaan dipakai
/// [DashboardViewData.sample] hasil slicing Figma; saat lapisan data siap,
/// beranda cukup menerima data hasil pemetaan DTO tanpa mengubah widget.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.data = DashboardViewData.sample,
    this.onAvatarTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.onQuickCommand,
    this.onSendCommand,
    this.onSeeAllActivities,
    this.onActivityDetail,
    this.onAnalyticsTap,
    this.profile = ProfileViewData.sample,
    this.onLogout,
  });

  final DashboardViewData data;
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

  /// Aksi setelah pengguna mengonfirmasi Keluar.
  final VoidCallback? onLogout;

  /// Lebar desain acuan (frame Figma 430px).
  static const double _designWidth = 430;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTimeRange? _selectedRange;

  String get _dateLabel {
    final DateTimeRange? range = _selectedRange;
    return range == null
        ? widget.data.revenue.dateLabel
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
                        searchHint: widget.data.searchHint,
                        avatarAsset: widget.data.avatarAsset,
                        onAvatarTap: widget.onAvatarTap ??
                            () => showProfileMenu(
                                  context,
                                  data: widget.profile,
                                  onLogout: widget.onLogout,
                                ),
                        onSearchTap: widget.onSearchTap,
                        onNotificationTap: widget.onNotificationTap,
                      ),
                      SizedBox(height: 16 * scale),
                      _buildMetrics(scale),
                      SizedBox(height: 32 * scale),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale,
                        ),
                        child: RevenueChartCard(
                          scale: scale,
                          data: _selectedRange == null
                              ? widget.data.revenue
                              : widget.data.revenue.copyWith(
                                  dateLabel: _dateLabel,
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
                          data: widget.data.assistant,
                          onQuickCommand: widget.onQuickCommand,
                          onSubmit: widget.onSendCommand,
                        ),
                      ),
                      SizedBox(height: 15 * scale),
                      _buildActivitiesHeader(scale),
                      SizedBox(height: 15 * scale),
                      _buildActivities(scale),
                      // Ruang agar item terakhir bisa digulir melewati
                      // lapisan kaca di bawah.
                      SizedBox(height: kBottomContentInset * scale),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetrics(double scale) {
    return SizedBox(
      height: 116 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: widget.data.metrics.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(width: 12 * scale),
        itemBuilder: (BuildContext context, int index) {
          final DashboardMetricData metric = widget.data.metrics[index];
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

  Widget _buildActivities(double scale) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < widget.data.activities.length; i++) {
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
      final DashboardActivityData activity = widget.data.activities[i];
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
