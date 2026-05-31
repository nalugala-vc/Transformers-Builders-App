enum AdminMemberActivityKind {
  joined,
  targetSet,
  goalChanged,
  contribution,
}

class AdminMemberActivityEvent {
  const AdminMemberActivityEvent({
    required this.kind,
    required this.date,
    this.amountKes,
    this.fromKes,
    this.toKes,
    this.paymentMethod,
    this.reference,
  });

  final AdminMemberActivityKind kind;
  final DateTime date;
  final int? amountKes;
  final int? fromKes;
  final int? toKes;
  final String? paymentMethod;
  final String? reference;
}
