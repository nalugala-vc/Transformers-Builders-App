import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class RegisterViewModel extends ChangeNotifier {
  String? fullNameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;
  String? termsError;
  bool isLoading = false;

  void clearErrors() {
    fullNameError = null;
    emailError = null;
    phoneError = null;
    passwordError = null;
    confirmPasswordError = null;
    termsError = null;
    notifyListeners();
  }

  bool validate({
    required String fullName,
    required String email,
    required String nationalPhoneDigits,
    required String plainPassword,
    required String confirmPassword,
    required bool agreeToTerms,
  }) {
    clearErrors();
    var valid = true;

    final name = fullName.trim();
    if (name.length < 2) {
      fullNameError = 'Enter your full name (at least 2 characters)';
      valid = false;
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      emailError = 'Enter your email';
      valid = false;
    } else if (!_emailPattern.hasMatch(trimmedEmail)) {
      emailError = 'Enter a valid email';
      valid = false;
    }

    final digits = nationalPhoneDigits.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      phoneError = 'Enter your phone number';
      valid = false;
    } else if (digits.length < 7) {
      phoneError = 'Enter a valid phone number';
      valid = false;
    }

    if (plainPassword.isEmpty) {
      passwordError = 'Enter a password';
      valid = false;
    } else if (plainPassword.length < 8) {
      passwordError = 'At least 8 characters';
      valid = false;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Confirm your password';
      valid = false;
    } else if (confirmPassword != plainPassword) {
      confirmPasswordError = 'Passwords do not match';
      valid = false;
    }

    if (!agreeToTerms) {
      termsError = 'Accept the terms and conditions to continue';
      valid = false;
    }

    notifyListeners();
    return valid;
  }

  Future<bool> submit({
    required String fullName,
    required String email,
    required String nationalPhoneDigits,
    required String plainPassword,
    required String confirmPassword,
    required bool agreeToTerms,
  }) async {
    if (!validate(
      fullName: fullName,
      email: email,
      nationalPhoneDigits: nationalPhoneDigits,
      plainPassword: plainPassword,
      confirmPassword: confirmPassword,
      agreeToTerms: agreeToTerms,
    )) {
      return false;
    }
    isLoading = true;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      // TODO: wire registration API
      return true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final registerViewModelProvider = ChangeNotifierProvider.autoDispose(
  (ref) => RegisterViewModel(),
);
