// lib/presentation/screens/profile/notification_preferences_screen.dart
//
// Layar Notifikasi (frame Figma `546:5634`).
//
// Toggle disimpan lewat usecase mock yang siap diganti endpoint preferensi.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../providers/profile/notification_preferences_controller.dart';
import '../../widgets/profile/profile_buttons.dart';
import '../../widgets/profile/profile_message_banner.dart';
import '../../widgets/profile/profile_tiles.dart';
import '../../widgets/profile/profile_top_bar.dart';

/// Layar preferensi notifikasi.
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
  });

  final NotificationPreferencesController Function() controllerFactory;
  final VoidCallback? onBack;

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late final NotificationPreferencesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bool saved = await _controller.save();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Preferensi notifikasi disimpan.'
              : (_controller.state.errorMessage ??
                  'Preferensi notifikasi gagal disimpan.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('notification_preferences_screen'),
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
    required NotificationPreferencesState state,
  }) {
    final NotificationPreferencesEntity? draft = state.draft;

    return Column(
      children: <Widget>[
        ProfileTopBar(
          scale: scale,
          topInset: topInset,
          title: 'Notifikasi',
          onBack: widget.onBack,
        ),
        if (state.isSaving)
          LinearProgressIndicator(
            minHeight: 2 * scale,
            color: SojuColors.primary,
            backgroundColor: SojuColors.profileDivider,
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22 * scale,
              26 * scale,
              22 * scale,
              32 * scale + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Atur pemberitahuan yang ingin Anda terima dari Buku Kita.',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13 * scale,
                    height: 1.5,
                    color: SojuColors.profileHelpBody,
                  ),
                ),
                SizedBox(height: 20 * scale),
                if (state.isLoading && draft == null)
                  Padding(
                    padding: EdgeInsets.only(top: 40 * scale),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else if (draft == null)
                  Column(
                    children: <Widget>[
                      ProfileMessageBanner(
                        scale: scale,
                        message: state.errorMessage ??
                            'Preferensi notifikasi gagal dimuat.',
                      ),
                      SizedBox(height: 16 * scale),
                      ProfilePrimaryButton(
                        scale: scale,
                        label: 'Coba Lagi',
                        onPressed: _controller.load,
                      ),
                    ],
                  )
                else ...<Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: SojuColors.surface,
                      borderRadius: BorderRadius.circular(15 * scale),
                      border: Border.all(color: SojuColors.profileDivider),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 18 * scale),
                    child: Column(
                      children: <Widget>[
                        ProfileToggleTile(
                          scale: scale,
                          label: 'Stok Menipis',
                          description:
                              'Peringatan saat stok mencapai batas minimum.',
                          value: draft.stockLow,
                          switchKey: const Key('notification_stock_low'),
                          onChanged: state.isSaving
                              ? null
                              : _controller.toggleStockLow,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: SojuColors.profileDivider,
                        ),
                        ProfileToggleTile(
                          scale: scale,
                          label: 'Selisih Kas',
                          description:
                              'Pemberitahuan saat kas tidak sesuai catatan.',
                          value: draft.cashDifference,
                          switchKey: const Key('notification_cash_difference'),
                          onChanged: state.isSaving
                              ? null
                              : _controller.toggleCashDifference,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: SojuColors.profileDivider,
                        ),
                        ProfileToggleTile(
                          scale: scale,
                          label: 'Transaksi Harian',
                          description: 'Ringkasan transaksi setiap akhir hari.',
                          value: draft.dailyTransaction,
                          switchKey:
                              const Key('notification_daily_transaction'),
                          onChanged: state.isSaving
                              ? null
                              : _controller.toggleDailyTransaction,
                        ),
                      ],
                    ),
                  ),
                  if (state.errorMessage != null) ...<Widget>[
                    SizedBox(height: 16 * scale),
                    ProfileMessageBanner(
                      scale: scale,
                      message: state.errorMessage!,
                    ),
                  ],
                  SizedBox(height: 28 * scale),
                  ProfilePrimaryButton(
                    key: const Key('notification_save_button'),
                    scale: scale,
                    label: 'Simpan',
                    isLoading: state.isSaving,
                    onPressed: state.isSaving ? null : _save,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
