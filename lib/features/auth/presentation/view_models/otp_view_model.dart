import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/auth_repository.dart';
import '../models/otp_route_extra.dart';
import '../providers/auth_providers.dart';

class OtpViewModel extends ChangeNotifier {
  OtpViewModel(this._auth, this._initial) {
    _verificationId = _initial.verificationId;
    _resendToken = _initial.forceResendingToken;
  }

  final AuthRepository _auth;
  final OtpRouteExtra _initial;

  late String _verificationId;
  int? _resendToken;

  String? verifyError;
  String? resendError;
  bool isLoading = false;
  bool isResending = false;

  String get maskedDestination => _initial.maskedDestination;

  Future<bool> verifySms(String smsCode) async {
    verifyError = null;
    isLoading = true;
    notifyListeners();
    try {
      await _auth.linkPhoneSmsCode(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await _auth.reloadCurrentUser();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        verifyError = 'This phone number is already linked to another account.';
      } else {
        verifyError = e.message ?? 'Invalid code. Try again.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      verifyError = 'Something went wrong. Try again.';
      if (kDebugMode) {
        debugPrint('OTP verify: $e');
      }
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendSms() async {
    resendError = null;
    isResending = true;
    notifyListeners();
    try {
      final start = await _auth.startPhoneVerification(
        phoneNumber: _initial.e164Phone,
        forceResendingToken: _resendToken,
      );
      if (start.kind == PhoneVerificationKind.smsPending) {
        final vid = start.verificationId;
        if (vid != null && vid.isNotEmpty) {
          _verificationId = vid;
        }
        _resendToken = start.forceResendingToken;
      }
      return true;
    } on FirebaseAuthException catch (e) {
      resendError = e.message ?? 'Could not resend code.';
      notifyListeners();
      return false;
    } catch (e) {
      resendError = 'Could not resend code. Try again later.';
      if (kDebugMode) {
        debugPrint('OTP resend: $e');
      }
      notifyListeners();
      return false;
    } finally {
      isResending = false;
      notifyListeners();
    }
  }
}

final otpViewModelProvider =
    ChangeNotifierProvider.autoDispose.family<OtpViewModel, OtpRouteExtra>(
  (ref, extra) => OtpViewModel(ref.read(authRepositoryProvider), extra),
);
