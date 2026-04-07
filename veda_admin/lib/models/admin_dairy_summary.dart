class AdminDairySummary {
  const AdminDairySummary({
    required this.dairyId,
    required this.userCount,
    required this.pendingPayments,
    required this.completedPayments,
  });

  final String dairyId;
  final int userCount;
  final int pendingPayments;
  final int completedPayments;
}
