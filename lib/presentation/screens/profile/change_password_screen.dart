// lib/presentation/screens/profile/change_password_screen.dart
//
// Layar Ganti Password. Tidak ada frame khusus di Figma; formulir mengikuti
// pola layar auth yang sudah ada.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../providers/profile/change_password_controller.dart';
import '../../widgets/profile/profile_buttons.dart';
import '../../widgets/profile/profile_message_banner.dart';
import '../../widgets/profile/profile_top_bar.dart';
import '../auth/widgets/auth_text_field.dart';

/// Layar formulir ganti password.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
    this.onDone,
  });

  final ChangePasswordController Function() controllerFactory;
  final VoidCallback? onBack;
  final VoidCallback? onDone;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final ChangePasswordController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final bool success = await _controller.submit();
    if (!mounted || success) {
      return;
    }
    final String message =
        _controller.state.errorMessage ?? 'Password gagal diperbarui.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validateCurrent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password saat ini wajib diisi.';
    }
    return null;
  }

  String? _validateNew(String? value) {
    final String next = value ?? '';
    if (next.isEmpty) {
      return 'Password baru wajib diisi.';
    }
    if (next.length < 8) {
      return 'Password baru minimal 8 karakter.';
    }
    if (next == _currentController.text) {
      return 'Password baru harus berbeda dari password saat ini.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    final String confirm = value ?? '';
    if (confirm.isEmpty) {
      return 'Konfirmasi password wajib diisi.';
    }
    if (confirm != _newController.text) {
      return 'Konfirmasi password tidak cocok.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('change_password_screen'),
      backgroundColor: SojuColors.profileBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = math.min(constraints.maxWidth, 480);
          final double scale = width / 430;
          final double topInset = MediaQuery.paddingOf(context).top;
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return Column(
                    children: <Widget>[
                      ProfileTopBar(
                        scale: scale,
                        topInset: topInset,
                        title: 'Ganti Password',
                        onBack: widget.onBack,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            22 * scale,
                            28 * scale,
                            22 * scale,
                            32 * scale + MediaQuery.paddingOf(context).bottom,
                          ),
                          child: _controller.state.isSuccess
                              ? _successBody(scale)
                              : _formBody(scale),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _formBody(double scale) {
    final ChangePasswordState state = _controller.state;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Gunakan minimal 8 karakter. Password baru harus berbeda dari '
            'password saat ini.',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13 * scale,
              height: 1.5,
              color: SojuColors.profileHelpBody,
            ),
          ),
          SizedBox(height: 22 * scale),
          if (state.errorMessage != null) ...<Widget>[
            ProfileMessageBanner(
              key: const Key('change_password_error'),
              scale: scale,
              message: state.errorMessage!,
            ),
            SizedBox(height: 16 * scale),
          ],
          AuthTextField(
            key: const Key('change_password_current'),
            scale: scale,
            controller: _currentController,
            hint: 'Password saat ini',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureCurrent,
            onToggleObscure: () {
              setState(() => _obscureCurrent = !_obscureCurrent);
            },
            onChanged: _controller.updateCurrentPassword,
            validator: _validateCurrent,
            textInputAction: TextInputAction.next,
            enabled: !state.isSubmitting,
          ),
          SizedBox(height: 16 * scale),
          AuthTextField(
            key: const Key('change_password_new'),
            scale: scale,
            controller: _newController,
            hint: 'Password baru',
            icon: Icons.lock_reset_rounded,
            obscure: _obscureNew,
            onToggleObscure: () {
              setState(() => _obscureNew = !_obscureNew);
            },
            onChanged: _controller.updateNewPassword,
            validator: _validateNew,
            textInputAction: TextInputAction.next,
            enabled: !state.isSubmitting,
          ),
          SizedBox(height: 16 * scale),
          AuthTextField(
            key: const Key('change_password_confirm'),
            scale: scale,
            controller: _confirmController,
            hint: 'Konfirmasi password baru',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            onToggleObscure: () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            },
            onChanged: _controller.updateConfirmPassword,
            validator: _validateConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            enabled: !state.isSubmitting,
          ),
          SizedBox(height: 26 * scale),
          ProfilePrimaryButton(
            key: const Key('change_password_submit'),
            scale: scale,
            label: 'Simpan Password',
            isLoading: state.isSubmitting,
            onPressed: state.isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _successBody(double scale) {
    return Container(
      key: const Key('change_password_success'),
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: SojuColors.profileDivider),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 62 * scale,
            height: 62 * scale,
            decoration: const BoxDecoration(
              color: SojuColors.profileIconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 34 * scale,
              color: SojuColors.primary,
            ),
          ),
          SizedBox(height: 18 * scale),
          Text(
            'Password berhasil diperbarui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: SojuColors.ink,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            _controller.state.successMessage ??
                'Gunakan password baru saat masuk berikutnya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13 * scale,
              height: 1.5,
              color: SojuColors.profileHelpBody,
            ),
          ),
          SizedBox(height: 24 * scale),
          ProfilePrimaryButton(
            scale: scale,
            label: 'Kembali ke Pengaturan',
            onPressed: widget.onDone,
          ),
        ],
      ),
    );
  }
}
