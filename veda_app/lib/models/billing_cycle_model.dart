class BillingCycleModel {
  const BillingCycleModel({
    required this.startDate,
    required this.endDate,
    required this.label,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String label;
}
