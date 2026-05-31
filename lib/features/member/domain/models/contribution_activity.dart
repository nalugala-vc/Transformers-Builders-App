enum ContributionPaymentStatus {
  completed,
  pending,
  failed,
}

class ContributionActivity {
  const ContributionActivity({
    required this.id,
    required this.date,
    required this.amountKes,
    required this.paymentMethod,
    required this.reference,
    required this.status,
    this.notes,
    this.providerReference,
    this.fxRate,
  });

  final String id;
  final DateTime date;
  final int amountKes;
  final String paymentMethod;
  final String reference;
  final ContributionPaymentStatus status;
  final String? notes;
  final String? providerReference;
  final double? fxRate;
}
