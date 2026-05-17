import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/config/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../models/otp_route_extra.dart';
import '../providers/auth_providers.dart';
import '../providers/registration_flow_providers.dart';
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

typedef OnRegistrationOtpReady = void Function(OtpRouteExtra otp);

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(
    this._auth,
    this._profiles, {
    OnRegistrationOtpReady? onOtpReady,
  }) : _onOtpReady = onOtpReady;

  final AuthRepository _auth;
  final UserProfileRepository _profiles;
  final OnRegistrationOtpReady? _onOtpReady;

  bool _disposed = false;

  String? fullNameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;
  String? termsError;
  bool isLoading = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

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
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('[Register] updateDisplayName failed: $e');
          debugPrint('$st');
        }
        await _auth.deleteCurrentUserAndSignOut();
        passwordError = 'Could not save your profile. Try again.';
        notifyListeners();
        return RegisterSubmitResult.failure();
      }

      try {
        await _auth.sendEmailVerification(createdUser);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('[Register] sendEmailVerification failed (non-fatal): $e');
          debugPrint('$st');
        }
        // Email templates may be off in dev; continue with phone verification.
      }

      try {
        await _profiles.createMemberProfile(
          uid: createdUser.uid,
          email: email.trim(),
          fullName: fullName,
          phoneE164: e164Phone,
        );
      } catch (e, st) {
        await _auth.deleteCurrentUserAndSignOut();
        passwordError = e is TimeoutException
            ? e.message ?? 'Could not reach the server. Check your connection and try again.'
            : 'Could not save your account. Try again.';
        if (kDebugMode) {
          debugPrint('[Register] createMemberProfile failed: $e');
          debugPrint('$st');
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
        final otpExtra = OtpRouteExtra(
          verificationId: vid,
          e164Phone: e164Phone,
          forceResendingToken: start.forceResendingToken,
          maskedDestination: masked,
        );
        _onOtpReady?.call(otpExtra);
        return RegisterSubmitResult.needsOtp(otpExtra);
      }

      if (kDebugMode) {
        debugPrint(
          '[Register] Unexpected phone verification result kind=${start.kind}',
        );
      }
      return RegisterSubmitResult.failure();
    } on FirebaseAuthException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[Register] FirebaseAuthException: ${e.code} ${e.message}');
        debugPrint('$st');
      }
      _mapRegisterFirebaseError(e);
      await _cleanupFailedRegistration(createdUser);
      return RegisterSubmitResult.failure();
    } catch (e, st) {
      phoneError ??= 'Could not send verification SMS. Check the number and try again.';
      if (kDebugMode) {
        debugPrint('[Register] submit error: $e');
        debugPrint('$st');
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
      case 'channel-error':
        // Hot restart / isolate mismatch — native Firebase Auth channel is gone.
        passwordError =
            'Connection lost to sign-in services. Fully stop the app and run again '
            '(do not use Hot Restart when signing up).';
        break;
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

final registerViewModelProvider = ChangeNotifierProvider<RegisterViewModel>(
  (ref) => RegisterViewModel(
    ref.read(authRepositoryProvider),
    ref.read(userProfileRepositoryProvider),
    onOtpReady: (otp) {
      ref.read(pendingRegistrationOtpProvider.notifier).state = otp;
      appRouter.go(AppRoutePaths.otpVerification, extra: otp);
    },
  ),
);
