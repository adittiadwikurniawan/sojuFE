import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/auth_session_entity.dart';
import 'models/reset_password_form_data.dart';
import 'widgets/auth_portal_selector.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_secondary_button.dart';
import 'widgets/auth_text_field.dart';

/// Layar Atur Ulang Password menggunakan token reset satu kali pakai
/// untuk peran `Admin` (`/api/v1/auth/reset-password`) maupun `Pelanggan`
/// (`/api/customer/auth/reset-password`).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.initialPortal = AuthPortal.admin,
    this.initialToken = '',
    this.onSubmit,
    this.onCancel,
    this.onBackToLogin,
    this.onBackToLoginWithPortal,
  });

  /// Jalur akun awal (`Admin` atau `Pelanggan`).
  final AuthPortal initialPortal;

  /// Token awal bila dibuka dari parameter rute.
  final String initialToken;

  /// Mengirim token dan password baru ke backend.
  final Future<void> Function(ResetPasswordFormData data)? onSubmit;

  /// Dipanggil saat tombol kembali / Batalkan ditekan.
  final VoidCallback? onCancel;

  /// Dipanggil setelah password berhasil diatur ulang.
  final VoidCallback? onBackToLogin;

  /// Dipanggil setelah password berhasil diatur ulang dengan membawa peran aktif.
  final ValueChanged<AuthPortal>? onBackToLoginWithPortal;

  /// Lebar desain acuan (frame Figma 430px).
  static const double designWidth = 430;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const String _logoAsset = 'assets/images/logo_bukukita.png';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController =
      TextEditingController(text: widget.initialToken);
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  late AuthPortal _selectedPortal = widget.initialPortal;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isSubmitting = false;
  bool _completed = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final Future<void> Function(ResetPasswordFormData data)? onSubmit =
          widget.onSubmit;
      if (onSubmit != null) {
        await onSubmit(
          ResetPasswordFormData(
            token: _tokenController.text.trim(),
            newPassword: _passwordController.text,
            passwordConfirmation: _confirmationController.text,
            portal: _selectedPortal,
          ),
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _completed = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      final String raw = error.toString().replaceFirst('Exception: ', '').trim();
      setState(() {
        _isSubmitting = false;
        _errorMessage = raw.isNotEmpty
            ? raw
            : 'Gagal mengatur ulang password. Periksa token lalu coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SojuColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double contentWidth = math.min(
              constraints.maxWidth,
              ResetPasswordScreen.designWidth + 50,
            );
            final double scale = contentWidth / ResetPasswordScreen.designWidth;

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
                      _buildBackButton(scale),
                      SizedBox(
                        height: 56 * scale,
                        child: Image.asset(_logoAsset, fit: BoxFit.contain),
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        _completed
                            ? 'Password Berhasil Diubah'
                            : 'Atur Ulang Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.w700,
                          height: 34 / 28,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                        child: Text(
                          _completed
                              ? 'Password akun ${_selectedPortal.label} Anda telah diperbarui. Silakan masuk kembali menggunakan password baru.'
                              : 'Pilih jenis akun, tempelkan token dari email reset, lalu buat password baru minimal 8 karakter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                            height: 22.75 / 12,
                            color: SojuColors.inkMuted,
                          ),
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                        child: _completed
                            ? _buildCompletedState(scale)
                            : _buildResetForm(scale),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackButton(double scale) {
    final VoidCallback? onCancel = widget.onCancel;
    if (onCancel == null) {
      return SizedBox(height: 8 * scale);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 4 * scale, top: 4 * scale),
        child: IconButton(
          onPressed: onCancel,
          icon: Icon(Icons.arrow_back, size: 22 * scale),
          color: SojuColors.ink,
          tooltip: 'Kembali',
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  void _handleBackToLogin() {
    if (widget.onBackToLoginWithPortal != null) {
      widget.onBackToLoginWithPortal!(_selectedPortal);
      return;
    }
    (widget.onBackToLogin ?? widget.onCancel)?.call();
  }

  Widget _buildCompletedState(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            width: 72 * scale,
            height: 72 * scale,
            decoration: const BoxDecoration(
              color: SojuColors.incomeSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40 * scale,
              color: SojuColors.success,
            ),
          ),
        ),
        SizedBox(height: 24 * scale),
        AuthPrimaryButton(
          scale: scale,
          label: 'Masuk Sekarang',
          onPressed: _handleBackToLogin,
        ),
      ],
    );
  }

  Widget _buildResetForm(double scale) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AuthPortalSelector(
              scale: scale,
              selectedPortal: _selectedPortal,
              enabled: !_isSubmitting,
              onChanged: (AuthPortal portal) {
                setState(() {
                  _selectedPortal = portal;
                  _errorMessage = null;
                });
              },
            ),
            SizedBox(height: 16 * scale),
            AuthTextField(
              scale: scale,
              controller: _tokenController,
              hint: 'Masukkan token reset password',
              icon: Icons.vpn_key_outlined,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              validator: (String? value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return 'Token reset password wajib diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16 * scale),
            AuthTextField(
              scale: scale,
              controller: _passwordController,
              hint: 'Masukkan password baru',
              icon: Icons.lock_outline,
              obscure: _obscurePassword,
              onToggleObscure: () => setState(
                () => _obscurePassword = !_obscurePassword,
              ),
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.newPassword],
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              validator: (String? value) {
                final String password = value ?? '';
                if (password.isEmpty) {
                  return 'Password baru wajib diisi';
                }
                if (password.length < 8) {
                  return 'Password baru minimal 8 karakter';
                }
                return null;
              },
            ),
            SizedBox(height: 16 * scale),
            AuthTextField(
              scale: scale,
              controller: _confirmationController,
              hint: 'Konfirmasi password baru',
              icon: Icons.lock_outline,
              obscure: _obscureConfirmation,
              onToggleObscure: () => setState(
                () => _obscureConfirmation = !_obscureConfirmation,
              ),
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.newPassword],
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
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
            if (_errorMessage != null) ...<Widget>[
              SizedBox(height: 12 * scale),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13 * scale,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            SizedBox(height: 24 * scale),
            AuthPrimaryButton(
              scale: scale,
              label: 'Atur Ulang Password',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            SizedBox(height: 12 * scale),
            AuthSecondaryButton(
              scale: scale,
              label: 'Batalkan',
              onPressed: widget.onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
