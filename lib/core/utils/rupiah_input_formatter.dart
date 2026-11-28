import 'package:flutter/services.dart';

/// Formatter input angka Rupiah dengan pemisah ribuan titik otomatis
/// (mis. `33333` → `33.333`, `1500000` → `1.500.000`).
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  /// Memformat string digit mentah menjadi format ribuan Indonesia (`33.333`).
  static String formatDigits(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return '';
    }
    final String normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    return normalized.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Mengambil nilai integer bersih dari teks terformat (`33.333` → `33333`).
  static int parseDigits(String formatted) {
    final String clean = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String formatted = formatDigits(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
