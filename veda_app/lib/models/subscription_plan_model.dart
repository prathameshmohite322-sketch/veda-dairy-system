class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.billingLabel,
    required this.features,
  });

  final String id;
  final String name;
  final double price;
  final String billingLabel;
  final List<String> features;
}
