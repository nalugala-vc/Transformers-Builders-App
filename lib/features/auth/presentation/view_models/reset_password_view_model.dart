import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  ResetPasswordViewModel(this._auth);

  final AuthRepository _auth;

  String? codeError;
  String? passwordError;
  String? confirmPasswordError;
  String? formError;
  bool isLoading = false;
  String? verifiedEmail;

  void clearErrors() {
    codeError = null;
    passwordError = null;
    confirmPasswordError = null;
    formError = null;
    notifyListeners();
  }

  bool _validate(String code, String password, String confirmPassword) {
    clearErrors();
    var ok = true;

    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) {
      codeError = 'Enter the reset code from your email.';
      ok = false;
    } else if (trimmedCode.length < 10) {
      codeError = 'That code looks too short. Copy the full code from the email link.';
      ok = false;
    }

    if (password.isEmpty) {
      passwordError = 'Enter a new password.';
      ok = false;
    } else if (password.length < 8) {
      passwordError = 'Use at least 8 characters.';
      ok = false;
    }

    if (confirmPassword != password) {
      confirmPasswordError = 'Passwords do not match.';
      ok = false;
    }

    if (!ok) notifyListeners();
    return ok;
  }

  Future<bool> submit({
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    if (!_validate(code, password, confirmPassword)) return false;

    isLoading = true;
    notifyListeners();
    try {
      final email = await _auth.verifyPasswordResetCode(code);
      verifiedEmail = email;
      await _auth.confirmPasswordReset(code: code, newPassword: password);
      return true;
    } on FirebaseAuthException catch (e) {
      formError = _messageFor(e);
      notifyListeners();
      return false;
    } catch (_) {
      formError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _messageFor(FirebaseAuthException e) => switch (e.code) {
        'expired-action-code' => 'This reset code has expired. Request a new link from Forgot password.',
        'invalid-action-code' => 'Invalid reset code. Check the code in your email or request a new link.',
        'weak-password' => 'Choose a stronger password (at least 8 characters).',
        'user-disabled' => 'This account has been disabled. Contact support.',
        _ => e.message ?? 'Could not reset your password. Please try again.',
      };
}

final resetPasswordViewModelProvider =
    ChangeNotifierProvider.autoDispose<ResetPasswordViewModel>(
  (ref) => ResetPasswordViewModel(ref.read(authRepositoryProvider)),
);
