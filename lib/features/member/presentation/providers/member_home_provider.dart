import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/user_profile_providers.dart';
import '../../domain/models/member_home_ui_state.dart';
import '../utils/member_formatters.dart';

/// Member home UI data. Contribution totals are mocked until Firestore wiring lands.
final memberHomeUiProvider = FutureProvider<MemberHomeUiState>((ref) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  var firstName = 'Member';

  if (firebaseUser != null) {
    final profile = await ref.read(userProfileRepositoryProvider).getUser(firebaseUser.uid);
    if (profile != null) {
      firstName = firstNameFromFullName(profile.fullName);
    } else if (firebaseUser.displayName != null && firebaseUser.displayName!.trim().isNotEmpty) {
      firstName = firstNameFromFullName(firebaseUser.displayName!);
    }
  }

  // Demo data — replace with Firestore contribution reads.
  const hasGoal = true;
  const showPendingAdmin = false;

  return MemberHomeUiState(
    firstName: firstName,
    hasContributionGoal: hasGoal,
    raisedKes: 2500,
    targetKes: 5000,
    goalAdjustedOn: DateTime(2026, 1, 12),
    showPendingAdminBanner: showPendingAdmin,
    unreadNotificationCount: 2,
    recentActivities: MemberHomeUiState.sampleActivities,
  );
});
