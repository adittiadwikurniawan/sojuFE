import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/auth_session_entity.dart';
import 'models/login_form_data.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_portal_selector.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';

/// Layar Masuk (frame Figma `546:1497`) dengan dukungan pemilihan peran
/// `Admin` (`/api/v1/auth/login`) dan `Pelanggan` (`/api/customer/auth/masuk`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.initialPortal = AuthPortal.admin,
    this.onSubmit,
    this.onRegisterTap,
    this.onForgotPassword,
    this.onForgotPasswordWithPortal,
    this.onPortalChanged,
    this.isLoading = false,
    this.errorMessage,
    this.onFieldChanged,
  });

  /// Jalur akun awal saat layar ditampilkan.
  final AuthPortal initialPortal;

  /// Dipanggil saat isian valid.
  final ValueChanged<LoginFormData>? onSubmit;

  /// Dipanggil saat tab "Daftar" ditekan.
  final VoidCallback? onRegisterTap;

  /// Dipanggil saat tautan "Lupa password?" ditekan (kompatibilitas lama).
  final VoidCallback? onForgotPassword;

  /// Dipanggil saat tautan "Lupa password?" ditekan dengan membawa peran terpilih.
  final ValueChanged<AuthPortal>? onForgotPasswordWithPortal;

  /// Dipanggil saat pengguna mengganti jalur `Admin` / `Pelanggan`.
  final ValueChanged<AuthPortal>? onPortalChanged;

  /// Menampilkan indikator proses pada tombol Masuk.
  final bool isLoading;

  /// Pesan galat dari controller auth.
  final String? errorMessage;

  /// Dipanggil saat isian berubah, biasanya untuk menghapus galat lama.
  final VoidCallback? onFieldChanged;

  /// Lebar desain acuan (frame Figma 430px).
  static const double designWidth = 430;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with AutomaticKeepAliveClientMixin<LoginScreen> {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  late AuthPortal _selectedPortal = widget.initialPortal;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleTabSelected(AuthTab tab) {
    if (tab == AuthTab.register) {
      widget.onRegisterTap?.call();
    }
  }

  void _handlePortalChanged(AuthPortal portal) {
    setState(() => _selectedPortal = portal);
    widget.onFieldChanged?.call();
    widget.onPortalChanged?.call(portal);
  }

  void _handleForgotPassword() {
    if (widget.onForgotPasswordWithPortal != null) {
      widget.onForgotPasswordWithPortal!(_selectedPortal);
      return;
    }
    widget.onForgotPassword?.call();
  }

  void _submit() {
    if (widget.isLoading) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit?.call(
      LoginFormData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        portal: _selectedPortal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double contentWidth = math.min(
          constraints.maxWidth,
          LoginScreen.designWidth + 50,
        );
        final double scale = contentWidth / LoginScreen.designWidth;

        final String subtitle = _selectedPortal == AuthPortal.customer
            ? 'Masuk sebagai pelanggan untuk memesan menu favoritmu.'
            : 'Masuk untuk melanjutkan mengelola keuangan dan stok tokomu.';

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 24 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AuthHeader(
                    scale: scale,
                    title: 'Selamat Datang di Buku Kita',
                    subtitle: subtitle,
                    activeTab: AuthTab.login,
                    onTabSelected: _handleTabSelected,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      24 * scale,
                      20 * scale,
                      0,
                    ),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AuthPortalSelector(
                              scale: scale,
                              selectedPortal: _selectedPortal,
                              enabled: !widget.isLoading,
                              onChanged: _handlePortalChanged,
                            ),
                            SizedBox(height: 16 * scale),
                            AuthTextField(
                              scale: scale,
                              controller: _emailController,
                              hint: 'Masukkan email kamu',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[
                                AutofillHints.email,
                              ],
                              onChanged: (_) => widget.onFieldChanged?.call(),
                              validator: (String? value) {
                                final String email = value?.trim() ?? '';
                                if (email.isEmpty) {
                                  return 'Email wajib diisi';
                                }
                                if (!_emailPattern.hasMatch(email)) {
                                  return 'Format email belum benar';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16 * scale),
                            AuthTextField(
                              scale: scale,
                              controller: _passwordController,
                              hint: 'Masukkan password',
                              icon: Icons.lock_outline,
                              obscure: _obscurePassword,
                              onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              textInputAction: TextInputAction.done,
                              autofillHints: const <String>[
                                AutofillHints.password,
                              ],
                              onChanged: (_) => widget.onFieldChanged?.call(),
                              onFieldSubmitted: (_) => _submit(),
                              validator: (String? value) {
                                if ((value ?? '').isEmpty) {
                                  return 'Password wajib diisi';
                                }
                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _handleForgotPassword,
                                style: TextButton.styleFrom(
                                  foregroundColor: SojuColors.link,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8 * scale,
                                    vertical: 6 * scale,
                                  ),
                                  minimumSize: Size(0, 36 * scale),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Lupa password?'),
                              ),
                            ),
                            SizedBox(height: 8 * scale),
                            if (widget.errorMessage != null) ...<Widget>[
                              Text(
                                widget.errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 13 * scale,
                                  height: 1.4,
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                            ],
                            AuthPrimaryButton(
                              scale: scale,
                              label: 'Masuk',
                              isLoading: widget.isLoading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
