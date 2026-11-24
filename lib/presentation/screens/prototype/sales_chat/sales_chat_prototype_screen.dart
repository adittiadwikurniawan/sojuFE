import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/sales_chat_entity.dart';
import '../../../providers/sales_chat/sales_chat_controller.dart';
import 'widgets/sales_chat_composer.dart';
import 'widgets/sales_chat_header.dart';
import 'widgets/sales_chat_message_bubble.dart';
import 'widgets/sales_draft_editor_sheet.dart';

/// Layar prototype "Chat Input Penjualan Harian/Shift".
///
/// Halaman ini berada di luar shell/navbar produksi dan hanya dibuka bila
/// feature flag prototype aktif. Semua data adalah simulasi lokal; tidak ada
/// HTTP, tidak ada endpoint AI, dan tidak ada penulisan transaksi.
class SalesChatPrototypeScreen extends StatefulWidget {
  const SalesChatPrototypeScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
  });

  final SalesChatController Function() controllerFactory;
  final VoidCallback? onBack;

  @override
  State<SalesChatPrototypeScreen> createState() =>
      _SalesChatPrototypeScreenState();
}

class _SalesChatPrototypeScreenState extends State<SalesChatPrototypeScreen> {
  late final SalesChatController _controller;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    _controller.addListener(_onStateChanged);
    _scrollToBottom(animate: false);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) {
        return;
      }
      final double target = _scroll.position.maxScrollExtent;
      if (animate) {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      } else {
        _scroll.jumpTo(target);
      }
    });
  }

  Future<void> _openCorrection(SalesChatDraft draft) async {
    final SalesChatDraft? updated = await showModalBottomSheet<SalesChatDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x4D0F172A),
      elevation: 0,
      builder: (BuildContext sheetContext) =>
          SalesDraftEditorSheet(draft: draft),
    );
    if (updated != null && mounted) {
      _controller.applyCorrection(updated);
    }
  }

  void _confirmSimulation() {
    final bool confirmed = _controller.confirmSimulation();
    if (!confirmed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi field dan perbaiki selisih total sebelum konfirmasi.',
          ),
        ),
      );
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final SalesChatState state = _controller.state;
    final double width = MediaQuery.sizeOf(context).width;
    final double scale = math.min(width, 480) / 430;

    int latestDraftIndex = -1;
    for (int i = 0; i < state.messages.length; i++) {
      if (state.messages[i].draft != null) {
        latestDraftIndex = i;
      }
    }

    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: <Widget>[
                SalesChatHeader(scale: scale, onBack: _handleBack),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    14 * scale,
                    10 * scale,
                    14 * scale,
                    0,
                  ),
                  child: _DemoNotice(
                    scale: scale,
                    onTryIncomplete: () => _controller.sendMessage(
                      SalesChatController.incompleteRecapInput,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      14 * scale,
                      12 * scale,
                      14 * scale,
                      16 * scale,
                    ),
                    children: <Widget>[
                      if (state.messages.isEmpty)
                        _WelcomeCard(
                          scale: scale,
                          onUseSample: () => _controller.sendMessage(
                            SalesChatController.sampleRecapInput,
                          ),
                        ),
                      for (int index = 0;
                          index < state.messages.length;
                          index++) ...<Widget>[
                        if (index > 0) SizedBox(height: 14 * scale),
                        SalesChatMessageBubble(
                          scale: scale,
                          message: state.messages[index],
                          onCorrect: _openCorrection,
                          onConfirm: index == latestDraftIndex
                              ? _confirmSimulation
                              : null,
                          isSimulationComplete: index == latestDraftIndex &&
                              state.isSimulationComplete,
                          simulationMessage: index == latestDraftIndex
                              ? state.simulationMessage
                              : null,
                          errorMessage: index == latestDraftIndex
                              ? state.errorMessage
                              : null,
                        ),
                      ],
                      if (state.status == SalesChatStatus.parsing) ...<Widget>[
                        SizedBox(height: 12 * scale),
                        _TypingIndicator(scale: scale),
                      ],
                    ],
                  ),
                ),
                SalesChatComposer(
                  scale: scale,
                  isSending: state.status == SalesChatStatus.parsing,
                  onSend: _controller.sendMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice({required this.scale, required this.onTryIncomplete});

  final double scale;
  final VoidCallback onTryIncomplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sales_chat_demo_notice'),
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: SojuColors.demoSoft,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: SojuColors.demoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.science_outlined,
                size: 14 * scale,
                color: SojuColors.demoInk,
              ),
              SizedBox(width: 5 * scale),
              Expanded(
                child: Text(
                  'Mode demo — data tidak disimpan',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.demoInk,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Percakapan dan draft di layar ini adalah contoh. Tidak ada '
            'request ke AI dan tidak ada transaksi yang masuk ke pembukuan.',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 9.5 * scale,
              height: 1.4,
              color: SojuColors.demoInk,
            ),
          ),
          SizedBox(height: 2 * scale),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('sales_chat_try_incomplete'),
              onPressed: onTryIncomplete,
              style: TextButton.styleFrom(
                foregroundColor: SojuColors.demoInk,
                padding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 3 * scale,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Coba contoh draft belum lengkap',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 9.5 * scale,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.scale, required this.onUseSample});

  final double scale;
  final VoidCallback onUseSample;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: SojuColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tempel rekap penjualan harian atau shift.',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: SojuColors.notificationTitle,
            ),
          ),
          SizedBox(height: 5 * scale),
          Text(
            'Saya akan menyusun draft untuk diperiksa. Di mode demo, draft '
            'tidak disimpan dan tidak masuk pembukuan.',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 10 * scale,
              height: 1.45,
              color: SojuColors.analyticsMuted,
            ),
          ),
          SizedBox(height: 8 * scale),
          OutlinedButton(
            key: const Key('sales_chat_use_sample'),
            onPressed: onUseSample,
            style: OutlinedButton.styleFrom(
              foregroundColor: SojuColors.primary,
              side: const BorderSide(color: SojuColors.primary),
              minimumSize: Size(0, 34 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9 * scale),
              ),
            ),
            child: Text(
              'Gunakan contoh rekap',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 10 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('sales_chat_loading'),
      children: <Widget>[
        SizedBox(
          width: 13 * scale,
          height: 13 * scale,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: SojuColors.primary,
          ),
        ),
        SizedBox(width: 7 * scale),
        Text(
          'Soju sedang menyusun draft contoh...',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 9.5 * scale,
            color: SojuColors.analyticsMuted,
          ),
        ),
      ],
    );
  }
}
