// lib/presentation/providers/sales_chat/sales_chat_controller.dart
//
// State + controller prototype chat input penjualan harian/shift.
//
// Semua balasan berasal dari usecase mock. Controller tidak memanggil HTTP,
// tidak menyimpan transaksi, dan tidak mengklaim draft sudah masuk pembukuan.
// Koreksi draft dan konfirmasi simulasi hanya mengubah state sesi prototype.

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../domain/entities/sales_chat_entity.dart';
import '../../../domain/usecases/sales_chat_usecases.dart';

/// Penulis pesan pada percakapan prototype.
enum SalesChatAuthor { user, assistant }

/// Satu pesan pada percakapan prototype.
@immutable
class SalesChatMessage {
  const SalesChatMessage({
    required this.author,
    required this.text,
    required this.timeLabel,
    this.draft,
    this.isSimulationResult = false,
  });

  final SalesChatAuthor author;
  final String text;
  final String timeLabel;

  /// Draft yang menempel pada pesan asisten, bila ada.
  final SalesChatDraft? draft;

  /// Pesan hasil simulasi konfirmasi (bukan status tersimpan).
  final bool isSimulationResult;

  SalesChatMessage copyWith({SalesChatDraft? draft}) {
    return SalesChatMessage(
      author: author,
      text: text,
      timeLabel: timeLabel,
      draft: draft ?? this.draft,
      isSimulationResult: isSimulationResult,
    );
  }
}

/// Status pengiriman/pemrosesan pesan.
enum SalesChatStatus { idle, parsing, error }

/// State percakapan prototype.
@immutable
class SalesChatState {
  const SalesChatState({
    this.messages = const <SalesChatMessage>[],
    this.draft,
    this.status = SalesChatStatus.idle,
    this.errorMessage,
    this.simulationMessage,
    this.isSimulationComplete = false,
  });

  final List<SalesChatMessage> messages;
  final SalesChatDraft? draft;
  final SalesChatStatus status;
  final String? errorMessage;

  /// Pesan hasil simulasi; tidak pernah berarti transaksi tersimpan.
  final String? simulationMessage;
  final bool isSimulationComplete;

  SalesChatState copyWith({
    List<SalesChatMessage>? messages,
    SalesChatDraft? draft,
    SalesChatStatus? status,
    String? errorMessage,
    String? simulationMessage,
    bool? isSimulationComplete,
    bool clearError = false,
    bool clearSimulation = false,
  }) {
    return SalesChatState(
      messages: messages ?? this.messages,
      draft: draft ?? this.draft,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      simulationMessage: clearSimulation
          ? null
          : (simulationMessage ?? this.simulationMessage),
      isSimulationComplete: clearSimulation
          ? false
          : (isSimulationComplete ?? this.isSimulationComplete),
    );
  }
}

/// Controller percakapan prototype.
class SalesChatController extends ChangeNotifier {
  SalesChatController({
    required ParseSalesChatRecap parseRecap,
    SalesChatDraft? initialDraft,
    String initialUserText = sampleRecapInput,
    DateTime Function()? now,
  })  : _parseRecap = parseRecap,
        _now = now ?? DateTime.now {
    if (initialDraft != null) {
      final String time = _timeLabel();
      _state = SalesChatState(
        messages: <SalesChatMessage>[
          SalesChatMessage(
            author: SalesChatAuthor.user,
            text: initialUserText,
            timeLabel: time,
          ),
          SalesChatMessage(
            author: SalesChatAuthor.assistant,
            text: _initialAssistantText,
            timeLabel: time,
            draft: initialDraft,
          ),
        ],
        draft: initialDraft,
      );
    }
  }

  /// Contoh input lengkap untuk demo.
  static const String sampleRecapInput =
      'Input hasil penjualan shift siang: Bento Ayam Bakar 30 porsi total '
      '1.050.000, Sosis Keju 15 porsi 225.000, Es Teh Manis 20 gelas '
      '100.000. Pembayaran via QRIS dan Cash.';

  /// Contoh input yang sengaja belum lengkap untuk demo validasi.
  static const String incompleteRecapInput =
      'Input hasil penjualan shift siang tanpa pembayaran: Bento Ayam Bakar '
      '30 porsi total 1.050.000, Sosis Keju 15 porsi 225.000, Es Teh Manis '
      '20 gelas 100.000.';

  static const String _initialAssistantText =
      'Siap! Ini draft contoh dari rekap shift siang. Periksa dulu — draft '
      'belum disimpan ke pembukuan.';

  static const String _cannotParseText =
      'Mode demo: rekap ini belum bisa dibaca. Coba gunakan contoh rekap '
      'penjualan yang ada di layar ini. Tidak ada data yang dikirim ke AI.';

  static const String _simulationText =
      'Simulasi selesai — tidak masuk ke pembukuan.';

  final ParseSalesChatRecap _parseRecap;
  final DateTime Function() _now;

  SalesChatState _state = const SalesChatState();
  bool _disposed = false;

  SalesChatState get state => _state;

  /// Mengirim pesan dan menjalankan simulasi parser lokal.
  Future<void> sendMessage(String text) async {
    final String input = text.trim();
    if (input.isEmpty || _state.status == SalesChatStatus.parsing) {
      return;
    }

    _state = _state.copyWith(
      messages: <SalesChatMessage>[
        ..._state.messages,
        SalesChatMessage(
          author: SalesChatAuthor.user,
          text: input,
          timeLabel: _timeLabel(),
        ),
      ],
      status: SalesChatStatus.parsing,
      clearError: true,
      clearSimulation: true,
    );
    notifyListeners();

    final Result<SalesChatDraft?> result = await _parseRecap(input);
    if (_disposed) {
      return;
    }

    result.fold(
      onFailure: (failure) {
        _appendAssistantMessage(
          'Mode demo: ${failure.message} Tidak ada data yang disimpan.',
          status: SalesChatStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (draft) {
        if (draft == null) {
          _appendAssistantMessage(
            _cannotParseText,
            status: SalesChatStatus.idle,
          );
          return;
        }
        _state = _state.copyWith(
          messages: <SalesChatMessage>[
            ..._state.messages,
            SalesChatMessage(
              author: SalesChatAuthor.assistant,
              text: 'Ini draft contoh dari data demo. Periksa dan lengkapi '
                  'sebelum konfirmasi simulasi.',
              timeLabel: _timeLabel(),
              draft: draft,
            ),
          ],
          draft: draft,
          status: SalesChatStatus.idle,
          clearError: true,
          clearSimulation: true,
        );
        notifyListeners();
      },
    );
  }

  /// Mengganti draft dengan hasil koreksi lokal.
  void applyCorrection(SalesChatDraft draft) {
    final int index = _state.messages.lastIndexWhere(
      (SalesChatMessage message) => message.draft != null,
    );
    final List<SalesChatMessage> messages = <SalesChatMessage>[
      for (int i = 0; i < _state.messages.length; i++)
        i == index
            ? _state.messages[i].copyWith(draft: draft)
            : _state.messages[i],
    ];
    _state = _state.copyWith(
      messages: messages,
      draft: draft,
      clearError: true,
      clearSimulation: true,
    );
    notifyListeners();
  }

  /// Menjalankan konfirmasi simulasi; tidak menulis transaksi.
  bool confirmSimulation() {
    final SalesChatDraft? draft = _state.draft;
    if (draft == null) {
      return false;
    }
    if (!draft.canConfirm) {
      _state = _state.copyWith(
        errorMessage:
            'Lengkapi field yang belum diisi dan perbaiki selisih total '
            'sebelum konfirmasi simulasi.',
      );
      notifyListeners();
      return false;
    }
    if (_state.isSimulationComplete) {
      return true;
    }

    _state = _state.copyWith(
      messages: <SalesChatMessage>[
        ..._state.messages,
        SalesChatMessage(
          author: SalesChatAuthor.assistant,
          text: _simulationText,
          timeLabel: _timeLabel(),
          isSimulationResult: true,
        ),
      ],
      isSimulationComplete: true,
      simulationMessage: _simulationText,
      clearError: true,
    );
    notifyListeners();
    return true;
  }

  void _appendAssistantMessage(
    String text, {
    required SalesChatStatus status,
    String? errorMessage,
  }) {
    _state = _state.copyWith(
      messages: <SalesChatMessage>[
        ..._state.messages,
        SalesChatMessage(
          author: SalesChatAuthor.assistant,
          text: text,
          timeLabel: _timeLabel(),
        ),
      ],
      status: status,
      errorMessage: errorMessage,
    );
    notifyListeners();
  }

  String _timeLabel() {
    final DateTime now = _now();
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
