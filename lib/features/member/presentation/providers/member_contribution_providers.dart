import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/member_contribution_repository.dart';

final memberContributionRepositoryProvider = Provider<MemberContributionRepository>(
  (ref) => MemberContributionRepository(),
);
