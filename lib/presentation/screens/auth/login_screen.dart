import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import 'models/login_form_data.dart';
import 'widgets/auth_divider.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_secondary_button.dart';
import 'widgets/auth_text_field.dart';

/// Layar Masuk (frame Figma `546:1497`).
///
/// Formulir hanya mengumpulkan isian lalu meneruskannya lewat [onSubmit];
/// pemanggilan API dan penanganan hasil berada di luar layar ini.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onSubmit,
    this.onRegisterTap,
    this.onForgotPassword,
    this.onGoogleLogin,
  });

  /// Dipanggil saat isian valid.
  final ValueChanged<LoginFormData>? onSubmit;

  /// Dipanggil saat tab "Daftar" ditekan.
  final VoidCallback? onRegisterTap;

  /// Dipanggil saat tautan "Lupa password?" ditekan.
  final VoidCallback? onForgotPassword;

  /// Dipanggil saat tombol masuk lewat Google ditekan.
  final VoidCallback? onGoogleLogin;

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

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit?.call(
      LoginFormData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
                    subtitle: 'Masuk untuk melanjutkan mengelola keuangan dan '
                        'stok tokomu.',
                    activeTab: AuthTab.login,
                    onTabSelected: _handleTabSelected,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      32 * scale,
                      20 * scale,
                      0,
                    ),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
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
                                onPressed: widget.onForgotPassword,
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
                            AuthPrimaryButton(
                              scale: scale,
                              label: 'Masuk',
                              onPressed: _submit,
                            ),
                            SizedBox(height: 24 * scale),
                            AuthDivider(scale: scale),
                            SizedBox(height: 24 * scale),
                            AuthSecondaryButton(
                              scale: scale,
                              label: 'Lanjutkan dengan Google',
                              onPressed: widget.onGoogleLogin,
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
