import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw StateError('Google Sign-In did not return an ID token.');
      }
      await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
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
