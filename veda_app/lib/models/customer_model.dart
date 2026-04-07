class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.dairyId,
    required this.name,
    required this.phone,
    required this.village,
    required this.cattleType,
    required this.totalAdvance,
    required this.usedAdvance,
    required this.isActive,
  });

  final String id;
  final String dairyId;
  final String name;
  final String phone;
  final String village;
  final String cattleType;
  final double totalAdvance;
  final double usedAdvance;
  final bool isActive;
}
