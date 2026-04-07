class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.totalUsers,
    required this.totalDairies,
    required this.pendingSubscriptionRequests,
    required this.completedSubscriptionRequests,
  });

  final int totalUsers;
  final int totalDairies;
  final int pendingSubscriptionRequests;
  final int completedSubscriptionRequests;
}
