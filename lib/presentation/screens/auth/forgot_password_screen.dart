import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/auth_session_entity.dart';
import 'widgets/auth_portal_selector.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_secondary_button.dart';
import 'widgets/auth_text_field.dart';

/// Layar Lupa Password (frame Figma `546:1361`) untuk Admin maupun Pelanggan.
///
/// Dua keadaan dalam satu layar:
/// 1. pemilihan peran (`Admin` / `Pelanggan`) + pengisian email, lalu
/// 2. konfirmasi bahwa instruksi reset password telah dikirim beserta pintasan
///    menuju layar input token Atur Ulang Password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialPortal = AuthPortal.admin,
    this.onSendResetLink,
    this.onRequestReset,
    this.onOpenResetPassword,
    this.onCancel,
    this.onBackToLogin,
  });

  /// Jalur akun awal (`Admin` atau `Pelanggan`).
  final AuthPortal initialPortal;

  /// Callback kompatibilitas lama untuk mengirim tautan reset ke [email].
  final Future<void> Function(String email)? onSendResetLink;

  /// Mengirim permintaan reset password ke [email] sesuai [portal].
  final Future<void> Function(String email, AuthPortal portal)? onRequestReset;

  /// Membuka layar Atur Ulang Password untuk memasukkan token reset.
  final ValueChanged<AuthPortal>? onOpenResetPassword;

  /// Dipanggil saat tombol "Batalkan" atau panah kembali ditekan.
  final VoidCallback? onCancel;

  /// Dipanggil saat pengguna kembali ke layar masuk dari keadaan terkirim.
  final VoidCallback? onBackToLogin;

  /// Lebar desain acuan (frame Figma 430px).
  static const double designWidth = 430;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const String _logoAsset = 'assets/images/logo_bukukita.png';
  static const String _illustrationAsset =
      'assets/images/forgot_password_illustration.png';
  static const String _emailSentAsset =
      'assets/images/forgot_password_email_sent.png';

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  late AuthPortal _selectedPortal = widget.initialPortal;
  bool _isSending = false;
  bool _sent = false;
  String? _errorMessage;

  String get _email => _emailController.text.trim();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_isSending) {
      return;
    }
    if (!_sent && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    final bool isResend = _sent;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      if (widget.onRequestReset != null) {
        await widget.onRequestReset!(_email, _selectedPortal);
      } else if (widget.onSendResetLink != null) {
        await widget.onSendResetLink!(_email);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isSending = false;
        _sent = true;
      });
      if (isResend) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tautan reset sudah dikirim ulang.')),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSending = false;
        _errorMessage = 'Tautan gagal dikirim. Periksa koneksi lalu coba lagi.';
      });
    }
  }

  void _editEmail() {
    setState(() {
      _sent = false;
      _errorMessage = null;
    });
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
              ForgotPasswordScreen.designWidth + 50,
            );
            final double scale =
                contentWidth / ForgotPasswordScreen.designWidth;

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
                        _sent ? 'Cek Email Kamu' : 'Lupa Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.w700,
                          height: 34 / 28,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      _buildSubtitle(scale),
                      SizedBox(height: 12 * scale),
                      Center(
                        child: SizedBox(
                          width: (_sent ? 165 : 230) * scale,
                          child: _sent
                              ? ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    SojuColors.emailSent,
                                    BlendMode.color,
                                  ),
                                  child: Image.asset(
                                    _emailSentAsset,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Image.asset(
                                  _illustrationAsset,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                        child: _sent
                            ? _buildSentActions(scale)
                            : _buildEmailForm(scale),
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

  Widget _buildSubtitle(double scale) {
    final TextStyle base = TextStyle(
      fontFamily: AppTypography.family,
      fontSize: 12 * scale,
      fontWeight: FontWeight.w500,
      height: 22.75 / 12,
      color: SojuColors.inkMuted,
    );

    if (!_sent) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        child: Text(
          'Masukkan alamat email yang terdaftar pada akun Anda',
          textAlign: TextAlign.center,
          style: base,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            const TextSpan(
              text: 'Jika akun terdaftar dan aktif, instruksi reset password telah dikirim ke ',
            ),
            TextSpan(
              text: _email,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(
              text: '. Gunakan token dari email tersebut untuk mengatur ulang password.',
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: base,
      ),
    );
  }

  Widget _buildEmailForm(double scale) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AuthPortalSelector(
              scale: scale,
              selectedPortal: _selectedPortal,
              enabled: !_isSending,
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
              controller: _emailController,
              hint: 'Masukkan Email Kamu',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.email],
              onFieldSubmitted: (_) => _sendResetLink(),
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
            if (_errorMessage != null) ...<Widget>[
              SizedBox(height: 8 * scale),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            SizedBox(height: 20 * scale),
            AuthPrimaryButton(
              scale: scale,
              label: 'Lanjutkan',
              onPressed: _sendResetLink,
              isLoading: _isSending,
            ),
            SizedBox(height: 12 * scale),
            AuthSecondaryButton(
              scale: scale,
              label: 'Batalkan',
              onPressed: widget.onCancel,
            ),
            if (widget.onOpenResetPassword != null) ...<Widget>[
              SizedBox(height: 8 * scale),
              Center(
                child: TextButton(
                  onPressed: _isSending
                      ? null
                      : () => widget.onOpenResetPassword!(_selectedPortal),
                  style: TextButton.styleFrom(
                    foregroundColor: SojuColors.link,
                    minimumSize: Size(0, 36 * scale),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Sudah punya token reset? Atur ulang password'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSentActions(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_errorMessage != null) ...<Widget>[
          Text(
            _errorMessage!,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 12 * scale),
        ],
        Text(
          'Belum menerima email? Periksa folder spam atau kirim ulang.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 12 * scale,
            fontWeight: FontWeight.w400,
            height: 22.75 / 12,
            color: SojuColors.inkMuted,
          ),
        ),
        SizedBox(height: 16 * scale),
        if (widget.onOpenResetPassword != null) ...<Widget>[
          AuthPrimaryButton(
            scale: scale,
            label: 'Masukkan Token Reset',
            onPressed: () => widget.onOpenResetPassword!(_selectedPortal),
          ),
          SizedBox(height: 12 * scale),
          AuthSecondaryButton(
            scale: scale,
            label: 'Kembali ke Masuk',
            onPressed: widget.onBackToLogin ?? () {},
          ),
        ] else
          AuthPrimaryButton(
            scale: scale,
            label: 'Kembali ke Masuk',
            onPressed: widget.onBackToLogin ?? () {},
          ),
        SizedBox(height: 12 * scale),
        AuthSecondaryButton(
          scale: scale,
          label: 'Kirim ulang tautan',
          onPressed: _sendResetLink,
          isLoading: _isSending,
        ),
        SizedBox(height: 4 * scale),
        Center(
          child: TextButton(
            onPressed: _isSending ? null : _editEmail,
            style: TextButton.styleFrom(
              foregroundColor: SojuColors.link,
              minimumSize: Size(0, 36 * scale),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Gunakan email lain'),
          ),
        ),
      ],
    );
  }
}
