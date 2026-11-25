// lib/data/models/help/help_model.dart
//
// DTO topik dan artikel Pusat Bantuan.
//
// Bentuk `data` pada envelope Phase A:
//
// ```json
// {
//   "topics": [
//     {
//       "id": "topik-1",
//       "judul": "Bagaimana cara mencatat transaksi?",
//       "deskripsi": "...",
//       "jumlah_artikel": 5,
//       "unggulan": true
//     }
//   ]
// }
// ```

import '../../../domain/entities/help_entity.dart';

/// DTO satu topik bantuan.
class HelpTopicModel {
  const HelpTopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.articleCount,
    required this.isFeatured,
  });

  final String id;
  final String title;
  final String description;
  final int articleCount;
  final bool isFeatured;

  factory HelpTopicModel.fromJson(Object? raw, {required int index}) {
    final Map<String, Object?> json = _asMap(raw, 'topics[$index]');
    final String? id = _asString(json['id']);
    final String? title = _asString(json['judul'] ?? json['title']);
    final String? description = _asString(
      json['deskripsi'] ?? json['description'],
    );
    if (id == null || id.isEmpty) {
      throw FormatException('Field `id` topik ke-$index tidak valid.');
    }
    if (title == null || title.isEmpty) {
      throw FormatException('Field `judul` topik ke-$index tidak valid.');
    }
    return HelpTopicModel(
      id: id,
      title: title,
      description: description ?? '',
      articleCount: _asInt(
        json['jumlah_artikel'] ?? json['article_count'],
        fallback: 1,
      ),
      isFeatured: _asBool(json['unggulan'] ?? json['is_featured']),
    );
  }

  HelpTopicEntity toEntity() {
    return HelpTopicEntity(
      id: id,
      title: title,
      description: description,
      articleCount: articleCount,
      isFeatured: isFeatured,
    );
  }
}

/// DTO detail artikel bantuan.
class HelpArticleModel {
  const HelpArticleModel({
    required this.id,
    required this.topicId,
    required this.title,
    required this.paragraphs,
  });

  final String id;
  final String topicId;
  final String title;
  final List<String> paragraphs;

  factory HelpArticleModel.fromJson(Object? raw) {
    final Map<String, Object?> json = _asMap(raw, 'data');
    final String? id = _asString(json['id']);
    final String? topicId = _asString(json['topik_id'] ?? json['topic_id']);
    final String? title = _asString(json['judul'] ?? json['title']);
    if (id == null || id.isEmpty) {
      throw const FormatException('Field `id` artikel tidak valid.');
    }
    if (title == null || title.isEmpty) {
      throw const FormatException('Field `judul` artikel tidak valid.');
    }
    final List<String> paragraphs = _asStringList(
      json['paragraf'] ?? json['paragraphs'] ?? json['body'],
    );
    if (paragraphs.isEmpty) {
      throw const FormatException('Artikel tidak memiliki isi.');
    }
    return HelpArticleModel(
      id: id,
      topicId: topicId ?? id,
      title: title,
      paragraphs: paragraphs,
    );
  }

  HelpArticleEntity toEntity() {
    return HelpArticleEntity(
      id: id,
      topicId: topicId,
      title: title,
      paragraphs: paragraphs,
    );
  }
}

Map<String, Object?> _asMap(Object? raw, String field) {
  if (raw is Map) {
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        entry.key.toString(): entry.value,
    };
  }
  throw FormatException('Field `$field` bukan objek JSON.');
}

String? _asString(Object? raw) {
  if (raw is String) {
    final String value = raw.trim();
    return value.isEmpty ? null : value;
  }
  return null;
}

int _asInt(Object? raw, {required int fallback}) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  if (raw is String) {
    return int.tryParse(raw) ?? fallback;
  }
  return fallback;
}

bool _asBool(Object? raw) {
  if (raw is bool) {
    return raw;
  }
  if (raw is num) {
    return raw != 0;
  }
  if (raw is String) {
    return raw.toLowerCase() == 'true' || raw == '1';
  }
  return false;
}

List<String> _asStringList(Object? raw) {
  if (raw is String) {
    final List<String> lines = raw
        .split(RegExp(r'\n\s*\n'))
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList(growable: false);
    return lines;
  }
  if (raw is! List) {
    return const <String>[];
  }
  return <String>[
    for (final Object? item in raw)
      if (item is String && item.trim().isNotEmpty) item.trim(),
  ];
}
