import 'billing_summary_model.dart';
import 'khata_entry_model.dart';
import 'milk_entry_model.dart';

class BillingDetailModel {
  const BillingDetailModel({
    required this.summary,
    required this.entries,
    required this.khataEntries,
    required this.feedAmount,
    required this.depositAmount,
    required this.advanceAmount,
    required this.deductionAmount,
    required this.finalPayableAmount,
  });

  final BillingSummaryModel summary;
  final List<MilkEntryModel> entries;
  final List<KhataEntryModel> khataEntries;
  final double feedAmount;
  final double depositAmount;
  final double advanceAmount;
  final double deductionAmount;
  final double finalPayableAmount;
}
