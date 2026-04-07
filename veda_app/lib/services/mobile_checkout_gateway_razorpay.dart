import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/payment_checkout_result.dart';
import '../models/subscription_plan_model.dart';
import 'mobile_checkout_gateway.dart';

class RazorpayMobileCheckoutGateway implements MobileCheckoutGateway {
  RazorpayMobileCheckoutGateway() : _razorpay = Razorpay();

  final Razorpay _razorpay;

  @override
  bool get isSupported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<PaymentCheckoutResult> openSubscriptionCheckout({
    required String keyId,
    required String requestId,
    required String userEmail,
    required SubscriptionPlanModel plan,
  }) async {
    final Completer<PaymentCheckoutResult> completer =
        Completer<PaymentCheckoutResult>();

    void handleSuccess(PaymentSuccessResponse response) {
      if (completer.isCompleted) {
        return;
      }
      completer.complete(
        PaymentCheckoutResult(
          status: 'success',
          message: 'Payment completed successfully.',
          paymentId: response.paymentId,
          signature: response.signature,
        ),
      );
    }

    void handleError(PaymentFailureResponse response) {
      if (completer.isCompleted) {
        return;
      }
      completer.complete(
        PaymentCheckoutResult(
          status: 'failed',
          message: response.message ?? 'Payment failed.',
          errorCode: response.code?.toString(),
        ),
      );
    }

    void handleWallet(ExternalWalletResponse response) {
      if (completer.isCompleted) {
        return;
      }
      completer.complete(
        PaymentCheckoutResult(
          status: 'external_wallet',
          message: 'External wallet selected.',
          externalWallet: response.walletName,
        ),
      );
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleWallet);

    try {
      _razorpay.open(<String, Object>{
        'key': keyId,
        'amount': (plan.price * 100).round(),
        'name': 'Veda Dairy System',
        'description': '${plan.name} ${plan.billingLabel} subscription',
        'prefill': <String, String>{
          'email': userEmail,
        },
        'notes': <String, String>{
          'requestId': requestId,
          'planId': plan.id,
        },
      });

      final PaymentCheckoutResult result = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => const PaymentCheckoutResult(
          status: 'timeout',
          message: 'Payment confirmation timed out.',
        ),
      );
      _clearHandlers();
      return result;
    } catch (error) {
      _clearHandlers();
      return PaymentCheckoutResult(
        status: 'failed',
        message: error.toString(),
      );
    }
  }

  void _clearHandlers() {
    _razorpay.clear();
  }

  @override
  void dispose() {
    _razorpay.clear();
  }
}

MobileCheckoutGateway createMobileCheckoutGatewayImpl() =>
    RazorpayMobileCheckoutGateway();
