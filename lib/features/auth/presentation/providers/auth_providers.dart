import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';

/// Firebase email/password + phone verification + password reset.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
