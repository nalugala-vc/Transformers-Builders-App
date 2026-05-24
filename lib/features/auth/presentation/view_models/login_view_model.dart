import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../l10n/app_localizations.dart';
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

  bool validate(AppLocalizations l10n, String email, String plainPassword) {
    clearErrors();
    var valid = true;

    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      emailError = l10n.errorEnterEmail;
      valid = false;
    } else if (!_emailPattern.hasMatch(trimmed)) {
      emailError = l10n.errorValidEmail;
      valid = false;
    }

    if (plainPassword.isEmpty) {
      passwordError = l10n.errorEnterPassword;
      valid = false;
    } else if (plainPassword.length < 8) {
      passwordError = l10n.errorPasswordMinLength;
      valid = false;
    }

    notifyListeners();
    return valid;
  }

  Future<bool> submit(
    AppLocalizations l10n,
    String email,
    String plainPassword,
  ) async {
    if (!validate(l10n, email, plainPassword)) return false;
    isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: plainPassword,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _mapLoginFirebaseError(l10n, e);
      return false;
    } catch (_) {
      passwordError = l10n.errorSomethingWrong;
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _mapLoginFirebaseError(AppLocalizations l10n, FirebaseAuthException e) {
    switch (e.code) {
      case 'channel-error':
        passwordError =
            'Connection lost to sign-in services. Fully stop the app and run again '
            '(avoid Hot Restart before signing in).';
        break;
      case 'invalid-email':
        emailError = l10n.errorValidEmail;
        break;
      case 'user-disabled':
        passwordError = l10n.errorAccountDisabled;
        break;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        passwordError = l10n.errorWrongCredentials;
        break;
      default:
        passwordError = e.message ?? l10n.errorSignInFailed;
    }
    notifyListeners();
  }
}

final loginViewModelProvider = ChangeNotifierProvider.autoDispose<LoginViewModel>(
  (ref) => LoginViewModel(ref.read(authRepositoryProvider)),
);
