import 'package:flutter_riverpod/legacy.dart';

import '../models/otp_route_extra.dart';

/// Set when registration needs SMS verification; used to open [OtpVerificationScreen]
/// after Firebase reCAPTCHA returns to the app.
final pendingRegistrationOtpProvider = StateProvider<OtpRouteExtra?>(
  (ref) => null,
);
