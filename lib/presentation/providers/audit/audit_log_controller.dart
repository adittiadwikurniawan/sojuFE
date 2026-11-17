// lib/presentation/providers/audit/audit_log_controller.dart
//
// State + controller log audit (MFR-8: loading/data/empty/error + retry).
//
// Memakai [ChangeNotifier] karena dependency Riverpod belum ditambahkan pada
// repo ini; pola state terpisah tetap mengikuti `ARCHITECTURE.md` §2.9.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/audit_log_entity.dart';
import '../../../domain/usecases/audit_usecases.dart';

/// Opsi rentang waktu filter audit (default 7 hari, MFR-7).
enum AuditRangeOption { days7, days30, days90, all }

/// Ekstensi label + parameter API untuk tiap opsi rentang.
extension AuditRangeOptionX on AuditRangeOption {
  /// Label chip Bahasa Indonesia.
  String get label {
    switch (this) {
      case AuditRangeOption.days7:
        return '7 Hari';
      case AuditRangeOption.days30:
        return '30 Hari';
      case AuditRangeOption.days90:
        return '90 Hari';
      case AuditRangeOption.all:
        return 'Semua Waktu';
    }
  }

  /// Nilai `days` yang dikirim ke repository (`null` = seluruh waktu).
  int? get days {
    switch (this) {
      case AuditRangeOption.days7:
        return 7;
      case AuditRangeOption.days30:
        return 30;
      case AuditRangeOption.days90:
        return 90;
      case AuditRangeOption.all:
        return null;
    }
  }
}

/// Status tampilan log audit.
enum AuditLogStatus { loading, data, empty, error }

/// State log audit.
class AuditLogState {
  const AuditLogState({
    required this.status,
    this.range = AuditRangeOption.days7,
    this.startDate,
    this.endDate,
    this.logs = const <AuditLogEntryEntity>[],
    this.totalCount,
    this.page = 1,
    this.hasNext = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.errorMessage,
  });

  /// Keadaan awal: memuat sesuai rentang default 7 hari.
  const AuditLogState.initial()
      : this(status: AuditLogStatus.loading, range: AuditRangeOption.days7);

  final AuditLogStatus status;
  final AuditRangeOption range;

  /// Awal rentang kustom dari kartu tanggal (inklusif).
  final DateTime? startDate;

  /// Akhir rentang kustom dari kartu tanggal (inklusif).
  final DateTime? endDate;

  final List<AuditLogEntryEntity> logs;

  /// Total log pada filter aktif (bila API mengirim pagination).
  final int? totalCount;

  /// Halaman terakhir yang sudah dimuat.
  final int page;

  /// `true` bila masih ada halaman berikutnya.
  final bool hasNext;

  /// Sedang memuat halaman berikutnya.
  final bool isLoadingMore;

  /// Gagal memuat halaman berikutnya (data utama tetap tampil).
  final bool loadMoreFailed;

  /// Pesan galat untuk state error / gagat muat-selengkapnya.
  final String? errorMessage;

  /// `true` bila filter memakai rentang kustom dari kartu tanggal.
  bool get hasCustomRange => startDate != null && endDate != null;

  AuditLogState copyWith({
    AuditLogStatus? status,
    AuditRangeOption? range,
    DateTime? startDate,
    DateTime? endDate,
    bool clearCustomRange = false,
    List<AuditLogEntryEntity>? logs,
    int? totalCount,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    String? errorMessage,
  }) {
    return AuditLogState(
      status: status ?? this.status,
      range: range ?? this.range,
      startDate: clearCustomRange ? null : (startDate ?? this.startDate),
      endDate: clearCustomRange ? null : (endDate ?? this.endDate),
      logs: logs ?? this.logs,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller daftar log audit.
class AuditLogController extends ChangeNotifier {
  AuditLogController({required GetAuditLogs getAuditLogs})
      : _getAuditLogs = getAuditLogs;

  final GetAuditLogs _getAuditLogs;

  AuditLogState _state = const AuditLogState.initial();

  /// State saat ini.
  AuditLogState get state => _state;

  /// Penanda permintaan untuk mengabaikan respons yang sudah basi saat
  /// pengguna mengganti filter lebih cepat daripada respons sebelumnya.
  int _requestId = 0;

  /// Memuat halaman pertama sesuai rentang aktif.
  Future<void> load() async {
    final int token = ++_requestId;
    _state = _state.copyWith(
      status: AuditLogStatus.loading,
      errorMessage: null,
    );
    notifyListeners();
    await _fetch(reset: true, token: token);
  }

  /// Mengganti rentang preset lalu memuat ulang dari halaman 1.
  ///
  /// Memilih preset selalu menghapus rentang kustom yang sedang aktif.
  Future<void> setRange(AuditRangeOption option) async {
    final bool alreadyActive = _state.range == option && !_state.hasCustomRange;
    if (alreadyActive && _state.status != AuditLogStatus.error) {
      return;
    }
    _state = _state.copyWith(range: option, clearCustomRange: true);
    notifyListeners();
    await load();
  }

  /// Memakai rentang kustom dari kartu tanggal lalu memuat ulang halaman 1.
  Future<void> setCustomRange(DateTimeRange range) async {
    final DateTime start =
        DateTime(range.start.year, range.start.month, range.start.day);
    final DateTime end =
        DateTime(range.end.year, range.end.month, range.end.day);
    _state = _state.copyWith(startDate: start, endDate: end);
    notifyListeners();
    await load();
  }

  /// Menghapus rentang kustom dan kembali ke preset aktif.
  Future<void> clearCustomRange() async {
    if (!_state.hasCustomRange) {
      return;
    }
    _state = _state.copyWith(clearCustomRange: true);
    notifyListeners();
    await load();
  }

  /// Memuat halaman berikutnya (muat selengkapnya).
  Future<void> loadMore() async {
    final AuditLogState current = _state;
    if (current.isLoadingMore ||
        !current.hasNext ||
        current.status != AuditLogStatus.data) {
      return;
    }
    _state = current.copyWith(isLoadingMore: true, loadMoreFailed: false);
    notifyListeners();
    final int token = ++_requestId;
    await _fetch(reset: false, token: token);
  }

  Future<void> _fetch({
    required bool reset,
    required int token,
  }) async {
    final AuditLogState current = _state;
    final int page = reset ? 1 : current.page + 1;
    final Result<AuditLogPageEntity> result = await _getAuditLogs(
      query: AuditLogQuery(
        days: current.hasCustomRange ? null : current.range.days,
        startDate: current.startDate,
        endDate: current.endDate,
        page: page,
      ),
    );

    // Respons basi: pengguna sudah melakukan aksi lain.
    if (token != _requestId) {
      return;
    }

    result.fold(
      onFailure: (AppFailure failure) {
        final String message = failure.message;
        if (reset) {
          _state = AuditLogState(
            status: AuditLogStatus.error,
            range: current.range,
            startDate: current.startDate,
            endDate: current.endDate,
            errorMessage: message,
          );
        } else {
          _state = current.copyWith(
            isLoadingMore: false,
            loadMoreFailed: true,
            errorMessage: message,
          );
        }
      },
      onSuccess: (AuditLogPageEntity pageData) {
        final List<AuditLogEntryEntity> logs = reset
            ? pageData.logs
            : <AuditLogEntryEntity>[...current.logs, ...pageData.logs];
        final bool empty = logs.isEmpty;
        _state = AuditLogState(
          status: empty ? AuditLogStatus.empty : AuditLogStatus.data,
          range: current.range,
          startDate: current.startDate,
          endDate: current.endDate,
          logs: logs,
          totalCount: pageData.total ?? (empty ? 0 : logs.length),
          page: pageData.page,
          hasNext: pageData.hasNext,
        );
      },
    );
    notifyListeners();
  }
}
