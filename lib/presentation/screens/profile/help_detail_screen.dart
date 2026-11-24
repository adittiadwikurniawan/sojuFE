// lib/presentation/screens/profile/help_detail_screen.dart
//
// Layar Detail Topik (frame Figma `546:5686`).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/help_entity.dart';
import '../../providers/profile/help_detail_controller.dart';
import '../../widgets/profile/profile_buttons.dart';
import '../../widgets/profile/profile_message_banner.dart';
import '../../widgets/profile/profile_top_bar.dart';

/// Layar detail artikel bantuan.
class HelpDetailScreen extends StatefulWidget {
  const HelpDetailScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
  });

  final HelpDetailController Function() controllerFactory;
  final VoidCallback? onBack;

  @override
  State<HelpDetailScreen> createState() => _HelpDetailScreenState();
}

class _HelpDetailScreenState extends State<HelpDetailScreen> {
  late final HelpDetailController _controller;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('help_detail_screen'),
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
    required HelpDetailState state,
  }) {
    final HelpArticleEntity? article = state.article;

    return Column(
      children: <Widget>[
        ProfileTopBar(
          scale: scale,
          topInset: topInset,
          title: 'Topik Detail',
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
            child: state.isLoading
                ? Padding(
                    padding: EdgeInsets.only(top: 48 * scale),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : state.hasError
                    ? Column(
                        children: <Widget>[
                          ProfileMessageBanner(
                            scale: scale,
                            message: state.errorMessage ??
                                'Artikel bantuan gagal dimuat.',
                          ),
                          SizedBox(height: 16 * scale),
                          ProfilePrimaryButton(
                            scale: scale,
                            label: 'Coba Lagi',
                            onPressed: _controller.load,
                          ),
                        ],
                      )
                    : article == null
                        ? ProfileMessageBanner(
                            scale: scale,
                            message: 'Artikel bantuan tidak ditemukan.',
                          )
                        : _articleBody(scale, article, state),
          ),
        ),
      ],
    );
  }

  Widget _articleBody(
    double scale,
    HelpArticleEntity article,
    HelpDetailState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          article.title,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 19.5 * scale,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: SojuColors.profileHelpTitle,
          ),
        ),
        SizedBox(height: 18 * scale),
        for (final String paragraph in article.paragraphs) ...<Widget>[
          Text(
            paragraph,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 15 * scale,
              height: 1.55,
              color: SojuColors.profileHelpBody,
            ),
          ),
          SizedBox(height: 16 * scale),
        ],
        SizedBox(height: 18 * scale),
        Text(
          'Apakah artikel ini membantu menjawab pertanyaan Anda?',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 15 * scale,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: SojuColors.profileHelpTitle,
          ),
        ),
        SizedBox(height: 14 * scale),
        if (state.feedbackSubmitted)
          Container(
            key: const Key('help_feedback_thanks'),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 14 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20 * scale,
                  color: const Color(0xFF047857),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Text(
                    'Terima kasih atas masukan Anda.',
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 13 * scale,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: <Widget>[
              Expanded(
                child: ProfilePrimaryButton(
                  key: const Key('help_feedback_yes'),
                  scale: scale,
                  label: 'Ya',
                  onPressed: () => _controller.submitFeedback(helpful: true),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: ProfilePrimaryButton(
                  key: const Key('help_feedback_no'),
                  scale: scale,
                  label: 'Tidak',
                  onPressed: () => _controller.submitFeedback(helpful: false),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
