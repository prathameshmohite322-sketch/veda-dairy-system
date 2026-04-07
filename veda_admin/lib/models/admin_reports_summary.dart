import 'admin_dairy_summary.dart';

class AdminReportsSummary {
  const AdminReportsSummary({
    required this.totalPending,
    required this.totalApproved,
    required this.totalRejected,
    required this.totalSuccess,
    required this.dairies,
  });

  final int totalPending;
  final int totalApproved;
  final int totalRejected;
  final int totalSuccess;
  final List<AdminDairySummary> dairies;
}
