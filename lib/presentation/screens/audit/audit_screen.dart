// lib/presentation/screens/audit/audit_screen.dart
//
// Layar "Audit & Stok" Buku Dapur (frame Figma `546:4741`).
//
// Sesuai PRD (FR-15 / MFR-7 / MFR-9): hanya menampilkan **audit log**
// read-only — tidak ada tombol tambah, edit, hapus, rekonsiliasi, atau AI.
// Data berasal dari `GetAuditLogs` (kontrak domain) yang disinjeksikan lewat
// [AuditScreen.controllerFactory]; implementasi mock dapat diganti repository
// REST (Phase B) tanpa mengubah layar ini.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../providers/audit/audit_log_controller.dart';
import '../../utils/format.dart';
import '../../widgets/bottom_glass_overlay.dart';
import '../../widgets/date_filter_card.dart';
import '../../widgets/soju_date_calendar_sheet.dart';
import 'models/audit_view_data.dart';
import 'widgets/audit_log_tile.dart';
import 'widgets/audit_range_chips.dart';
import 'widgets/audit_status_view.dart';
import 'widgets/audit_top_bar.dart';

/// Lebar desain acuan (frame Figma 430px).
const double _kAuditDesignWidth = 430;

/// Layar Audit & Stok: daftar log aktivitas baca-saja.
class AuditScreen extends StatefulWidget {
  const AuditScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
  });

  /// Membuat controller per instance layar (DI disambungkan dari route:
  /// Phase A memakai mock, Phase B cukup mengganti factory ke repository
  /// REST tanpa perubahan layar).
  final AuditLogController Function() controllerFactory;

  /// Aksi tombol kembali (disingkatkan dari route).
  final VoidCallback? onBack;

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  late final AuditLogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.load();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            final double scale = contentWidth / _kAuditDesignWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AuditTopBar(
                      scale: scale,
                      topInset: topInset,
                      title: 'Audit & Stok',
                      onBack: widget.onBack,
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget? _) =>
                            _buildBody(_controller.state, scale),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(AuditLogState state, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader(state, scale),
        Expanded(
          child: switch (state.status) {
            AuditLogStatus.loading => AuditLoadingView(scale: scale),
            AuditLogStatus.error => _buildError(state, scale),
            AuditLogStatus.empty => _buildEmpty(state, scale),
            AuditLogStatus.data => _buildList(state, scale),
          },
        ),
      ],
    );
  }

  /// Judul section, jumlah log, deskripsi, dan chip rentang waktu.
  Widget _buildHeader(AuditLogState state, double scale) {
    final String countLabel = switch (state.status) {
      AuditLogStatus.loading => '…',
      _ => '${state.totalCount ?? state.logs.length} log',
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        18 * scale,
        16 * scale,
        14 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'Log Aktivitas',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 17 * scale,
                  fontWeight: FontWeight.w800,
                  color: SojuColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                countLabel,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.analyticsMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Riwayat perubahan data bersifat permanen dan hanya dapat dibaca.',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: SojuColors.analyticsMuted,
            ),
          ),
          SizedBox(height: 12 * scale),
          AuditRangeChips(
            scale: scale,
            selected: state.range,
            customActive: state.hasCustomRange,
            onChanged: _controller.setRange,
          ),
          SizedBox(height: 12 * scale),
          DateFilterCard(
            scale: scale,
            caption: 'Rentang audit',
            label: _rangeLabel(state),
            onTap: _pickDateRange,
          ),
        ],
      ),
    );
  }

  String _rangeLabel(AuditLogState state) {
    final DateTime? start = state.startDate;
    final DateTime? end = state.endDate;
    if (start != null && end != null) {
      return formatDateRange(DateTimeRange(start: start, end: end));
    }
    return state.range.label;
  }

  Future<void> _pickDateRange() async {
    final AuditLogState state = _controller.state;
    final DateTime? start = state.startDate;
    final DateTime? end = state.endDate;
    final DateTimeRange? initialRange = start != null && end != null
        ? DateTimeRange(start: start, end: end)
        : null;
    final SojuDateSelection? result = await showSojuDateCalendarSheet(
      context,
      initialMonth: start ?? DateTime.now(),
      initialRange: initialRange,
    );
    if (result == null || !mounted) {
      return;
    }
    if (result.range == null) {
      await _controller.clearCustomRange();
    } else {
      await _controller.setCustomRange(result.range!);
    }
  }

  Widget _buildError(AuditLogState state, double scale) {
    return Center(
      child: SingleChildScrollView(
        child: AuditErrorView(
          scale: scale,
          message:
              state.errorMessage ?? 'Terjadi kesalahan yang tidak diketahui.',
          onRetry: _controller.load,
        ),
      ),
    );
  }

  Widget _buildEmpty(AuditLogState state, double scale) {
    return Center(
      child: SingleChildScrollView(
        child: AuditEmptyView(
          scale: scale,
          rangeLabel: state.hasCustomRange
              ? _rangeLabel(state)
              : rangeLabelText(state.range),
        ),
      ),
    );
  }

  Widget _buildList(AuditLogState state, double scale) {
    final List<Widget> rows = <Widget>[];
    for (final AuditLogSection section in buildAuditSections(state.logs)) {
      rows.add(_SectionHeader(scale: scale, label: section.label));
      for (final AuditLogViewData log in section.items) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(
              left: 16 * scale,
              right: 16 * scale,
              bottom: 10 * scale,
            ),
            child: AuditLogTile(scale: scale, log: log),
          ),
        );
      }
    }
    rows.add(_ListFooter(state: state, scale: scale, controller: _controller));

    return ListView(
        padding: EdgeInsets.only(bottom: kBottomContentInset * scale),
        children: rows);
  }
}

/// Header tanggal kelompok (`Hari Ini`, `Kemarin`, `17 Nov 2026`).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.scale, required this.label});

  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        6 * scale,
        18 * scale,
        8 * scale,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 12.5 * scale,
          fontWeight: FontWeight.w800,
          color: SojuColors.analyticsLabel,
        ),
      ),
    );
  }
}

/// Bagian bawah daftar: muat selengkapnya, proses muat, galat muat, atau
/// tanda akhir daftar.
class _ListFooter extends StatelessWidget {
  const _ListFooter({
    required this.state,
    required this.scale,
    required this.controller,
  });

  final AuditLogState state;
  final double scale;
  final AuditLogController controller;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.all(16 * scale),
        child: const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (state.loadMoreFailed) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16 * scale, 4 * scale, 16 * scale, 0),
        child: Column(
          children: <Widget>[
            Text(
              state.errorMessage ?? 'Gagal memuat selengkapnya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12.5 * scale,
                fontWeight: FontWeight.w500,
                color: SojuColors.expense,
              ),
            ),
            SizedBox(height: 8 * scale),
            OutlinedButton(
              onPressed: controller.loadMore,
              style: OutlinedButton.styleFrom(
                foregroundColor: SojuColors.primary,
                side: const BorderSide(color: SojuColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
              ),
              child: Text(
                'Coba lagi',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.hasNext) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        child: OutlinedButton(
          onPressed: controller.loadMore,
          style: OutlinedButton.styleFrom(
            foregroundColor: SojuColors.primary,
            backgroundColor: SojuColors.surface,
            side: const BorderSide(color: SojuColors.border),
            minimumSize: Size.fromHeight(44 * scale),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22 * scale),
            ),
          ),
          child: Text(
            'Muat selengkapnya',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13.5 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 4 * scale),
      child: Text(
        'Semua log sudah ditampilkan',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 12 * scale,
          fontWeight: FontWeight.w500,
          color: SojuColors.analyticsMuted,
        ),
      ),
    );
  }
}

/// Label rentang untuk teks keadaan kosong.
String rangeLabelText(AuditRangeOption option) {
  switch (option) {
    case AuditRangeOption.days7:
      return '7 hari terakhir';
    case AuditRangeOption.days30:
      return '30 hari terakhir';
    case AuditRangeOption.days90:
      return '90 hari terakhir';
    case AuditRangeOption.all:
      return 'seluruh rentang waktu';
  }
}
