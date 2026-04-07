class AdminPaymentRequest {
  const AdminPaymentRequest({
    required this.id,
    required this.dairyId,
    required this.userEmail,
    required this.planName,
    required this.amount,
    required this.status,
    required this.platform,
  });

  final String id;
  final String dairyId;
  final String userEmail;
  final String planName;
  final double amount;
  final String status;
  final String platform;
}
