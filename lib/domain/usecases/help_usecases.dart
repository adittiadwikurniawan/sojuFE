// lib/domain/usecases/help_usecases.dart
//
// Usecase Pusat Bantuan.

import '../../core/common/result.dart';
import '../entities/help_entity.dart';
import '../repositories/help_repository.dart';

/// Mengambil daftar topik bantuan.
class GetHelpTopics {
  const GetHelpTopics(this._repository);

  final HelpRepository _repository;

  Future<Result<List<HelpTopicEntity>>> call() => _repository.getTopics();
}

/// Mengambil detail artikel bantuan.
class GetHelpArticle {
  const GetHelpArticle(this._repository);

  final HelpRepository _repository;

  Future<Result<HelpArticleEntity>> call(String id) {
    return _repository.getArticle(id);
  }
}
