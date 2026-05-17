import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_auth_logger.dart';

/// Google OAuth via [GoogleSignIn.instance.authenticate], then Firebase session
/// with [GoogleAuthProvider.credential] (Google’s ID token endpoint).
///
/// [GoogleSignIn.instance.initialize] is called lazily on first sign-in so a
/// broken native channel (e.g. Pigeon `configure` after hot restart) does not
/// crash [main]. If init fails, run `flutter clean`, `cd ios && pod install`,
/// then a full rebuild — not hot restart alone.
class GoogleAuthRepository {
  bool? _initOk;

  Future<void> _ensureGoogleSignInReady() async {
    if (_initOk == true) return;
    if (_initOk == false) {
      throw const GoogleSignInUnavailableException();
    }
    try {
      await GoogleSignIn.instance.initialize();
      _initOk = true;
      logFirebaseAuth('GoogleSignIn.initialize', 'success');
    } on PlatformException catch (e, st) {
      _initOk = false;
      if (kDebugMode) {
        debugPrint('GoogleSignIn.initialize failed: $e\n$st');
      }
      throw GoogleSignInUnavailableException(e.message);
    } catch (e, st) {
      _initOk = false;
      if (kDebugMode) {
        debugPrint('GoogleSignIn.initialize failed: $e\n$st');
      }
      throw GoogleSignInUnavailableException(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    await _ensureGoogleSignInReady();
    try {
      logFirebaseAuth('GoogleSignIn.authenticate', 'start');
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      logFirebaseAuth(
        'GoogleSignIn.authenticate',
        'displayName=${account.displayName}, email=${account.email}',
      );
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        logFirebaseAuth('GoogleSignIn.authenticate', 'error=noIdToken');
        throw StateError('Google Sign-In did not return an ID token.');
      }
      logFirebaseAuth(
        'signInWithCredential (Google)',
        'idTokenLength=${idToken.length}',
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      logUserCredential('signInWithGoogle', userCred);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        logFirebaseAuth('GoogleSignIn.authenticate', 'canceled');
        return;
      }
      logFirebaseAuth(
        'GoogleSignIn.authenticate',
        'GoogleSignInException code=${e.code} description=${e.description}',
      );
      rethrow;
    }
  }
}

/// Thrown when native Google Sign-In failed to configure (channel error, etc.).
final class GoogleSignInUnavailableException implements Exception {
  const GoogleSignInUnavailableException([this.detail]);
  final String? detail;

  @override
  String toString() =>
      'Google Sign-In is not available on this build. '
      'Try a full rebuild (not hot restart), run `pod install` under ios/, '
      'and confirm Google is enabled in Firebase Auth. '
      '${detail ?? ''}';
}
