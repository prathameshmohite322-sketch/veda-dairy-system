import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/subscription_plan_model.dart';
import 'offline_service.dart';

class PaymentService {
  PaymentService({
    FirebaseFirestore? firestore,
    OfflineService? offlineService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _offlineService = offlineService ?? OfflineService();

  final FirebaseFirestore _firestore;
  final OfflineService _offlineService;

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
}
