import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/user_profile_repository.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepository(),
);
