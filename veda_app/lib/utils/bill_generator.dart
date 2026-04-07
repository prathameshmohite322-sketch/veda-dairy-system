class BillGenerator {
  String buildBillReference(String customerId, String cycle) {
    return '$customerId-$cycle';
  }
}
