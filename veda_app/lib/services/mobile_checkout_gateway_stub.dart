import '../models/payment_checkout_result.dart';
import '../models/subscription_plan_model.dart';
import 'mobile_checkout_gateway.dart';

class UnsupportedMobileCheckoutGateway implements MobileCheckoutGateway {
  @override
  bool get isSupported => false;

  @override
  Future<PaymentCheckoutResult> openSubscriptionCheckout({
    required String keyId,
    required String requestId,
    required String userEmail,
    required SubscriptionPlanModel plan,
  }) async {
    return const PaymentCheckoutResult(
      status: 'unsupported',
      message: 'Mobile checkout is not supported on this platform.',
    );
  }

  @override
  void dispose() {}
}

MobileCheckoutGateway createMobileCheckoutGatewayImpl() =>
    UnsupportedMobileCheckoutGateway();
