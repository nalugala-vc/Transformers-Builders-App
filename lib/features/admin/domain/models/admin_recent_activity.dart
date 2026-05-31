/// Event type for the dashboard "Recent Activity" feed.
///
/// Phase 1 only emits [memberContribution]; the other types are reserved so the
/// feed can grow without breaking widgets.
enum AdminRecentActivityType {
  memberContribution,
  adminRequest,
  announcement,
}

/// A single, normalized item shown in the admin "Recent Activity" feed.
class AdminRecentActivity {
  const AdminRecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.occurredAt,
    this.amountKes,
    this.memberUid,
    this.contributionId,
  });

  final String id;
  final AdminRecentActivityType type;
  final String title;
  final String subtitle;
  final DateTime occurredAt;
  final int? amountKes;
  final String? memberUid;
  final String? contributionId;
}
