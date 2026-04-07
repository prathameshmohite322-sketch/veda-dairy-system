class FactorySaleModel {
  const FactorySaleModel({
    required this.id,
    required this.dairyId,
    required this.factoryName,
    required this.liters,
    required this.saleRate,
    required this.commissionPerLiter,
    required this.totalAmount,
    required this.commissionAmount,
    required this.netProfit,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String dairyId;
  final String factoryName;
  final double liters;
  final double saleRate;
  final double commissionPerLiter;
  final double totalAmount;
  final double commissionAmount;
  final double netProfit;
  final String note;
  final DateTime createdAt;
}
