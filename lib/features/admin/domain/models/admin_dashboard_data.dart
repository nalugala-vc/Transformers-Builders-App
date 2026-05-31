import '../../../member/domain/models/church_progress_data.dart';
import 'admin_attention_item.dart';
import 'admin_recent_activity.dart';

/// Snapshot consumed by the admin dashboard tab. Built by
/// [AdminDashboardRepository.loadDashboard] from a handful of Firestore reads.
class AdminDashboardData {
  const AdminDashboardData({
    required this.totalRaisedKes,
    required this.totalRaisedDeltaKes,
    required this.totalRaisedDeltaPercent,
    required this.activeMembers,
    required this.newMembersThisWeek,
    required this.churchProgress,
    required this.recentActivity,
    required this.attentionItems,
  });

  static const empty = AdminDashboardData(
    totalRaisedKes: 0,
    totalRaisedDeltaKes: 0,
    totalRaisedDeltaPercent: 0,
    activeMembers: 0,
    newMembersThisWeek: 0,
    churchProgress: ChurchProgressData.empty,
    recentActivity: [],
    attentionItems: [],
  );

  /// Sum of all completed contributions across the church (KES).
  final int totalRaisedKes;

  /// KES raised in the trailing 7 days (used for the "+12.5% this week" delta).
  final int totalRaisedDeltaKes;

  /// Percentage of [totalRaisedKes] that came in the trailing 7 days.
  final double totalRaisedDeltaPercent;

  /// Members with `role == "member"` in the `users` collection.
  final int activeMembers;

  /// Members whose `createdAt` is within the trailing 7 days.
  final int newMembersThisWeek;

  /// Same per-group totals shown on the member Progress tab; surfaced on the
  /// dashboard so the admin sees the same donut + segments with exact amounts.
  final ChurchProgressData churchProgress;

  /// Last 10 events across the campaign (most recent first).
  final List<AdminRecentActivity> recentActivity;

  /// Items the admin should action (pending requests, drafts, etc.).
  final List<AdminAttentionItem> attentionItems;
}
