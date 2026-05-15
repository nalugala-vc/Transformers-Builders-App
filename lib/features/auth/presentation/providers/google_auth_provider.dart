import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/google_auth_repository.dart';

final googleAuthRepositoryProvider = Provider<GoogleAuthRepository>(
  (ref) => GoogleAuthRepository(),
);
