import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/payment_checkout_result.dart';
import '../models/subscription_plan_model.dart';
import 'mobile_checkout_gateway.dart';
import 'mobile_checkout_gateway_factory.dart';
import 'offline_service.dart';

class PaymentService {
  PaymentService({
    FirebaseFirestore? firestore,
    OfflineService? offlineService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _offlineService = offlineService ?? OfflineService(),
        _checkoutGateway = createMobileCheckoutGateway();

  final FirebaseFirestore _firestore;
  final OfflineService _offlineService;
  final MobileCheckoutGateway _checkoutGateway;

  List<SubscriptionPlanModel> availablePlans() {
    return const <SubscriptionPlanModel>[
      SubscriptionPlanModel(
        id: 'starter_monthly',
        name: 'Starter',
        price: 499,
        billingLabel: 'Monthly',
        features: <String>[
          'Milk entry and farmer management',
          '10-day billing and khata',
          'PDF bill sharing',
        ],
      ),
      SubscriptionPlanModel(
        id: 'growth_monthly',
        name: 'Growth',
        price: 999,
        billingLabel: 'Monthly',
        features: <String>[
          'Everything in Starter',
          'Offline auto sync',
          'Factory sales and reports',
        ],
      ),
      SubscriptionPlanModel(
        id: 'premium_monthly',
        name: 'Premium',
        price: 1499,
        billingLabel: 'Monthly',
        features: <String>[
          'Everything in Growth',
          'Admin controls',
          'Priority support and future add-ons',
        ],
      ),
    ];
  }

  Future<String> createSubscriptionRequest({
    required String dairyId,
    required String userId,
    required String userEmail,
    required SubscriptionPlanModel plan,
  }) async {
    final String requestId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
    final Map<String, dynamic> payload = <String, dynamic>{
      'id': requestId,
      'dairyId': dairyId,
      'userId': userId,
      'userEmail': userEmail,
      'planId': plan.id,
      'planName': plan.name,
      'amount': plan.price,
      'billingLabel': plan.billingLabel,
      'status': 'pending',
      'platform': _platformLabel(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      await _firestore
          .collection('dairies')
          .doc(dairyId)
          .collection('subscription_requests')
          .doc(requestId)
          .set(<String, dynamic>{
        'userId': userId,
        'userEmail': userEmail,
        'planId': plan.id,
        'planName': plan.name,
        'amount': plan.price,
        'billingLabel': plan.billingLabel,
        'status': 'pending',
        'platform': _platformLabel(),
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (_) {
      await _offlineService.enqueuePendingOperation(
        operationType: 'subscription_request_add',
        recordId: requestId,
        payload: payload,
      );
    }

    return requestId;
  }

  bool get isWebCheckoutFallback => kIsWeb;
  bool get isMobileCheckoutSupported => !kIsWeb && _checkoutGateway.isSupported;
  bool get isRazorpayConfigured => AppConstants.razorpayKeyId.trim().isNotEmpty;

  Future<PaymentCheckoutResult> startSubscriptionCheckout({
    required String dairyId,
    required String userId,
    required String userEmail,
    required SubscriptionPlanModel plan,
  }) async {
    final String requestId = await createSubscriptionRequest(
      dairyId: dairyId,
      userId: userId,
      userEmail: userEmail,
      plan: plan,
    );

    if (!isMobileCheckoutSupported || !isRazorpayConfigured) {
      return PaymentCheckoutResult(
        status: 'request_only',
        message: 'Subscription request saved with id $requestId.',
      );
    }

    final PaymentCheckoutResult result =
        await _checkoutGateway.openSubscriptionCheckout(
      keyId: AppConstants.razorpayKeyId,
      requestId: requestId,
      userEmail: userEmail,
      plan: plan,
    );

    await _persistCheckoutResult(
      dairyId: dairyId,
      requestId: requestId,
      result: result,
    );
    return result;
  }

  String _platformLabel() {
    if (kIsWeb) {
      return 'web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'other';
    }
  }

  Future<void> _persistCheckoutResult({
    required String dairyId,
    required String requestId,
    required PaymentCheckoutResult result,
  }) async {
    final Map<String, dynamic> update = <String, dynamic>{
      'status': result.status,
      'statusMessage': result.message,
      'paymentId': result.paymentId,
      'signature': result.signature,
      'externalWallet': result.externalWallet,
      'errorCode': result.errorCode,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    try {
      await _firestore
          .collection('dairies')
          .doc(dairyId)
          .collection('subscription_requests')
          .doc(requestId)
          .update(<String, dynamic>{
        'status': result.status,
        'statusMessage': result.message,
        'paymentId': result.paymentId,
        'signature': result.signature,
        'externalWallet': result.externalWallet,
        'errorCode': result.errorCode,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (_) {
      await _offlineService.enqueuePendingOperation(
        operationType: 'subscription_request_update',
        recordId: requestId,
        payload: <String, dynamic>{
          'id': requestId,
          'dairyId': dairyId,
          ...update,
        },
      );
    }
  }

  void dispose() {
    _checkoutGateway.dispose();
  }
}
