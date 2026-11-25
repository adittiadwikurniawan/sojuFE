// lib/presentation/screens/profile/help_topics_screen.dart
//
// Layar Topik Pusat Bantuan (frame Figma `546:5647`).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/help_entity.dart';
import '../../providers/profile/help_topics_controller.dart';
import '../../widgets/profile/profile_buttons.dart';
import '../../widgets/profile/profile_message_banner.dart';
import '../../widgets/profile/profile_top_bar.dart';

/// Layar daftar topik bantuan.
class HelpTopicsScreen extends StatefulWidget {
  const HelpTopicsScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
    this.onArticleTap,
  });

  final HelpTopicsController Function() controllerFactory;
  final VoidCallback? onBack;
  final ValueChanged<String>? onArticleTap;

  @override
  State<HelpTopicsScreen> createState() => _HelpTopicsScreenState();
}

class _HelpTopicsScreenState extends State<HelpTopicsScreen> {
  late final HelpTopicsController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openTopic(HelpTopicEntity topic) {
    widget.onArticleTap?.call(topic.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('help_topics_screen'),
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
    required HelpTopicsState state,
  }) {
    return Column(
      children: <Widget>[
        ProfileSearchTopBar(
          scale: scale,
          topInset: topInset,
          controller: _searchController,
          searchFieldKey: const Key('help_search_field'),
          onChanged: _controller.setQuery,
          onBack: widget.onBack,
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(60 * scale),
            ),
            child: ColoredBox(
              color: SojuColors.surface,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  23 * scale,
                  12 * scale,
                  23 * scale,
                  32 * scale + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 55 * scale,
                        height: 7 * scale,
                        decoration: BoxDecoration(
                          color: SojuColors.profileSwitchInactive,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * scale),
                    Row(
                      children: <Widget>[
                        Text(
                          'Topik',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.primary,
                          ),
                        ),
                        const Spacer(),
                        if (_controller.canShowAll)
                          TextButton(
                            key: const Key('help_see_all'),
                            onPressed: _controller.toggleShowAll,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              state.showAll ? 'Ringkas' : 'Lihat Semua',
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: SojuColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    if (state.isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: 48 * scale),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (state.hasError && state.topics.isEmpty)
                      Column(
                        children: <Widget>[
                          ProfileMessageBanner(
                            scale: scale,
                            message: state.errorMessage ??
                                'Topik bantuan gagal dimuat.',
                          ),
                          SizedBox(height: 16 * scale),
                          ProfilePrimaryButton(
                            scale: scale,
                            label: 'Coba Lagi',
                            onPressed: _controller.load,
                          ),
                        ],
                      )
                    else if (!_controller.hasResults)
                      _EmptyTopics(scale: scale)
                    else ...<Widget>[
                      if (state.errorMessage != null) ...<Widget>[
                        ProfileMessageBanner(
                          scale: scale,
                          message: state.errorMessage!,
                        ),
                        SizedBox(height: 16 * scale),
                      ],
                      for (final HelpTopicEntity topic
                          in _controller.featuredTopics) ...<Widget>[
                        _FeaturedTopicCard(
                          key: Key('help_featured_topic_${topic.id}'),
                          scale: scale,
                          topic: topic,
                          onTap: () => _openTopic(topic),
                        ),
                        SizedBox(height: 16 * scale),
                      ],
                      for (final HelpTopicEntity topic
                          in _controller.visibleArticleTopics) ...<Widget>[
                        _ArticleTopicCard(
                          key: Key('help_article_${topic.id}'),
                          scale: scale,
                          topic: topic,
                          onTap: () => _openTopic(topic),
                        ),
                        SizedBox(height: 14 * scale),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedTopicCard extends StatelessWidget {
  const _FeaturedTopicCard({
    super.key,
    required this.scale,
    required this.topic,
    required this.onTap,
  });

  final double scale;
  final HelpTopicEntity topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.profileHelpCard,
      borderRadius: BorderRadius.circular(23 * scale),
      child: InkWell(
        borderRadius: BorderRadius.circular(23 * scale),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(24 * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      topic.title,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 15.5 * scale,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: SojuColors.profileHelpTitle,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      topic.description,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 11.5 * scale,
                        height: 1.5,
                        color: SojuColors.profileHelpBody,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Lihat Topik',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 11.5 * scale,
                            fontWeight: FontWeight.w600,
                            color: SojuColors.primary,
                          ),
                        ),
                        SizedBox(width: 4 * scale),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14 * scale,
                          color: SojuColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16 * scale),
              Container(
                width: 84 * scale,
                height: 84 * scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFFEAF3FF), Color(0xFF8BB8FF)],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _iconFor(topic),
                  size: 38 * scale,
                  color: SojuColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(HelpTopicEntity topic) {
    if (topic.id.contains('jenis')) {
      return Icons.category_outlined;
    }
    if (topic.id.contains('order')) {
      return Icons.shopping_bag_outlined;
    }
    return Icons.receipt_long_outlined;
  }
}

class _ArticleTopicCard extends StatelessWidget {
  const _ArticleTopicCard({
    super.key,
    required this.scale,
    required this.topic,
    required this.onTap,
  });

  final double scale;
  final HelpTopicEntity topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.profileHelpCard,
      borderRadius: BorderRadius.circular(28 * scale),
      child: InkWell(
        borderRadius: BorderRadius.circular(28 * scale),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(24 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                topic.title,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 14.5 * scale,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: SojuColors.profileHelpTitle,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                topic.description,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 11.5 * scale,
                  height: 1.5,
                  color: SojuColors.profileHelpBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTopics extends StatelessWidget {
  const _EmptyTopics({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('help_empty'),
      padding: EdgeInsets.only(top: 48 * scale),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.search_off_rounded,
            size: 48 * scale,
            color: SojuColors.profileMuted,
          ),
          SizedBox(height: 12 * scale),
          Text(
            'Topik tidak ditemukan.',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.ink,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Coba kata kunci lain.',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12 * scale,
              color: SojuColors.profileHelpBody,
            ),
          ),
        ],
      ),
    );
  }
}
