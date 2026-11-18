// lib/presentation/screens/activities/activities_screen.dart
//
// Halaman "Lihat Semua" untuk aktivitas. Untuk saat ini halaman ini hanya
// menampilkan daftar baca-saja; detail aktivitas belum menjadi bagian alur.
// Widget tidak memanggil HTTP dan hanya menerima data tampilan.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../models/activity_view_data.dart';
import '../../widgets/activity_tile.dart';
import 'widgets/activities_top_bar.dart';

/// Daftar lengkap aktivitas yang dibuka dari tautan "Lihat Semua".
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({
    super.key,
    this.activities = ActivityViewData.sample,
    this.onBack,
    this.onActivityTap,
  });

  final List<ActivityData> activities;
  final VoidCallback? onBack;

  /// Aksi opsional saat satu baris dibuka. Bila `null`, tombol Detail
  /// disembunyikan karena halaman ini hanya menyediakan mode lihat.
  final ValueChanged<ActivityData>? onActivityTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = math.min(constraints.maxWidth, 480);
            final double scale = width / 430;
            final double topInset = MediaQuery.paddingOf(context).top;
            final double bottomInset = MediaQuery.paddingOf(context).bottom;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: Column(
                  children: <Widget>[
                    ActivitiesTopBar(
                      scale: scale,
                      topInset: topInset,
                      onBack: onBack,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          16 * scale,
                          20 * scale,
                          16 * scale,
                          24 * scale + bottomInset,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _ListHeader(
                              scale: scale,
                              count: activities.length,
                            ),
                            SizedBox(height: 12 * scale),
                            if (activities.isEmpty)
                              _EmptyState(scale: scale)
                            else
                              _ActivityList(
                                scale: scale,
                                activities: activities,
                                onActivityTap: onActivityTap,
                              ),
                          ],
                        ),
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
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.scale, required this.count});

  final double scale;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Semua Aktivitas',
            style: TextStyle(
              fontFamily: AppTypography.wordmarkFamily,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10 * scale,
            vertical: 4 * scale,
          ),
          decoration: BoxDecoration(
            color: SojuColors.infoSoft,
            borderRadius: BorderRadius.circular(20 * scale),
          ),
          child: Text(
            '$count aktivitas',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.badgeBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({
    required this.scale,
    required this.activities,
    required this.onActivityTap,
  });

  final double scale;
  final List<ActivityData> activities;
  final ValueChanged<ActivityData>? onActivityTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('activities_list'),
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < activities.length; i++) ...<Widget>[
            if (i > 0) ...<Widget>[
              SizedBox(height: 8 * scale),
              Container(height: 1, color: SojuColors.hairline),
              SizedBox(height: 8 * scale),
            ],
            ActivityTile(
              scale: scale,
              data: activities[i],
              showDetailAction: onActivityTap != null,
              onDetail: onActivityTap == null
                  ? null
                  : () => onActivityTap!(activities[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 32 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.history_rounded,
            size: 34 * scale,
            color: SojuColors.analyticsMuted,
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Belum ada aktivitas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
