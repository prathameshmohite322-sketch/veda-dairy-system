class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.dairyId,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.createdAtIso,
  });

  final String id;
  final String dairyId;
  final String customerId;
  final String type;
  final double amount;
  final String createdAtIso;
}
