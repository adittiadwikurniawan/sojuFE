import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import 'models/register_form_data.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/terms_consent.dart';

/// Layar Daftar Akun Pelanggan (`/api/customer/auth/daftar`).
///
/// Pendaftaran publik hanya membuat akun Pelanggan (`CUSTOMER`).
/// Pembuatan akun pengelola (`ADMIN` / `SUPER_ADMIN`) dilakukan secara
/// tertutup oleh Super Admin sesuai AD-08 & AD-09.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.onSubmit,
    this.onLoginTap,
    this.onOpenTerms,
    this.onOpenPrivacy,
    this.isLoading = false,
    this.errorMessage,
    this.onFieldChanged,
  });

  /// Dipanggil saat isian valid dan syarat sudah disetujui.
  final ValueChanged<RegisterFormData>? onSubmit;

  /// Dipanggil saat tab "Masuk" ditekan.
  final VoidCallback? onLoginTap;

  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;

  /// Menampilkan indikator proses pada tombol Daftar.
  final bool isLoading;

  /// Pesan galat dari controller auth.
  final String? errorMessage;

  /// Dipanggil saat isian berubah, biasanya untuk menghapus galat lama.
  final VoidCallback? onFieldChanged;

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
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
    _phoneController.dispose();
    _addressController.dispose();
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
    if (widget.isLoading) {
      return;
    }
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
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
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
                    subtitle:
                        'Buat akun pelanggan untuk memesan menu dan memantau pesananmu.',
                    activeTab: AuthTab.register,
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
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 10 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: SojuColors.infoSoft,
                                borderRadius:
                                    BorderRadius.circular(12 * scale),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.storefront_outlined,
                                    size: 18 * scale,
                                    color: SojuColors.primary,
                                  ),
                                  SizedBox(width: 8 * scale),
                                  Expanded(
                                    child: Text(
                                      'Pendaftaran khusus akun Pelanggan.',
                                      style: TextStyle(
                                        fontFamily: AppTypography.family,
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.w500,
                                        color: SojuColors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16 * scale),
                            AuthTextField(
                              scale: scale,
                              controller: _nameController,
                              hint: 'Masukkan Nama Kamu',
                              icon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[
                                AutofillHints.name,
                              ],
                              onChanged: (_) => widget.onFieldChanged?.call(),
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
                              controller: _phoneController,
                              hint: 'Masukkan Nomor Telepon',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[
                                AutofillHints.telephoneNumber,
                              ],
                              onChanged: (_) => widget.onFieldChanged?.call(),
                              validator: (String? value) {
                                final String phone = value?.trim() ?? '';
                                if (phone.isEmpty) {
                                  return 'Nomor telepon wajib diisi';
                                }
                                if (phone.length < 8) {
                                  return 'Nomor telepon minimal 8 digit';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16 * scale),
                            AuthTextField(
                              scale: scale,
                              controller: _addressController,
                              hint: 'Masukkan Alamat Lengkap',
                              icon: Icons.location_on_outlined,
                              keyboardType: TextInputType.streetAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[
                                AutofillHints.fullStreetAddress,
                              ],
                              onChanged: (_) => widget.onFieldChanged?.call(),
                              validator: (String? value) {
                                final String address = value?.trim() ?? '';
                                if (address.isEmpty) {
                                  return 'Alamat wajib diisi';
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
                              onChanged: (_) => widget.onFieldChanged?.call(),
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
                              onChanged: (_) => widget.onFieldChanged?.call(),
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
                              label: 'Daftar',
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
