// lib/domain/repositories/help_repository.dart
//
// Kontrak repository Pusat Bantuan.

import '../../core/common/result.dart';
import '../entities/help_entity.dart';

/// Repository topik dan artikel bantuan.
abstract interface class HelpRepository {
  /// Mengambil seluruh topik bantuan.
  Future<Result<List<HelpTopicEntity>>> getTopics();

  /// Mengambil detail artikel berdasarkan [id].
  Future<Result<HelpArticleEntity>> getArticle(String id);
}
