import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Debug-only output for Firebase Auth–related calls.
///
/// Uses both [dev.log] (DevTools) and [debugPrint] so messages show in the
/// **flutter run** terminal as well.
/// Does not log passwords, refresh tokens, ID tokens, or SMS codes.
void logFirebaseAuth(String event, [Object? detail]) {
  if (!kDebugMode) return;
  final msg = detail != null ? '$event | $detail' : event;
  dev.log(msg, name: 'FirebaseAuth');
  debugPrint('[FirebaseAuth] $msg');
}

void logUserCredential(String operation, UserCredential cred) {
  if (!kDebugMode) return;
  final u = cred.user;
  final info = cred.additionalUserInfo;
  final msg =
      '$operation → uid=${u?.uid}, email=${u?.email}, '
      'emailVerified=${u?.emailVerified}, displayName=${u?.displayName}, '
      'isNewUser=${info?.isNewUser}, profile=${info?.profile}, '
      'credentialProvider=${cred.credential?.providerId}';
  dev.log(msg, name: 'FirebaseAuth');
  debugPrint('[FirebaseAuth] $msg');
}

void logFirebaseAuthException(String operation, FirebaseAuthException e) {
  if (!kDebugMode) return;
  final msg =
      '$operation → FirebaseAuthException code=${e.code}, message=${e.message}, '
      'email=${e.email}';
  dev.log(msg, name: 'FirebaseAuth');
  debugPrint('[FirebaseAuth] $msg');
}

void logFirebaseAuthError(String operation, Object e, [StackTrace? st]) {
  if (!kDebugMode) return;
  dev.log('$operation → error=$e', name: 'FirebaseAuth', stackTrace: st);
  debugPrint('[FirebaseAuth] $operation → error=$e');
  if (st != null) {
    debugPrint('[FirebaseAuth] $st');
  }
}

/// User profile reads/writes (Firestore) tied to auth — debug only.
void logAuthFirestore(String event, [Object? detail]) {
  if (!kDebugMode) return;
  final msg = detail != null ? '$event | $detail' : event;
  dev.log(msg, name: 'AuthFirestore');
  debugPrint('[AuthFirestore] $msg');
}
