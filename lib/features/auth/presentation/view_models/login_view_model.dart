import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginViewModel extends ChangeNotifier {
  String? emailError;
  String? passwordError;
  bool isLoading = false;

  void clearErrors() {
    emailError = null;
    passwordError = null;
    notifyListeners();
  }

  /// Validates [email] and [plainPassword]. Returns true when both are valid.
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
      await Future<void>.delayed(const Duration(milliseconds: 600));
      // TODO: wire Firebase Auth / API
      return true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final loginViewModelProvider = ChangeNotifierProvider.autoDispose(
  (ref) => LoginViewModel(),
);
