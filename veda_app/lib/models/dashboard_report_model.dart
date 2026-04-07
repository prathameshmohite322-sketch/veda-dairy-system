class DashboardReportModel {
  const DashboardReportModel({
    required this.todayMilkLiters,
    required this.todayMilkValue,
    required this.currentCycleAmount,
    required this.currentCycleLiters,
    required this.activeFarmers,
    required this.totalAdvanceOutstanding,
    required this.recentEntryCount,
  });

  final double todayMilkLiters;
  final double todayMilkValue;
  final double currentCycleAmount;
  final double currentCycleLiters;
  final int activeFarmers;
  final double totalAdvanceOutstanding;
  final int recentEntryCount;
}
