// lib/core/common/result.dart
//
// Tipe Result<T> (success/failure) lintas layer (lihat `ARCHITECTURE.md` §2.5).
//
// Repository selalu mengembalikan [Result] agar kegagalan transport, HTTP,
// envelope, parse, dan auth tersedia sebagai nilai — bukan sebagai exception
// yang wajib ditangkap presentation.

import '../errors/app_failure.dart';

/// Hasil operasi yang dapat gagal: [SuccessResult] atau [FailureResult].
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = SuccessResult<T>;

  factory Result.failure(AppFailure failure) = FailureResult<T>;

  bool get isSuccess => this is SuccessResult<T>;

  bool get isFailure => this is FailureResult<T>;

  /// Nilai sukses, atau `null` bila gagal.
  T? get valueOrNull {
    final Result<T> self = this;
    return self is SuccessResult<T> ? self.value : null;
  }

  /// Kegagalan, atau `null` bila sukses.
  AppFailure? get failureOrNull {
    final Result<T> self = this;
    return self is FailureResult<T> ? self.failure : null;
  }

  /// Memetakan hasil sesuai cabangnya.
  R fold<R>({
    required R Function(AppFailure failure) onFailure,
    required R Function(T value) onSuccess,
  }) {
    final Result<T> self = this;
    if (self is SuccessResult<T>) {
      return onSuccess(self.value);
    }
    return onFailure((self as FailureResult<T>).failure);
  }
}

/// Hasil sukses berisi [value].
class SuccessResult<T> extends Result<T> {
  const SuccessResult(this.value);

  final T value;
}

/// Hasil gagal berisi [failure].
class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final AppFailure failure;
}
