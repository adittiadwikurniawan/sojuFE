import 'package:flutter/material.dart';

/// Model tampilan layar Beranda (frame Figma `546:1616`).
///
/// Semua widget beranda menerima data dari model ini sehingga wiring API
/// nanti hanya perlu memetakan respons DTO -> [DashboardViewData] tanpa mengubah
/// widget. Sumber kebenaran data tetap di lapisan `data/` saat fitur API
/// mulai di-slicing.
@immutable
class DashboardViewData {
  const DashboardViewData({
    required this.avatarAsset,
    required this.searchHint,
    required this.metrics,
    required this.revenue,
    required this.assistant,
    required this.activities,
  });

  /// Aset avatar pada bilah atas.
  final String avatarAsset;

  /// Placeholder medan pencarian.
  final String searchHint;

  /// Kartu ringkasan metrik (baris geser horizontal).
  final List<DashboardMetricData> metrics;

  /// Ringkasan pendapatan + grafik batang.
  final RevenueSummary revenue;

  /// Kartu asisten AI.
  final AssistantCardData assistant;

  /// Daftar aktivitas terakhir.
  final List<DashboardActivityData> activities;

  /// Data contoh hasil slicing Figma.
  static const DashboardViewData sample = DashboardViewData(
    avatarAsset: 'assets/images/avatar_profil.png',
    searchHint: 'Cari Kas Mu',
    metrics: <DashboardMetricData>[
      DashboardMetricData(
        title: 'Penghasilan Hari Ini',
        value: 'Rp 940.000',
        note: 'Margin Sehat 33%',
        titleSize: 13.4,
      ),
      DashboardMetricData(
        title: 'Total Transaksi',
        value: '18 Transaksi',
        note: 'Rata-rata Rp 52rb/struk',
      ),
      DashboardMetricData(
        title: 'Pengeluaran',
        value: 'Rp 200.000',
        note: 'Belanja Bahan / Operasional',
      ),
    ],
    revenue: RevenueSummary(
      title: 'Total Penghasilan',
      dateLabel: '14 Okt 2026',
      total: 'Rp 200,666.987',
      growth: '+14%',
      axisMax: 520,
      days: <RevenueDayData>[
        RevenueDayData(label: 'Senin', thisWeek: 289, lastWeek: 189),
        RevenueDayData(label: 'Selasa', thisWeek: 280, lastWeek: 380),
        RevenueDayData(label: 'Rabu', thisWeek: 520, lastWeek: 450),
        RevenueDayData(label: 'Kamis', thisWeek: 510, lastWeek: 420),
      ],
      lastWeekLegend: 'Minggu Terakhir',
      thisWeekLegend: 'Minggu Ini',
    ),
    assistant: AssistantCardData(
      title: 'Tanya BukuKita AI',
      subtitle: 'Asisten pencatat suara, chat & stok dapur',
      inputHint: 'Ketik perintah atau tempel chat pesanan WhatsApp',
      quickCommands: <AssistantCommandData>[
        AssistantCommandData(
          label: '/add Catat Cepat',
          labelSize: 13,
          icon: Icons.add,
        ),
        AssistantCommandData(
          label: '/ask Cek Laba Hari Ini',
          labelSize: 12,
          icon: Icons.chat_bubble_outline,
        ),
      ],
    ),
    activities: <DashboardActivityData>[
      DashboardActivityData(
        name: 'Sosis',
        variant: 'Pedas/Sedang',
        sku: 'SKU: AYM - BKR -01',
        pack: '10 Pack',
        badge: 'Pemasukkan',
        imageAsset: 'assets/images/activity_sosis.png',
      ),
      DashboardActivityData(
        name: 'Sosis',
        variant: 'Pedas/Sedang',
        sku: 'SKU: AYM - BKR -01',
        pack: '10 Pack',
        badge: 'Pemasukkan',
        imageAsset: 'assets/images/activity_sosis.png',
      ),
      DashboardActivityData(
        name: 'Sosis',
        variant: 'Pedas/Sedang',
        sku: 'SKU: AYM - BKR -01',
        pack: '10 Pack',
        badge: 'Pemasukkan',
        imageAsset: 'assets/images/activity_sosis.png',
      ),
      DashboardActivityData(
        name: 'Sosis',
        variant: 'Pedas/Sedang',
        sku: 'SKU: AYM - BKR -01',
        pack: '10 Pack',
        badge: 'Pemasukkan',
        imageAsset: 'assets/images/activity_sosis.png',
      ),
    ],
  );
}

/// Satu kartu ringkasan metrik.
@immutable
class DashboardMetricData {
  const DashboardMetricData({
    required this.title,
    required this.value,
    required this.note,
    this.titleSize = 15.4,
  });

  final String title;
  final String value;
  final String note;

  /// Ukuran judul; Figma memakai 13.4 pada judul panjang dan 15.4 pada
  /// judul pendek.
  final double titleSize;
}

/// Ringkasan pendapatan beserta deret grafik batang.
@immutable
class RevenueSummary {
  const RevenueSummary({
    required this.title,
    required this.dateLabel,
    required this.total,
    required this.growth,
    required this.axisMax,
    required this.days,
    required this.lastWeekLegend,
    required this.thisWeekLegend,
  });

  final String title;
  final String dateLabel;
  final String total;
  final String growth;

  /// Nilai tertinggi sumbu-Y dalam satuan ribu rupiah.
  final int axisMax;

  final List<RevenueDayData> days;
  final String lastWeekLegend;
  final String thisWeekLegend;

  RevenueSummary copyWith({String? dateLabel}) {
    return RevenueSummary(
      title: title,
      dateLabel: dateLabel ?? this.dateLabel,
      total: total,
      growth: growth,
      axisMax: axisMax,
      days: days,
      lastWeekLegend: lastWeekLegend,
      thisWeekLegend: thisWeekLegend,
    );
  }
}

/// Satu kelompok hari pada grafik (dua batang: minggu ini & minggu lalu).
@immutable
class RevenueDayData {
  const RevenueDayData({
    required this.label,
    required this.thisWeek,
    required this.lastWeek,
  });

  final String label;

  /// Nilai minggu ini (batang biru tua), satuan ribu rupiah.
  final int thisWeek;

  /// Nilai minggu lalu (batang hijau), satuan ribu rupiah.
  final int lastWeek;
}

/// Isi kartu asisten AI.
@immutable
class AssistantCardData {
  const AssistantCardData({
    required this.title,
    required this.subtitle,
    required this.inputHint,
    required this.quickCommands,
  });

  final String title;
  final String subtitle;
  final String inputHint;
  final List<AssistantCommandData> quickCommands;
}

/// Pil perintah cepat pada kartu asisten AI.
@immutable
class AssistantCommandData {
  const AssistantCommandData({
    required this.label,
    required this.labelSize,
    required this.icon,
  });

  final String label;
  final double labelSize;
  final IconData icon;
}

/// Satu baris aktivitas terakhir.
@immutable
class DashboardActivityData {
  const DashboardActivityData({
    required this.name,
    required this.variant,
    required this.sku,
    required this.pack,
    required this.badge,
    required this.imageAsset,
  });

  final String name;
  final String variant;
  final String sku;
  final String pack;
  final String badge;
  final String imageAsset;
}
