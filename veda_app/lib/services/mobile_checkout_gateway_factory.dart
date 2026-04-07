import 'mobile_checkout_gateway.dart';
import 'mobile_checkout_gateway_stub.dart'
    if (dart.library.io) 'mobile_checkout_gateway_razorpay.dart';

MobileCheckoutGateway createMobileCheckoutGateway() =>
    createMobileCheckoutGatewayImpl();
