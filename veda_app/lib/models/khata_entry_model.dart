class KhataEntryModel {
  const KhataEntryModel({
    required this.id,
    required this.dairyId,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String dairyId;
  final String customerId;
  final String type;
  final double amount;
  final String note;
  final DateTime createdAt;
}
