import 'contribution_activity.dart';

class MemberHomeUiState {
  const MemberHomeUiState({
    required this.firstName,
    required this.hasContributionGoal,
    required this.raisedKes,
    required this.targetKes,
    this.goalAdjustedOn,
    required this.showPendingAdminBanner,
    required this.recentActivities,
  });

  final String firstName;
  final bool hasContributionGoal;
  final int raisedKes;
  final int targetKes;
  final DateTime? goalAdjustedOn;
  final bool showPendingAdminBanner;
  final List<ContributionActivity> recentActivities;

  double get progressFraction {
    if (!hasContributionGoal || targetKes <= 0) return 0;
    return (raisedKes / targetKes).clamp(0.0, 1.0);
  }
}
