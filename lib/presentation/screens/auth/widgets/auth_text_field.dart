import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Medan isian formulir auth: ikon di kiri, hint, dan tombol intip sandi
/// opsional (frame `546:1547`, node `546:1556`).
///
/// Bila [obscure] diisi, [onToggleObscure] wajib tersedia agar pengguna dapat
/// menampilkan/menyembunyikan isi medan.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.scale,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
  });

  final double scale;
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  /// Menyembunyikan isi medan (untuk sandi).
  final bool obscure;

  /// Aksi tombol mata di sisi kanan medan.
  final VoidCallback? onToggleObscure;

  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14 * scale),
      borderSide: BorderSide(color: SojuColors.border, width: 1.2 * scale),
    );

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      style: TextStyle(
        fontFamily: AppTypography.family,
        fontSize: 18 * scale,
        fontWeight: FontWeight.w400,
        color: SojuColors.ink,
      ),
      cursorColor: SojuColors.primary,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: SojuColors.surface,
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 18 * scale,
          fontWeight: FontWeight.w400,
          color: SojuColors.inputHint,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 4 * scale,
          vertical: 18.5 * scale,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: 16 * scale,
            right: 12 * scale,
          ),
          child: Icon(icon, size: 20 * scale, color: SojuColors.fieldIcon),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20 * scale,
                  color: SojuColors.fieldIcon,
                ),
                tooltip: obscure ? 'Tampilkan sandi' : 'Sembunyikan sandi',
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        border: baseBorder,
        enabledBorder: baseBorder,
        disabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(
            color: SojuColors.primary,
            width: 1.6 * scale,
          ),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.2 * scale,
          ),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.6 * scale,
          ),
        ),
      ),
    );
  }
}
