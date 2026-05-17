import 'contribution_activity.dart';

class MemberHomeUiState {
  const MemberHomeUiState({
    required this.firstName,
    required this.hasContributionGoal,
    required this.raisedKes,
    required this.targetKes,
    this.goalAdjustedOn,
    required this.showPendingAdminBanner,
    required this.unreadNotificationCount,
    required this.recentActivities,
  });

  final String firstName;
  final bool hasContributionGoal;
  final int raisedKes;
  final int targetKes;
  final DateTime? goalAdjustedOn;
  final bool showPendingAdminBanner;
  final int unreadNotificationCount;
  final List<ContributionActivity> recentActivities;

  double get progressFraction {
    if (!hasContributionGoal || targetKes <= 0) return 0;
    return (raisedKes / targetKes).clamp(0.0, 1.0);
  }

  static List<ContributionActivity> get sampleActivities => [
        ContributionActivity(
          id: '1',
          date: DateTime(2026, 1, 20),
          amountKes: 500,
          paymentMethod: 'M-Pesa',
          reference: 'QHX72K9LMP',
          status: ContributionPaymentStatus.completed,
        ),
        ContributionActivity(
          id: '2',
          date: DateTime(2026, 1, 8),
          amountKes: 1000,
          paymentMethod: 'Card',
          reference: 'TC-2026-0108',
          status: ContributionPaymentStatus.completed,
        ),
        ContributionActivity(
          id: '3',
          date: DateTime(2025, 12, 15),
          amountKes: 1000,
          paymentMethod: 'M-Pesa',
          reference: 'PLK91M2NQR',
          status: ContributionPaymentStatus.completed,
        ),
      ];
}
