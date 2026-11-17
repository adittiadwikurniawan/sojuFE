import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models/register_form_data.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/terms_consent.dart';

/// Layar Daftar (frame Figma `546:1547`).
///
/// Formulir hanya mengumpulkan isian lalu meneruskannya lewat [onSubmit];
/// pemanggilan API dan penanganan hasil berada di luar layar ini sehingga
/// lapisan UI tetap bebas dari logika data.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.onSubmit,
    this.onLoginTap,
    this.onOpenTerms,
    this.onOpenPrivacy,
  });

  /// Dipanggil saat isian valid dan syarat sudah disetujui.
  final ValueChanged<RegisterFormData>? onSubmit;

  /// Dipanggil saat tab "Masuk" ditekan.
  final VoidCallback? onLoginTap;

  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;

  /// Lebar desain acuan (frame Figma 430px).
  static const double designWidth = 430;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with AutomaticKeepAliveClientMixin<RegisterScreen> {
  @override
  bool get wantKeepAlive => true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _handleTabSelected(AuthTab tab) {
    if (tab == AuthTab.login) {
      widget.onLoginTap?.call();
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final bool formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);

    if (!formValid || !_acceptedTerms) {
      return;
    }

    widget.onSubmit?.call(
      RegisterFormData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmationController.text,
        acceptedTerms: _acceptedTerms,
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
          RegisterScreen.designWidth + 50,
        );
        final double scale = contentWidth / RegisterScreen.designWidth;

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
                    subtitle: 'Buat akun sekarang dan tingkatkan penjualan '
                        'tokomu dengan analitik pintar.',
                    activeTab: AuthTab.register,
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
                              controller: _nameController,
                              hint: 'Masukkan Nama Kamu',
                              icon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[
                                AutofillHints.name,
                              ],
                              validator: (String? value) {
                                if (value == null || value.trim().length < 2) {
                                  return 'Nama minimal 2 karakter';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16 * scale),
                            AuthTextField(
                              scale: scale,
                              controller: _emailController,
                              hint: 'Masukkan Email Kamu',
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
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[
                                AutofillHints.newPassword,
                              ],
                              validator: (String? value) {
                                if ((value ?? '').length < 8) {
                                  return 'Password minimal 8 karakter';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16 * scale),
                            AuthTextField(
                              scale: scale,
                              controller: _confirmationController,
                              hint: 'Konfirmasi password',
                              icon: Icons.lock_outline,
                              obscure: _obscureConfirmation,
                              onToggleObscure: () => setState(
                                () => _obscureConfirmation =
                                    !_obscureConfirmation,
                              ),
                              textInputAction: TextInputAction.done,
                              autofillHints: const <String>[
                                AutofillHints.newPassword,
                              ],
                              onFieldSubmitted: (_) => _submit(),
                              validator: (String? value) {
                                if ((value ?? '').isEmpty) {
                                  return 'Konfirmasi password wajib diisi';
                                }
                                if (value != _passwordController.text) {
                                  return 'Konfirmasi password tidak sama';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24 * scale),
                            TermsConsent(
                              scale: scale,
                              value: _acceptedTerms,
                              onChanged: (bool checked) => setState(() {
                                _acceptedTerms = checked;
                                if (checked) {
                                  _showTermsError = false;
                                }
                              }),
                              onOpenTerms: widget.onOpenTerms,
                              onOpenPrivacy: widget.onOpenPrivacy,
                              errorText: _showTermsError
                                  ? 'Setujui syarat & ketentuan dulu ya'
                                  : null,
                            ),
                            SizedBox(height: 24 * scale),
                            AuthPrimaryButton(
                              scale: scale,
                              label: 'Daftar',
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
