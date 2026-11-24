// lib/data/repositories/help_repository_impl.dart
//
// Implementasi repository Pusat Bantuan.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/help_entity.dart';
import '../../domain/repositories/help_repository.dart';
import '../datasources/interfaces/help_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/help/help_model.dart';

/// Repository bantuan di atas [HelpDataSource].
class HelpRepositoryImpl implements HelpRepository {
  const HelpRepositoryImpl(this._dataSource);

  final HelpDataSource _dataSource;

  @override
  Future<Result<List<HelpTopicEntity>>> getTopics() async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchTopicsRaw();
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Topik bantuan tidak dapat dimuat.',
          ),
        );
      }
      final Object? data = envelope.data;
      final Object? rawTopics = data is Map ? data['topics'] : data;
      if (rawTopics is! List) {
        return Result.failure(
          const ParsingFailure(message: 'Daftar topik bantuan tidak valid.'),
        );
      }
      final List<HelpTopicEntity> topics = <HelpTopicEntity>[
        for (int index = 0; index < rawTopics.length; index++)
          HelpTopicModel.fromJson(rawTopics[index], index: index).toEntity(),
      ];
      return Result.success(topics);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<HelpArticleEntity>> getArticle(String id) async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchArticleRaw(id);
      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Artikel bantuan tidak ditemukan.',
          ),
        );
      }
      final HelpArticleModel model = HelpArticleModel.fromJson(envelope.data);
      return Result.success(model.toEntity());
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } on FormatException catch (failure) {
      return Result.failure(ParsingFailure(message: failure.message));
    } on Object {
      return Result.failure(const NetworkFailure());
    }
  }
}
