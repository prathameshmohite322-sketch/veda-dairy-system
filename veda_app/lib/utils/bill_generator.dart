import '../models/billing_detail_model.dart';

class BillGenerator {
  String buildBillReference(String customerId, String cycle) {
    final String sanitizedCycle = cycle
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
    return '$customerId-$sanitizedCycle';
  }

  String buildFileName(BillingDetailModel bill, String cycle) {
    return '${buildBillReference(bill.summary.customerId, cycle)}.pdf';
  }

  List<List<String>> buildEntryRows(BillingDetailModel bill) {
    return bill.entries.map((entry) {
      return <String>[
        _dateLabel(entry.createdAt),
        entry.shift,
        entry.liters.toStringAsFixed(1),
        entry.fat.toStringAsFixed(1),
        entry.snf.toStringAsFixed(1),
        entry.rate.toStringAsFixed(2),
        entry.amount.toStringAsFixed(0),
      ];
    }).toList();
  }

  List<List<String>> buildKhataRows(BillingDetailModel bill) {
    return bill.khataEntries.map((entry) {
      return <String>[
        _dateLabel(entry.createdAt),
        _khataLabel(entry.type),
        entry.note,
        entry.amount.toStringAsFixed(0),
      ];
    }).toList();
  }

  String _dateLabel(DateTime value) {
    return '${value.day}/${value.month}/${value.year}';
  }

  String _khataLabel(String type) {
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'feed':
        return 'Feed';
      case 'advance':
        return 'Advance';
      case 'deduction':
        return 'Manual Deduction';
      default:
        return type;
    }
  }
}
