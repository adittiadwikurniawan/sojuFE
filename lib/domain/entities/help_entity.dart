// lib/domain/entities/help_entity.dart
//
// Entity Pusat Bantuan (frame Figma `546:5647` dan `546:5686`).
//
// Phase A memakai datasource mock. Kontrak repository sudah memisahkan daftar
// topik dan detail artikel agar dapat diganti endpoint bantuan pada Phase B.

import 'package:flutter/foundation.dart';

/// Satu topik bantuan.
@immutable
class HelpTopicEntity {
  const HelpTopicEntity({
    required this.id,
    required this.title,
    required this.description,
    this.articleCount = 1,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String description;
  final int articleCount;

  /// Topik unggulan tampil sebagai kartu besar pada layar Topik.
  final bool isFeatured;
}

/// Detail artikel bantuan.
@immutable
class HelpArticleEntity {
  const HelpArticleEntity({
    required this.id,
    required this.topicId,
    required this.title,
    required this.paragraphs,
  });

  final String id;
  final String topicId;
  final String title;

  /// Paragraf yang ditampilkan berurutan.
  final List<String> paragraphs;
}
