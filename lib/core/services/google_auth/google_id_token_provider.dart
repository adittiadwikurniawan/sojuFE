// lib/core/services/google_auth/google_id_token_provider.dart
//
// Kontrak pengambilan ID token Google. Implementasi plugin berada di data
// layer agar presentation/domain tidak bergantung pada package Google.

/// Penyedia ID token Google untuk ditukar dengan JWT backend.
abstract interface class GoogleIdTokenProvider {
  /// ID token Google, atau `null` bila pengguna membatalkan dialog.
  Future<String?> getIdToken();
}
