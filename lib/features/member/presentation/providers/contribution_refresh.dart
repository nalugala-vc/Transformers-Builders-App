import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'member_contribution_providers.dart';
import 'member_home_provider.dart';
import 'member_progress_provider.dart';

void invalidateContributionData(WidgetRef ref) {
  ref.invalidate(memberHomeUiProvider);
  ref.invalidate(memberContributionsListProvider);
  ref.invalidate(churchProgressSnapshotProvider);
}
