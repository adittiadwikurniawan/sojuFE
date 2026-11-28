import 'package:flutter/material.dart';

/// Utilitas format angka dan tanggal Indonesia.
///
/// Dibuat tanpa dependensi tambahan (tanpa `intl`) agar ringan dan mudah
/// diuji. Semua nilai nominal dinyatakan dalam rupiah penuh.

const List<String> _monthNames = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const List<String> _monthShortNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const List<String> _weekdayNames = <String>[
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const List<String> _weekdayShortNames = <String>[
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
  'Min',
];

/// Mengelompokkan angka dengan pemisah ribuan titik: `15000000` → `15.000.000`.
String groupDigits(int value) {
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// `15000000` → `Rp 15.000.000`; nilai negatif menjadi `-Rp 10.000.000`.
/// Dengan [withSign] aktif, nilai positif menjadi `+ Rp 15.000.000` dan
/// negatif menjadi `- Rp 10.000.000`.
String formatRupiah(num value, {bool withSign = false}) {
  final String amount = 'Rp ${groupDigits(value.round())}';
  if (value == 0) {
    return amount;
  }
  if (!withSign) {
    return value < 0 ? '-$amount' : amount;
  }
  return value < 0 ? '- $amount' : '+ $amount';
}

/// Format ringkas untuk legenda dan label grafik: `15 Jt`, `500 rb`.
String formatCompactRupiah(num value, {bool withSign = false}) {
  final double absolute = value.abs().toDouble();
  late final String text;
  if (absolute >= 1000000000) {
    text = 'Rp ${_compact(absolute / 1000000000)} M';
  } else if (absolute >= 1000000) {
    text = 'Rp ${_compact(absolute / 1000000)} Jt';
  } else if (absolute >= 1000) {
    text = 'Rp ${_compact(absolute / 1000)} rb';
  } else {
    text = 'Rp ${absolute.round()}';
  }
  if (!withSign || value == 0) {
    return text;
  }
  return value < 0 ? '- $text' : '+ $text';
}

String _compact(double value) {
  if (value >= 100) {
    return value.round().toString();
  }
  final String text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

/// `0.6` → `60%`.
String formatPercent(double fraction, {int decimals = 0}) {
  final String text = (fraction * 100).toStringAsFixed(decimals);
  return '${decimals == 0 ? text : _trimZeros(text)}%';
}

/// `13.636` → `+13.6%`.
String formatPercentChange(double percent) {
  final String text = _trimZeros(percent.abs().toStringAsFixed(1));
  if (percent > 0) {
    return '+$text%';
  }
  if (percent < 0) {
    return '-$text%';
  }
  return '0%';
}

String _trimZeros(String value) {
  if (!value.contains('.')) {
    return value;
  }
  return value.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// Label ringkas untuk sumbu grafik dalam satuan ribuan: `500` → `500rb`,
/// `3000` → `3jt`.
String formatChartValue(int thousands) {
  if (thousands == 0) {
    return '0';
  }
  if (thousands >= 1000) {
    final String text = _trimZeros((thousands / 1000).toStringAsFixed(1));
    return '${text}jt';
  }
  return '${thousands}rb';
}

/// `DateTime(2026, 10)` → `Oktober 2026`.
String formatMonthYear(DateTime month) {
  return '${_monthNames[month.month - 1]} ${month.year}';
}

/// Rentang tanggal ringkas: `1–31 Okt 2026`, `25 Okt – 3 Nov 2026`.
String formatDateRange(DateTimeRange range) {
  final DateTime start = range.start;
  final DateTime end = range.end;
  if (_isSameDay(start, end)) {
    return '${start.day} ${_monthShortNames[start.month - 1]} ${start.year}';
  }
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} '
        '${_monthShortNames[start.month - 1]} ${start.year}';
  }
  if (start.year == end.year) {
    return '${start.day} ${_monthShortNames[start.month - 1]} – '
        '${end.day} ${_monthShortNames[end.month - 1]} ${start.year}';
  }
  return '${start.day} ${_monthShortNames[start.month - 1]} ${start.year} – '
      '${end.day} ${_monthShortNames[end.month - 1]} ${end.year}';
}

/// `DateTime(2026, 10, 31)` → `31 Okt`.
String formatDayMonth(DateTime date) {
  return '${date.day} ${_monthShortNames[date.month - 1]}';
}

/// `DateTime(2026, 10, 31)` → `Sabtu, 31 Okt`.
String formatWeekdayDate(DateTime date) {
  return '${weekdayName(date)}, ${formatDayMonth(date)}';
}

/// Jam 24 jam dengan nol di depan: `DateTime(2026, 10, 31, 9, 5)` → `09:05`.
String formatClock(DateTime time) {
  final String hour = time.hour.toString().padLeft(2, '0');
  final String minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Nama hari panjang, mis. `Senin`.
String weekdayName(DateTime date) => _weekdayNames[date.weekday - 1];

/// Nama hari pendek, mis. `Sen`.
String weekdayShort(DateTime date) => _weekdayShortNames[date.weekday - 1];

/// Awal minggu (Senin) pada pukul 00.00.
DateTime startOfWeek(DateTime date) {
  final DateTime day = dateOnly(date);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// Menghapus komponen jam dari [date].
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
