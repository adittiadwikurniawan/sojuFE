// lib/data/datasources/remote/free_table_remote_datasource.dart
//
// Remote datasource pembuatan Kategori Baru / Tabel Bebas:
// - `FreeTableCashflowType.freeTable` -> `POST /api/v1/free-tables`
// - `income` / `expense` -> `POST /api/v1/transaction-types`

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../../../domain/entities/free_table_entity.dart';
import '../interfaces/free_table_datasource.dart';

class FreeTableRemoteDataSource implements FreeTableDataSource {
  const FreeTableRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  static String _mapColumnType(FreeTableFieldType type) {
    return switch (type) {
      FreeTableFieldType.shortText => 'TEKS',
      FreeTableFieldType.number => 'ANGKA',
      FreeTableFieldType.date => 'TANGGAL',
      FreeTableFieldType.multipleChoice => 'DROPDOWN',
    };
  }

  static String _generateTypeCode(FreeTableCategoryDraft draft) {
    final String prefix =
        draft.cashflowType == FreeTableCashflowType.income ? 'PM' : 'PG';
    final int suffix = DateTime.now().millisecondsSinceEpoch % 1000;
    return '$prefix${suffix.toString().padLeft(3, '0')}';
  }

  @override
  Future<Map<String, Object?>> createRawCategory({
    required FreeTableCategoryDraft draft,
  }) async {
    final ApiResponse response;
    try {
      if (draft.cashflowType == FreeTableCashflowType.freeTable) {
        response = await _apiClient.post(
          '/api/v1/free-tables',
          body: <String, Object?>{
            'namaTabel': draft.name,
            if (draft.department != null && draft.department!.trim().isNotEmpty)
              'deskripsi': draft.department!.trim(),
            'kolom': <Map<String, Object?>>[
              for (int i = 0; i < draft.fields.length; i++)
                <String, Object?>{
                  'namaKolom': draft.fields[i].label,
                  'tipeData': _mapColumnType(draft.fields[i].type),
                  if (draft.fields[i].options.isNotEmpty)
                    'opsiDropdown': draft.fields[i].options,
                  'urutan': i,
                },
            ],
          },
        );
      } else {
        response = await _apiClient.post(
          '/api/v1/transaction-types',
          body: <String, Object?>{
            'kode': _generateTypeCode(draft),
            'namaTransaksi': draft.name,
            'arah': draft.cashflowType == FreeTableCashflowType.income
                ? 'PEMASUKAN'
                : 'PENGELUARAN',
            if (draft.department != null && draft.department!.trim().isNotEmpty)
              'unitBisnis': draft.department!.trim(),
          },
        );
      }
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }

    final Object? raw = response.body;
    final Map<String, Object?>? body = raw is Map
        ? <String, Object?>{
            for (final MapEntry<Object?, Object?> e in raw.entries)
              e.key.toString(): e.value,
          }
        : null;

    final Object? message = body?['message'];
    final String? text =
        message is String && message.trim().isNotEmpty ? message.trim() : null;

    if (response.statusCode == 401) {
      throw UnauthorizedFailure(message: text);
    }
    if (!response.isSuccess) {
      throw ServerFailure(statusCode: response.statusCode, message: text);
    }

    final Object? dataObj = body?['data'];
    final String? createdId =
        dataObj is Map ? dataObj['id']?.toString() : null;

    return <String, Object?>{
      'success': true,
      if (text != null) 'message': text,
      'data': <String, Object?>{
        if (createdId != null) 'id': createdId,
        ...draft.toJson(),
      },
    };
  }
}
