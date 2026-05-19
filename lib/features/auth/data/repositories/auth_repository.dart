import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../firebase_auth_logger.dart';

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
  }) async {
    logFirebaseAuth('signInWithEmailAndPassword', 'email=${email.trim()}');
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      logUserCredential('signInWithEmailAndPassword', cred);
      return cred;
    } on FirebaseAuthException catch (e, st) {
      logFirebaseAuthException('signInWithEmailAndPassword', e);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    logFirebaseAuth('createUserWithEmailAndPassword', 'email=${email.trim()}');
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      logUserCredential('createUserWithEmailAndPassword', cred);
      return cred;
    } on FirebaseAuthException catch (e, st) {
      logFirebaseAuthException('createUserWithEmailAndPassword', e);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    logFirebaseAuth('sendPasswordResetEmail', 'email=${email.trim()}');
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      logFirebaseAuth('sendPasswordResetEmail', 'success');
    } on FirebaseAuthException catch (e, st) {
      logFirebaseAuthException('sendPasswordResetEmail', e);
      Error.throwWithStackTrace(e, st);
    }
  }

  /// Returns the email address associated with a password-reset [code].
  Future<String> verifyPasswordResetCode(String code) async {
    logFirebaseAuth('verifyPasswordResetCode', 'codeLength=${code.length}');
    try {
      final email = await _auth.verifyPasswordResetCode(code.trim());
      logFirebaseAuth('verifyPasswordResetCode', 'success email=$email');
      return email;
    } on FirebaseAuthException catch (e, st) {
      logFirebaseAuthException('verifyPasswordResetCode', e);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    logFirebaseAuth('confirmPasswordReset', 'codeLength=${code.length}');
    try {
      await _auth.confirmPasswordReset(code: code.trim(), newPassword: newPassword);
      logFirebaseAuth('confirmPasswordReset', 'success');
    } on FirebaseAuthException catch (e, st) {
      logFirebaseAuthException('confirmPasswordReset', e);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> updateDisplayName(User user, String displayName) async {
    logFirebaseAuth('updateDisplayName', 'uid=${user.uid}, displayName=$displayName');
    try {
      await user.updateDisplayName(displayName.trim());
      logFirebaseAuth('updateDisplayName', 'success');
    } on FirebaseAuthException catch (e, st) {
      logFirebaseAuthException('updateDisplayName', e);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> sendEmailVerification(User user) async {
    logFirebaseAuth('sendEmailVerification', 'uid=${user.uid}');
    try {
      await user.sendEmailVerification();
      logFirebaseAuth('sendEmailVerification', 'success');
    } on FirebaseAuthException catch (e, st) {
      logFirebaseAuthException('sendEmailVerification', e);
      Error.throwWithStackTrace(e, st);
    }
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

    logFirebaseAuth(
      'verifyPhoneNumber',
      'phoneNumber=$phoneNumber, forceResendingToken=$forceResendingToken',
    );
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        logFirebaseAuth(
          'verifyPhoneNumber.verificationCompleted',
          'providerId=${credential.providerId}',
        );
        try {
          final user = _auth.currentUser;
          if (user == null) {
            fail(StateError('No signed-in user during phone auto-verification.'));
            return;
          }
          await user.linkWithCredential(credential);
          logFirebaseAuth('linkWithCredential (auto)', 'uid=${user.uid}');
          complete(const PhoneVerificationStartResult.autoLinked());
        } catch (e, st) {
          logFirebaseAuthError('verifyPhoneNumber.verificationCompleted', e, st);
          fail(e, st);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        logFirebaseAuthException('verifyPhoneNumber.verificationFailed', e);
        fail(e);
      },
      codeSent: (String verificationId, int? token) {
        logFirebaseAuth(
          'verifyPhoneNumber.codeSent',
          'verificationId length=${verificationId.length}, resendToken=$token',
        );
        complete(
          PhoneVerificationStartResult.sms(
            verificationId: verificationId,
            forceResendingToken: token,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (done) return;
        logFirebaseAuth(
          'verifyPhoneNumber.codeAutoRetrievalTimeout',
          'verificationId length=${verificationId.length}',
        );
        complete(
          PhoneVerificationStartResult.sms(
            verificationId: verificationId,
            forceResendingToken: forceResendingToken,
          ),
        );
      },
    );

    return completer.future
        .then((result) {
          logFirebaseAuth('startPhoneVerification', 'resultKind=${result.kind}');
          return result;
        })
        .catchError((Object e, StackTrace st) {
          logFirebaseAuthError('startPhoneVerification', e, st);
          Error.throwWithStackTrace(e, st);
        })
        .timeout(
      const Duration(seconds: 125),
      onTimeout: () {
        if (!completer.isCompleted) {
          logFirebaseAuth('startPhoneVerification', 'timeout');
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
      logFirebaseAuth('linkPhoneSmsCode', 'error=noCurrentUser');
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'You are not signed in. Please sign in and try again.',
      );
    }
    logFirebaseAuth(
      'linkPhoneSmsCode',
      'uid=${user.uid}, smsCodeLength=${smsCode.length}, '
      'verificationIdLength=${verificationId.length}',
    );
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    try {
      await user.linkWithCredential(credential);
      logFirebaseAuth('linkPhoneSmsCode', 'success uid=${user.uid}');
    } on FirebaseAuthException catch (e, st) {
      logFirebaseAuthException('linkPhoneSmsCode', e);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> signOut() async {
    logFirebaseAuth('signOut', 'uid=${currentUser?.uid}');
    await _auth.signOut();
    logFirebaseAuth('signOut', 'success');
  }

  Future<void> reloadUser(User user) async {
    logFirebaseAuth('reloadUser', 'uid=${user.uid}');
    await user.reload();
    logFirebaseAuth('reloadUser', 'success emailVerified=${user.emailVerified}');
  }

  Future<void> reloadCurrentUser() async {
    final u = currentUser;
    if (u != null) await reloadUser(u);
  }

  /// Deletes the signed-in user (e.g. rollback after a failed post-signup step) then signs out.
  Future<void> deleteCurrentUserAndSignOut() async {
    final user = _auth.currentUser;
    logFirebaseAuth('deleteCurrentUserAndSignOut', 'uid=${user?.uid}');
    if (user != null) {
      try {
        await user.delete();
        logFirebaseAuth('deleteCurrentUserAndSignOut', 'user.delete success');
      } catch (e, st) {
        logFirebaseAuthError('deleteCurrentUserAndSignOut.user.delete', e, st);
      }
    }
    await signOut();
  }
}
