import '../models/payment_checkout_result.dart';
import '../models/subscription_plan_model.dart';

abstract class MobileCheckoutGateway {
  bool get isSupported;

  Future<PaymentCheckoutResult> openSubscriptionCheckout({
    required String keyId,
    required String requestId,
    required String userEmail,
    required SubscriptionPlanModel plan,
  });

  void dispose();
}
