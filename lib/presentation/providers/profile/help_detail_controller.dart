// lib/presentation/providers/profile/help_detail_controller.dart
//
// State + controller detail artikel bantuan.

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/help_entity.dart';
import '../../../domain/usecases/help_usecases.dart';

/// Status pemuatan detail artikel.
enum HelpDetailStatus { loading, ready, error }

/// State layar Detail Topik.
@immutable
class HelpDetailState {
  const HelpDetailState({
    this.article,
    this.status = HelpDetailStatus.loading,
    this.errorMessage,
    this.feedbackSubmitted = false,
    this.feedbackHelpful,
  });

  final HelpArticleEntity? article;
  final HelpDetailStatus status;
  final String? errorMessage;
  final bool feedbackSubmitted;
  final bool? feedbackHelpful;

  bool get isLoading => status == HelpDetailStatus.loading;
  bool get hasError => status == HelpDetailStatus.error;

  HelpDetailState copyWith({
    HelpArticleEntity? article,
    HelpDetailStatus? status,
    String? errorMessage,
    bool clearError = false,
    bool? feedbackSubmitted,
    bool? feedbackHelpful,
  }) {
    return HelpDetailState(
      article: article ?? this.article,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      feedbackSubmitted: feedbackSubmitted ?? this.feedbackSubmitted,
      feedbackHelpful: feedbackHelpful ?? this.feedbackHelpful,
    );
  }
}

/// Controller detail artikel bantuan.
class HelpDetailController extends ChangeNotifier {
  HelpDetailController({
    required GetHelpArticle getArticle,
    required this.articleId,
  }) : _getArticle = getArticle;

  final GetHelpArticle _getArticle;
  final String articleId;

  HelpDetailState _state = const HelpDetailState();
  bool _disposed = false;

  HelpDetailState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(
      status: HelpDetailStatus.loading,
      clearError: true,
    );
    _notify();

    final Result<HelpArticleEntity> result = await _getArticle(articleId);
    if (_disposed) {
      return;
    }
    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: HelpDetailStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (HelpArticleEntity article) {
        _state = _state.copyWith(
          article: article,
          status: HelpDetailStatus.ready,
          clearError: true,
        );
      },
    );
    _notify();
  }

  void submitFeedback({required bool helpful}) {
    if (_state.feedbackSubmitted) {
      return;
    }
    _state = _state.copyWith(
      feedbackSubmitted: true,
      feedbackHelpful: helpful,
    );
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
