import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._auth);

  final AuthRepository _auth;

  String? emailError;
  String? passwordError;
  bool isLoading = false;

  void clearErrors() {
    emailError = null;
    passwordError = null;
    notifyListeners();
  }

  bool validate(String email, String plainPassword) {
    clearErrors();
    var valid = true;

    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      emailError = 'Enter your email';
      valid = false;
    } else if (!_emailPattern.hasMatch(trimmed)) {
      emailError = 'Enter a valid email';
      valid = false;
    }

    if (plainPassword.isEmpty) {
      passwordError = 'Enter your password';
      valid = false;
    } else if (plainPassword.length < 8) {
      passwordError = 'Password must be at least 8 characters';
      valid = false;
    }

    notifyListeners();
    return valid;
  }

  Future<bool> submit(String email, String plainPassword) async {
    if (!validate(email, plainPassword)) return false;
    isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: plainPassword,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _mapLoginFirebaseError(e);
      return false;
    } catch (_) {
      passwordError = 'Something went wrong. Try again.';
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _mapLoginFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'channel-error':
        passwordError =
            'Connection lost to sign-in services. Fully stop the app and run again '
            '(avoid Hot Restart before signing in).';
        break;
      case 'invalid-email':
        emailError = 'Enter a valid email';
        break;
      case 'user-disabled':
        passwordError = 'This account has been disabled.';
        break;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        passwordError = 'Wrong email or password';
        break;
      default:
        passwordError = e.message ?? 'Sign-in failed';
    }
    notifyListeners();
  }
}

final loginViewModelProvider = ChangeNotifierProvider.autoDispose<LoginViewModel>(
  (ref) => LoginViewModel(ref.read(authRepositoryProvider)),
);
