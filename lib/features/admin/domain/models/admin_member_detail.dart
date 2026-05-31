import '../../../auth/domain/models/app_user.dart';
import '../../../member/domain/models/contribution_activity.dart';
import 'admin_member_activity_event.dart';
import 'goal_history_entry.dart';

class AdminMemberDetail {
  const AdminMemberDetail({
    required this.user,
    required this.raisedKes,
    required this.targetKes,
    required this.goalHistory,
    required this.contributions,
    required this.activityEvents,
    required this.paymentMethodsUsed,
    this.goalSetAt,
    this.goalAdjustedAt,
  });

  final AppUser user;
  final int raisedKes;
  final int targetKes;
  final List<GoalHistoryEntry> goalHistory;
  final List<ContributionActivity> contributions;
  final List<AdminMemberActivityEvent> activityEvents;
  final List<String> paymentMethodsUsed;
  final DateTime? goalSetAt;
  final DateTime? goalAdjustedAt;

  int get goalLowerCount =>
      goalHistory.where((entry) => entry.isLowering).length;

  double get progressFraction =>
      targetKes <= 0 ? 0 : (raisedKes / targetKes).clamp(0.0, 1.0);

  int get progressPercent => (progressFraction * 100).round();
}
