import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel(this._auth);

  final AuthRepository _auth;

  String? emailError;
  bool isLoading = false;

  void clearErrors() {
    emailError = null;
    notifyListeners();
  }

  bool validate(String email) {
    clearErrors();
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      emailError = 'Enter your email address.';
      notifyListeners();
      return false;
    }
    if (!_emailPattern.hasMatch(trimmed)) {
      emailError = 'Enter a valid email address.';
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Returns `true` when the reset email was requested (or Firebase accepted the request).
  Future<bool> submit(String email) async {
    if (!validate(email)) return false;
    isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        emailError = 'Enter a valid email address.';
        notifyListeners();
        return false;
      }
      if (e.code == 'channel-error') {
        emailError =
            'Connection lost. Stop the app completely and run again (avoid Hot Restart).';
        notifyListeners();
        return false;
      }
      // Avoid account enumeration for missing users / network quirks.
      return true;
    } catch (_) {
      emailError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final forgotPasswordViewModelProvider =
    ChangeNotifierProvider.autoDispose<ForgotPasswordViewModel>(
  (ref) => ForgotPasswordViewModel(ref.read(authRepositoryProvider)),
);
