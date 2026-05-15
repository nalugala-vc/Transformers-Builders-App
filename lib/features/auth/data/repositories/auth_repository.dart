import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

enum PhoneVerificationKind { autoLinked, smsPending }

/// Result of starting Firebase phone verification.
class PhoneVerificationStartResult {
  const PhoneVerificationStartResult.autoLinked()
      : kind = PhoneVerificationKind.autoLinked,
        verificationId = null,
        forceResendingToken = null;

  const PhoneVerificationStartResult.sms({
    required this.verificationId,
    this.forceResendingToken,
  }) : kind = PhoneVerificationKind.smsPending;

  final PhoneVerificationKind kind;
  final String? verificationId;
  final int? forceResendingToken;
}

/// Email/password + phone verification + password reset via Firebase Auth.
///
/// [auth] is optional for tests; production uses [FirebaseAuth.instance] lazily
/// so [Provider] creation does not require [Firebase.initializeApp].
class AuthRepository {
  AuthRepository([FirebaseAuth? auth]) : _authOverride = auth;

  final FirebaseAuth? _authOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> updateDisplayName(User user, String displayName) {
    return user.updateDisplayName(displayName.trim());
  }

  Future<void> sendEmailVerification(User user) {
    return user.sendEmailVerification();
  }

  /// Sends an SMS with a verification code to [phoneNumber] (E.164, e.g. `+2547…`).
  Future<PhoneVerificationStartResult> startPhoneVerification({
    required String phoneNumber,
    int? forceResendingToken,
  }) {
    final completer = Completer<PhoneVerificationStartResult>();
    var done = false;

    void complete(PhoneVerificationStartResult value) {
      if (done) return;
      done = true;
      if (!completer.isCompleted) completer.complete(value);
    }

    void fail(Object error, [StackTrace? stackTrace]) {
      if (done) return;
      done = true;
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace ?? StackTrace.current);
      }
    }

    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final user = _auth.currentUser;
          if (user == null) {
            fail(StateError('No signed-in user during phone auto-verification.'));
            return;
          }
          await user.linkWithCredential(credential);
          complete(const PhoneVerificationStartResult.autoLinked());
        } catch (e, st) {
          fail(e, st);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        fail(e);
      },
      codeSent: (String verificationId, int? token) {
        complete(
          PhoneVerificationStartResult.sms(
            verificationId: verificationId,
            forceResendingToken: token,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (done) return;
        complete(
          PhoneVerificationStartResult.sms(
            verificationId: verificationId,
            forceResendingToken: forceResendingToken,
          ),
        );
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 125),
      onTimeout: () {
        if (!completer.isCompleted) {
          throw TimeoutException(
            'Phone verification timed out. Check your number and try again.',
          );
        }
        return completer.future;
      },
    );
  }

  /// Links the SMS code to the current user (after email registration).
  Future<void> linkPhoneSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'You are not signed in. Please sign in and try again.',
      );
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await user.linkWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> reloadUser(User user) => user.reload();

  Future<void> reloadCurrentUser() async {
    final u = currentUser;
    if (u != null) await reloadUser(u);
  }

  /// Deletes the signed-in user (e.g. rollback after a failed post-signup step) then signs out.
  Future<void> deleteCurrentUserAndSignOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.delete();
      } catch (_) {}
    }
    await signOut();
  }
}
