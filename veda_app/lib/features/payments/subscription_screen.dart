import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../models/app_user.dart';
import '../../models/subscription_plan_model.dart';
import '../../services/payment_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({
    super.key,
    required this.user,
    required this.paymentService,
  });

  final AppUser user;
  final PaymentService paymentService;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _submitting = false;
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<SubscriptionPlanModel> plans =
        widget.paymentService.availablePlans();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('subscriptions')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            l10n.t('subscriptionIntro'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ...plans.map(
            (SubscriptionPlanModel plan) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            plan.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          'Rs ${plan.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(plan.billingLabel),
                    const SizedBox(height: 12),
                    ...plan.features.map(
                      (String feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('- $feature'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : () => _selectPlan(plan),
                        child: Text(
                          _selectedPlanId == plan.id && _submitting
                              ? l10n.t('saving')
                              : l10n.t('choosePlan'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.paymentService.isWebCheckoutFallback
                    ? l10n.t('webPaymentNote')
                    : l10n.t('mobilePaymentNote'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPlan(SubscriptionPlanModel plan) async {
    setState(() {
      _submitting = true;
      _selectedPlanId = plan.id;
    });

    final AppLocalizations l10n = AppLocalizations.of(context);
    final String requestId =
        await widget.paymentService.createSubscriptionRequest(
      dairyId: widget.user.dairyId,
      userId: widget.user.id,
      userEmail: widget.user.email,
      plan: plan,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.t('subscriptionRequestCreated', <String, String>{
            'requestId': requestId,
          }),
        ),
      ),
    );
  }
}
