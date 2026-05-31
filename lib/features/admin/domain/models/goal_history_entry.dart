class GoalHistoryEntry {
  const GoalHistoryEntry({
    required this.fromKes,
    required this.toKes,
    required this.changedAt,
  });

  final int fromKes;
  final int toKes;
  final DateTime changedAt;

  bool get isLowering => toKes < fromKes;
}
