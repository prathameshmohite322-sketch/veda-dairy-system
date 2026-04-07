class AccountCalculation {
  static double remainingAdvance({
    required double totalAdvance,
    required double usedAdvance,
  }) {
    return totalAdvance - usedAdvance;
  }
}
