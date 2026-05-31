enum AdminAttentionKind {
  pendingAdminRequest,
  pendingMemberApproval,
  announcementDraft,
}

class AdminAttentionItem {
  const AdminAttentionItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final AdminAttentionKind kind;
  final String title;
  final String subtitle;
}
