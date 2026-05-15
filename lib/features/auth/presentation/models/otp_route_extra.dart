import 'package:flutter/foundation.dart';

/// Passed as [GoRouterState.extra] when opening [OtpVerificationScreen] after
/// registration so Firebase Phone Auth can verify the SMS code.
@immutable
final class OtpRouteExtra {
  const OtpRouteExtra({
    required this.verificationId,
    required this.e164Phone,
    this.forceResendingToken,
    required this.maskedDestination,
  });

  final String verificationId;
  final String e164Phone;
  final int? forceResendingToken;
  final String maskedDestination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpRouteExtra &&
          runtimeType == other.runtimeType &&
          verificationId == other.verificationId &&
          e164Phone == other.e164Phone &&
          forceResendingToken == other.forceResendingToken &&
          maskedDestination == other.maskedDestination;

  @override
  int get hashCode =>
      Object.hash(verificationId, e164Phone, forceResendingToken, maskedDestination);
}
