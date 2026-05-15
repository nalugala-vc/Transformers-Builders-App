import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../models/otp_route_extra.dart';
import '../providers/auth_providers.dart';
import '../providers/user_profile_providers.dart';
import '../utils/phone_display.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Outcome of [RegisterViewModel.submit] after Firebase work.
final class RegisterSubmitResult {
  const RegisterSubmitResult._({
    required this.success,
    this.otp,
    this.goHome = false,
  });

  final bool success;
  final OtpRouteExtra? otp;
  final bool goHome;

  factory RegisterSubmitResult.failure() => const RegisterSubmitResult._(success: false);

  factory RegisterSubmitResult.needsOtp(OtpRouteExtra otp) =>
      RegisterSubmitResult._(success: true, otp: otp);

  factory RegisterSubmitResult.completed() =>
      const RegisterSubmitResult._(success: true, goHome: true);
}

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._auth, this._profiles);

  final AuthRepository _auth;
  final UserProfileRepository _profiles;

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

  Future<RegisterSubmitResult> submit({
    required String fullName,
    required String email,
    required String e164Phone,
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
      return RegisterSubmitResult.failure();
    }

    isLoading = true;
    notifyListeners();
    User? createdUser;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: plainPassword,
      );
      createdUser = cred.user;
      if (createdUser == null) {
        throw StateError('No user returned after sign-up.');
      }

      try {
        await _auth.updateDisplayName(createdUser, fullName);
      } catch (e) {
        await _auth.deleteCurrentUserAndSignOut();
        passwordError = 'Could not save your profile. Try again.';
        notifyListeners();
        return RegisterSubmitResult.failure();
      }

      try {
        await _auth.sendEmailVerification(createdUser);
      } catch (_) {
        // Email templates may be off in dev; continue with phone verification.
      }

      try {
        await _profiles.createMemberProfile(
          uid: createdUser.uid,
          email: email.trim(),
          fullName: fullName,
          phoneE164: e164Phone,
        );
      } catch (e) {
        await _auth.deleteCurrentUserAndSignOut();
        passwordError = 'Could not save your account. Try again.';
        if (kDebugMode) {
          debugPrint('createMemberProfile failed: $e');
        }
        notifyListeners();
        return RegisterSubmitResult.failure();
      }

      final start = await _auth.startPhoneVerification(phoneNumber: e164Phone);
      if (start.kind == PhoneVerificationKind.autoLinked) {
        await _auth.reloadCurrentUser();
        return RegisterSubmitResult.completed();
      }
      if (start.kind == PhoneVerificationKind.smsPending) {
        final vid = start.verificationId;
        if (vid == null || vid.isEmpty) {
          throw StateError('Missing verification id from Firebase.');
        }
        final masked = maskE164ForDisplay(e164Phone);
        return RegisterSubmitResult.needsOtp(
          OtpRouteExtra(
            verificationId: vid,
            e164Phone: e164Phone,
            forceResendingToken: start.forceResendingToken,
            maskedDestination: masked,
          ),
        );
      }

      return RegisterSubmitResult.failure();
    } on FirebaseAuthException catch (e) {
      _mapRegisterFirebaseError(e);
      await _cleanupFailedRegistration(createdUser);
      return RegisterSubmitResult.failure();
    } catch (e) {
      phoneError ??= 'Could not send verification SMS. Check the number and try again.';
      if (kDebugMode) {
        debugPrint('Register submit error: $e');
      }
      notifyListeners();
      await _cleanupFailedRegistration(createdUser);
      return RegisterSubmitResult.failure();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cleanupFailedRegistration(User? user) async {
    if (user == null) return;
    await _auth.deleteCurrentUserAndSignOut();
  }

  void _mapRegisterFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        emailError = 'This email is already registered';
        break;
      case 'weak-password':
        passwordError = 'Password is too weak';
        break;
      case 'invalid-email':
        emailError = 'Enter a valid email';
        break;
      case 'invalid-phone-number':
      case 'missing-phone-number':
      case 'quota-exceeded':
      case 'too-many-requests':
        phoneError = e.message ?? 'Phone verification failed';
        break;
      default:
        passwordError = e.message ?? 'Registration failed';
    }
    notifyListeners();
  }
}

final registerViewModelProvider = ChangeNotifierProvider.autoDispose<RegisterViewModel>(
  (ref) => RegisterViewModel(
    ref.read(authRepositoryProvider),
    ref.read(userProfileRepositoryProvider),
  ),
);
