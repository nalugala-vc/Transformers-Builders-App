import 'contribution_activity.dart';

/// Member contribution goal + totals for the home screen.
class MemberContributionSummary {
  const MemberContributionSummary({
    this.targetKes,
    this.goalSetAt,
    this.goalAdjustedAt,
    required this.raisedKes,
    required this.recentActivities,
    this.fullName,
  });

  final int? targetKes;
  final DateTime? goalSetAt;
  final DateTime? goalAdjustedAt;
  final int raisedKes;
  final List<ContributionActivity> recentActivities;
  final String? fullName;

  bool get hasContributionGoal => targetKes != null && targetKes! > 0;

  /// Set only when the member changes an existing target (not the first time).
  DateTime? get goalAdjustedOn => goalAdjustedAt;
}
