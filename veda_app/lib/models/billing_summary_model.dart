class BillingSummaryModel {
  const BillingSummaryModel({
    required this.customerId,
    required this.customerName,
    required this.totalLiters,
    required this.averageFat,
    required this.averageSnf,
    required this.totalAmount,
    required this.entryCount,
    required this.cycleStart,
    required this.cycleEnd,
  });

  final String customerId;
  final String customerName;
  final double totalLiters;
  final double averageFat;
  final double averageSnf;
  final double totalAmount;
  final int entryCount;
  final DateTime cycleStart;
  final DateTime cycleEnd;
}
