class DairyCalculations {
  static double calculateMilkRate({
    required double fat,
    required double snf,
    required String cattleType,
  }) {
    final double baseRate = cattleType == 'Buffalo' ? 42 : 34;
    return baseRate + (fat * 1.8) + (snf * 0.35);
  }

  static double calculateAmount({
    required double liters,
    required double rate,
  }) {
    return liters * rate;
  }

  static double calculateAverage({
    required List<double> values,
  }) {
    if (values.isEmpty) {
      return 0;
    }
    final double total = values.reduce((double a, double b) => a + b);
    return total / values.length;
  }
}
