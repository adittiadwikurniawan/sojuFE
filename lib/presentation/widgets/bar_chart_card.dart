import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';

/// Data satu hari pada [BarChartCard].
@immutable
class BarChartDay {
  const BarChartDay({
    required this.label,
    required this.primary,
    required this.secondary,
  });

  /// Label hari di bawah batang (mis. `Senin`).
  final String label;

  /// Nilai batang seri pertama (warna navy).
  final int primary;

  /// Nilai batang seri kedua (warna hijau).
  final int secondary;
}

/// Data kartu grafik batang dua seri.
///
/// Nilai [axisMax], [BarChartDay.primary], dan [BarChartDay.secondary] memakai
/// satuan ribuan agar cocok dengan geometri desain; [valueFormatter] mengatur
/// label yang tampil (mis. `300rb` atau `3jt`).
@immutable
class BarChartData {
  const BarChartData({
    required this.title,
    required this.total,
    required this.dateLabel,
    required this.growth,
    required this.axisMax,
    required this.days,
    required this.primaryLegend,
    required this.secondaryLegend,
    this.growthPositive = true,
    this.valueFormatter,
  });

  final String title;
  final String total;
  final String dateLabel;
  final String growth;
  final int axisMax;
  final List<BarChartDay> days;
  final String primaryLegend;
  final String secondaryLegend;
  final bool growthPositive;

  /// Format label sumbu Y dan nilai batang; bawaan `100rb`.
  final String Function(int value)? valueFormatter;

  String formatValue(int value) => valueFormatter?.call(value) ?? '${value}rb';
}

/// Kartu grafik batang dua seri (frame `546:1616` node `546:1652` dan frame
/// `546:2937` node `546:2996`).
///
/// Geometri grafik dipetakan linear dari [BarChartData.axisMax] pada tinggi
/// area plot desain, sehingga data dari API dapat langsung dipakai tanpa
/// mengubah tata letak.
class BarChartCard extends StatelessWidget {
  const BarChartCard({
    super.key,
    required this.scale,
    required this.data,
    this.onDateTap,
  });

  final double scale;
  final BarChartData data;

  /// Bila diisi, pil tanggal di header dapat diketuk untuk memilih tanggal.
  final VoidCallback? onDateTap;

  // --- Geometri desain (px pada frame 430) ---

  /// Tinggi kartu.
  static const double _cardHeight = 421;

  /// Garis bawah batang grafik.
  static const double _baseline = 272;

  /// Tinggi area plot (dari garis 0 sampai nilai maksimum sumbu).
  static const double _plotHeight = 222;

  /// Lebar batang dan jarak antar batang dalam satu hari.
  static const double _barWidth = 30;
  static const double _barGap = 6;

  /// Awal area plot (setelah label sumbu-Y).
  static const double _plotLeft = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _cardHeight * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 17.5 * scale,
        vertical: 17.5 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(15 * scale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          SizedBox(height: 2 * scale),
          _buildTotalRow(),
          SizedBox(height: 19 * scale),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            data.title,
            style: TextStyle(
              fontFamily: AppTypography.wordmarkFamily,
              fontSize: 15.3 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        _DatePill(scale: scale, label: data.dateLabel, onTap: onDateTap),
      ],
    );
  }

  Widget _buildTotalRow() {
    final Color growthColor =
        data.growthPositive ? SojuColors.positive : SojuColors.expense;
    return Row(
      children: <Widget>[
        Text(
          data.total,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 6 * scale),
        Icon(
          data.growthPositive ? Icons.north : Icons.south,
          size: 10 * scale,
          color: growthColor,
        ),
        SizedBox(width: 2 * scale),
        Text(
          data.growth,
          style: TextStyle(
            fontFamily: AppTypography.wordmarkFamily,
            fontSize: 14.2 * scale,
            fontWeight: FontWeight.w600,
            color: growthColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final int axisMax = data.axisMax;
    final int days = data.days.length;
    double valueToY(int value) => _baseline - (value / axisMax) * _plotHeight;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double plotWidth = constraints.maxWidth / scale - _plotLeft;
        final double groupWidth = plotWidth / days;
        // Batang menyempit otomatis saat jumlah hari bertambah agar seluruh
        // grup tetap berada di dalam kartu (mis. 7 hari pada Analytics).
        final double barWidth =
            math.min(_barWidth, (groupWidth - _barGap - 10) / 2);
        final double barOffset = barWidth + _barGap;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Garis bantu + label sumbu-Y.
            for (int step = 1; step <= 5; step++)
              ..._axis(value: (axisMax ~/ 5) * step, valueToY: valueToY),
            // Label nol di baseline.
            Positioned(
              left: 0,
              top: _baseline * scale,
              width: 31 * scale,
              child: _axisText('Rp. 0'),
            ),
            // Batang + label nilai + label hari.
            for (int i = 0; i < days; i++) ...<Widget>[
              _buildBar(
                left: _plotLeft + i * groupWidth + 3,
                width: barWidth,
                value: data.days[i].primary,
                color: SojuColors.primaryDeep,
                valueToY: valueToY,
              ),
              _buildBar(
                left: _plotLeft + i * groupWidth + 3 + barOffset,
                width: barWidth,
                value: data.days[i].secondary,
                color: SojuColors.chartGreen,
                valueToY: valueToY,
              ),
              Positioned(
                left: (_plotLeft +
                        i * groupWidth +
                        3 +
                        (barOffset + barWidth) / 2 -
                        24.5) *
                    scale,
                top: 277 * scale,
                width: 49 * scale,
                child: Text(
                  data.days[i].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ChartLegend(
                scale: scale,
                secondaryLabel: data.secondaryLegend,
                primaryLabel: data.primaryLegend,
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _axis({
    required int value,
    required double Function(int) valueToY,
  }) {
    final double y = valueToY(value);
    return <Widget>[
      Positioned(
        left: _plotLeft * scale,
        right: 0,
        top: y * scale,
        child: Container(height: 1, color: Colors.black),
      ),
      Positioned(
        left: 0,
        top: (y - 4) * scale,
        width: 31 * scale,
        child: _axisText(data.formatValue(value)),
      ),
    ];
  }

  Widget _axisText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.family,
        fontSize: 8 * scale,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }

  Widget _buildBar({
    required double left,
    required double width,
    required int value,
    required Color color,
    required double Function(int) valueToY,
  }) {
    final double top = valueToY(value);
    final double height = (_baseline - top).clamp(0, _plotHeight);

    return Positioned(
      left: left * scale,
      top: top * scale,
      width: width * scale,
      height: height * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10.5 * scale),
              ),
            ),
          ),
          if (value > 0)
            Positioned(
              left: -12 * scale,
              top: -11 * scale,
              width: (width + 24) * scale,
              child: Text(
                data.formatValue(value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 8 * scale,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.scale,
    required this.label,
    this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget pill = Container(
      key: const Key('chart_date_pill'),
      height: 25 * scale,
      padding: EdgeInsets.symmetric(horizontal: 7 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(17 * scale),
        border: Border.all(color: Colors.black, width: 0.8 * scale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.calendar_today_outlined,
            size: 11 * scale,
            color: Colors.black,
          ),
          SizedBox(width: 3 * scale),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.wordmarkFamily,
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.metricTitle,
            ),
          ),
          SizedBox(width: 4 * scale),
          Icon(
            Icons.keyboard_arrow_down,
            size: 10 * scale,
            color: Colors.black,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return pill;
    }
    return Semantics(
      button: true,
      label: 'Pilih tanggal $label',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: pill,
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.scale,
    required this.secondaryLabel,
    required this.primaryLabel,
  });

  final double scale;
  final String secondaryLabel;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _dot(SojuColors.chartGreen),
        SizedBox(width: 4 * scale),
        _label(secondaryLabel),
        SizedBox(width: 16 * scale),
        _dot(SojuColors.primaryDeep),
        SizedBox(width: 4 * scale),
        _label(primaryLabel),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6 * scale,
      height: 6 * scale,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.family,
        fontSize: 8.9 * scale,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }
}
