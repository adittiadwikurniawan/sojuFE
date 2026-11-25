// lib/data/datasources/remote/google_id_token_provider.dart
//
// Implementasi Google Sign-In. `serverClientId` adalah OAuth Web Client ID
// yang juga dipakai backend sebagai audience verifikasi ID token.
//
// iOS membutuhkan OAuth iOS Client ID sebagai `clientId`; Android memakai
// client ID yang terdaftar untuk package + SHA-1 di Google Cloud Console.
// Web memakai OAuth Web Client ID sebagai `clientId`.

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/services/google_auth/google_id_token_provider.dart';

/// Mengambil ID token dari dialog Google Sign-In.
class GoogleIdTokenProviderImpl implements GoogleIdTokenProvider {
  GoogleIdTokenProviderImpl({
    String? serverClientId,
    String? iosClientId,
  })  : _serverClientId = serverClientId,
        _iosClientId = iosClientId;

  final String? _serverClientId;
  final String? _iosClientId;

  @override
  Future<String?> getIdToken() async {
    final bool isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    // Web memakai OAuth Web Client ID sebagai `clientId`. Android memakai
    // client ID yang terdaftar untuk package + SHA-1 dan `serverClientId`
    // untuk meminta ID token. iOS memakai OAuth iOS Client ID.
    final GoogleSignIn signIn = GoogleSignIn(
      scopes: const <String>['email', 'profile'],
      clientId: kIsWeb ? _serverClientId : (isIOS ? _iosClientId : null),
      serverClientId: kIsWeb ? null : _serverClientId,
    );

    final GoogleSignInAccount? account = await signIn.signIn();
    if (account == null) {
      return null;
    }

    final GoogleSignInAuthentication authentication =
        await account.authentication;
    return authentication.idToken;
  }
}
