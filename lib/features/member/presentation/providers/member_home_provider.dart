import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/member_home_ui_state.dart';
import '../utils/member_formatters.dart';
import 'member_contribution_providers.dart';

/// Member home UI — profile, contribution goal, and recent activity from Firestore.
final memberHomeUiProvider = FutureProvider<MemberHomeUiState>((ref) async {
  ref.keepAlive();

  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) {
    throw StateError('No signed-in user.');
  }

  final contributions = await ref
      .read(memberContributionRepositoryProvider)
      .getHomeSummary(firebaseUser.uid);

  var firstName = 'Member';
  if (contributions.fullName != null) {
    firstName = firstNameFromFullName(contributions.fullName!);
  } else if (firebaseUser.displayName != null &&
      firebaseUser.displayName!.trim().isNotEmpty) {
    firstName = firstNameFromFullName(firebaseUser.displayName!);
  }

  return MemberHomeUiState(
    firstName: firstName,
    hasContributionGoal: contributions.hasContributionGoal,
    raisedKes: contributions.raisedKes,
    targetKes: contributions.targetKes ?? 0,
    goalAdjustedOn: contributions.goalAdjustedOn,
    showPendingAdminBanner: false,
    recentActivities: contributions.recentActivities,
  );
});
