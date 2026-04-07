class PaymentCheckoutResult {
  const PaymentCheckoutResult({
    required this.status,
    required this.message,
    this.paymentId,
    this.signature,
    this.externalWallet,
    this.errorCode,
  });

  final String status;
  final String message;
  final String? paymentId;
  final String? signature;
  final String? externalWallet;
  final String? errorCode;
}
