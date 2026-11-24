// lib/presentation/screens/profile/profile_account_screen.dart
//
// Layar Akun Saya (frame Figma `546:5592`).
//
// Data profil dan foto masih memakai datasource mock, tetapi seluruh aksi
// melewati usecase/repository yang siap diganti endpoint API.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../providers/profile/profile_controller.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/profile/profile_buttons.dart';
import '../../widgets/profile/profile_field_card.dart';
import '../../widgets/profile/profile_message_banner.dart';
import '../../widgets/profile/profile_top_bar.dart';
import 'models/profile_view_data.dart';

/// Layar edit data akun dan foto profil.
class ProfileAccountScreen extends StatefulWidget {
  const ProfileAccountScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
    this.onSaved,
    this.onPickPhoto,
  });

  final ProfileController Function() controllerFactory;
  final VoidCallback? onBack;
  final ValueChanged<ProfileEntity>? onSaved;

  /// Callback opsional untuk pemilih foto asli. Bila null, layar memakai
  /// pilihan foto contoh (mode mock).
  final Future<ProfilePhotoDraft?> Function()? onPickPhoto;

  @override
  State<ProfileAccountScreen> createState() => _ProfileAccountScreenState();
}

class _ProfileAccountScreenState extends State<ProfileAccountScreen> {
  late final ProfileController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _fieldsSynced = false;
  String? _syncedProfileId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ProfileViewData.sample.name);
    _emailController =
        TextEditingController(text: ProfileViewData.sample.email);
    _phoneController =
        TextEditingController(text: ProfileViewData.sample.phone);
    _controller = widget.controllerFactory();
    _controller.addListener(_onControllerChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    final ProfileEntity? profile = _controller.state.profile;
    if (profile != null && (!_fieldsSynced || _syncedProfileId != profile.id)) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _fieldsSynced = true;
      _syncedProfileId = profile.id;
    }
    setState(() {});
  }

  Future<void> _save() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final ProfileUpdateDraft draft = ProfileUpdateDraft(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    final bool saved = await _controller.save(draft);
    if (!mounted) {
      return;
    }
    if (saved) {
      final ProfileEntity? profile = _controller.state.profile;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan.')),
      );
      if (profile != null) {
        widget.onSaved?.call(profile);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.state.errorMessage ?? 'Profil gagal disimpan.',
          ),
        ),
      );
    }
  }

  Future<void> _openPhotoSheet() async {
    final _PhotoAction? action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        final double scale =
            math.min(MediaQuery.sizeOf(context).width, 480) / 430;
        final bool hasRealPicker = widget.onPickPhoto != null;
        return Container(
          key: const Key('profile_photo_sheet'),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28 * scale),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            22 * scale,
            14 * scale,
            22 * scale,
            24 * scale,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 52 * scale,
                height: 6 * scale,
                decoration: BoxDecoration(
                  color: SojuColors.profileSwitchInactive,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(height: 18 * scale),
              Text(
                'Foto Profil',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                hasRealPicker
                    ? 'Pilih foto baru untuk profil Anda.'
                    : 'Mode demo: gunakan foto contoh atau hapus foto. '
                        'Pemilih galeri dapat dihubungkan lewat API.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * scale,
                  height: 1.45,
                  color: SojuColors.profileHelpBody,
                ),
              ),
              SizedBox(height: 18 * scale),
              _PhotoSheetOption(
                key: const Key('profile_photo_use_sample'),
                scale: scale,
                icon: hasRealPicker
                    ? Icons.photo_library_outlined
                    : Icons.image_outlined,
                label:
                    hasRealPicker ? 'Pilih dari Galeri' : 'Gunakan Foto Contoh',
                onTap: () => Navigator.of(context).pop(
                  hasRealPicker ? _PhotoAction.gallery : _PhotoAction.sample,
                ),
              ),
              SizedBox(height: 8 * scale),
              _PhotoSheetOption(
                key: const Key('profile_photo_remove'),
                scale: scale,
                icon: Icons.delete_outline_rounded,
                label: 'Hapus Foto',
                foregroundColor: const Color(0xFFDC2626),
                onTap: () => Navigator.of(context).pop(_PhotoAction.remove),
              ),
              SizedBox(height: 8 * scale),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.profileMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (action == null || !mounted) {
      return;
    }

    ProfilePhotoDraft? draft;
    switch (action) {
      case _PhotoAction.gallery:
        draft = await widget.onPickPhoto?.call();
      case _PhotoAction.sample:
        draft = const ProfilePhotoDraft(
          assetPath: 'assets/images/avatar_profil.png',
        );
      case _PhotoAction.remove:
        draft = const ProfilePhotoDraft(remove: true);
    }

    if (draft == null || !mounted) {
      return;
    }

    final bool updated = await _controller.updatePhoto(draft);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated
              ? 'Foto profil diperbarui.'
              : (_controller.state.errorMessage ??
                  'Foto profil gagal diperbarui.'),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi.';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    final RegExp pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final String phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'No telepon wajib diisi.';
    }
    final String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9 || digits.length > 15) {
      return 'Nomor telepon harus 9-15 digit.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('profile_account_screen'),
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
                  return _body(
                    context,
                    scale: scale,
                    topInset: topInset,
                    state: _controller.state,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context, {
    required double scale,
    required double topInset,
    required ProfileState state,
  }) {
    final ProfileEntity? profile = state.profile;
    final String name = profile?.name ?? _nameController.text;
    final String initials = profile?.initials ?? _initialsOf(name);

    return Column(
      children: <Widget>[
        ProfileTopBar(
          scale: scale,
          topInset: topInset,
          title: 'Akun Saya',
          onBack: widget.onBack,
        ),
        if (state.isSaving || state.isUploadingPhoto)
          LinearProgressIndicator(
            minHeight: 2 * scale,
            color: SojuColors.primary,
            backgroundColor: SojuColors.profileDivider,
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22 * scale,
              28 * scale,
              22 * scale,
              32 * scale + MediaQuery.paddingOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: <Widget>[
                  ProfileAvatar(
                    key: const Key('profile_avatar_edit'),
                    size: 127 * scale,
                    scale: scale,
                    initials: initials,
                    assetPath: profile?.avatarAsset ??
                        (profile == null
                            ? ProfileViewData.sample.avatarAsset
                            : null),
                    imageUrl: profile?.avatarUrl,
                    onTap: _openPhotoSheet,
                    showEditBadge: true,
                    isLoading: state.isUploadingPhoto,
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    'Ketuk foto untuk mengganti',
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12 * scale,
                      color: SojuColors.profileMuted,
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  if (state.errorMessage != null) ...<Widget>[
                    ProfileMessageBanner(
                      scale: scale,
                      message: state.errorMessage!,
                    ),
                    SizedBox(height: 16 * scale),
                  ],
                  ProfileFieldCard(
                    scale: scale,
                    label: 'Nama',
                    fieldKey: const Key('profile_name_field'),
                    controller: _nameController,
                    hint: 'Masukkan nama',
                    textInputAction: TextInputAction.next,
                    validator: _validateName,
                  ),
                  SizedBox(height: 18 * scale),
                  ProfileFieldCard(
                    scale: scale,
                    label: 'Email',
                    fieldKey: const Key('profile_email_field'),
                    controller: _emailController,
                    hint: 'Masukkan email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 18 * scale),
                  ProfileFieldCard(
                    scale: scale,
                    label: 'No Telepon',
                    fieldKey: const Key('profile_phone_field'),
                    controller: _phoneController,
                    hint: 'Masukkan nomor telepon',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    validator: _validatePhone,
                  ),
                  SizedBox(height: 30 * scale),
                  ProfilePrimaryButton(
                    key: const Key('profile_save_button'),
                    scale: scale,
                    label: 'Simpan',
                    isLoading: state.isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _initialsOf(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

enum _PhotoAction { gallery, sample, remove }

class _PhotoSheetOption extends StatelessWidget {
  const _PhotoSheetOption({
    super.key,
    required this.scale,
    required this.icon,
    required this.label,
    required this.onTap,
    this.foregroundColor = SojuColors.ink,
  });

  final double scale;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.profileBackground,
      borderRadius: BorderRadius.circular(14 * scale),
      child: InkWell(
        borderRadius: BorderRadius.circular(14 * scale),
        onTap: onTap,
        child: SizedBox(
          height: 54 * scale,
          child: Row(
            children: <Widget>[
              SizedBox(width: 16 * scale),
              Icon(icon, size: 22 * scale, color: foregroundColor),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
