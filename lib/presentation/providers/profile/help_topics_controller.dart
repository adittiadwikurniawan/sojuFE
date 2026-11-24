// lib/presentation/providers/profile/help_topics_controller.dart
//
// State + filter daftar topik Pusat Bantuan.

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/help_entity.dart';
import '../../../domain/usecases/help_usecases.dart';

/// Status pemuatan topik bantuan.
enum HelpTopicsStatus { loading, ready, error }

/// State layar Topik.
@immutable
class HelpTopicsState {
  const HelpTopicsState({
    this.topics = const <HelpTopicEntity>[],
    this.query = '',
    this.showAll = false,
    this.status = HelpTopicsStatus.loading,
    this.errorMessage,
  });

  final List<HelpTopicEntity> topics;
  final String query;
  final bool showAll;
  final HelpTopicsStatus status;
  final String? errorMessage;

  bool get isLoading => status == HelpTopicsStatus.loading;
  bool get hasError => status == HelpTopicsStatus.error;

  HelpTopicsState copyWith({
    List<HelpTopicEntity>? topics,
    String? query,
    bool? showAll,
    HelpTopicsStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HelpTopicsState(
      topics: topics ?? this.topics,
      query: query ?? this.query,
      showAll: showAll ?? this.showAll,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Controller layar Topik.
class HelpTopicsController extends ChangeNotifier {
  HelpTopicsController({required GetHelpTopics getTopics})
      : _getTopics = getTopics;

  final GetHelpTopics _getTopics;

  HelpTopicsState _state = const HelpTopicsState();
  bool _disposed = false;

  HelpTopicsState get state => _state;

  /// Topik yang cocok dengan pencarian.
  List<HelpTopicEntity> get filteredTopics {
    final String query = _state.query.trim().toLowerCase();
    if (query.isEmpty) {
      return _state.topics;
    }
    return _state.topics
        .where(
          (HelpTopicEntity topic) =>
              topic.title.toLowerCase().contains(query) ||
              topic.description.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  List<HelpTopicEntity> get featuredTopics {
    return filteredTopics
        .where((HelpTopicEntity topic) => topic.isFeatured)
        .take(2)
        .toList(growable: false);
  }

  List<HelpTopicEntity> get articleTopics {
    return filteredTopics
        .where((HelpTopicEntity topic) => !topic.isFeatured)
        .toList(growable: false);
  }

  List<HelpTopicEntity> get visibleArticleTopics {
    final List<HelpTopicEntity> articles = articleTopics;
    if (_state.showAll || _state.query.trim().isNotEmpty) {
      return articles;
    }
    return articles.take(2).toList(growable: false);
  }

  bool get canShowAll =>
      _state.query.trim().isEmpty && articleTopics.length > 2;

  bool get hasResults => filteredTopics.isNotEmpty;

  Future<void> load() async {
    _state = _state.copyWith(
      status: HelpTopicsStatus.loading,
      clearError: true,
    );
    _notify();

    final Result<List<HelpTopicEntity>> result = await _getTopics();
    if (_disposed) {
      return;
    }
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: HelpTopicsStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (List<HelpTopicEntity> topics) {
        _state = _state.copyWith(
          topics: topics,
          status: HelpTopicsStatus.ready,
          clearError: true,
        );
      },
    );
    _notify();
  }

  void setQuery(String value) {
    _state = _state.copyWith(
      query: value,
      showAll: false,
      clearError: true,
    );
    _notify();
  }

  void toggleShowAll() {
    _state = _state.copyWith(showAll: !_state.showAll);
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
