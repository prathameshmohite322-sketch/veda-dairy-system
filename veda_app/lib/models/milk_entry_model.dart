class MilkEntryModel {
  const MilkEntryModel({
    required this.id,
    required this.dairyId,
    required this.customerId,
    required this.customerName,
    required this.shift,
    required this.cattleType,
    required this.liters,
    required this.fat,
    required this.snf,
    required this.rate,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String dairyId;
  final String customerId;
  final String customerName;
  final String shift;
  final String cattleType;
  final double liters;
  final double fat;
  final double snf;
  final double rate;
  final double amount;
  final DateTime createdAt;
}
