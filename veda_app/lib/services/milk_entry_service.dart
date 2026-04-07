import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/calculations.dart';
import '../models/billing_detail_model.dart';
import '../models/billing_summary_model.dart';
import '../models/khata_entry_model.dart';
import '../models/customer_model.dart';
import '../models/milk_entry_model.dart';

class MilkEntryService {
  MilkEntryService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _entriesRef(String dairyId) {
    return _firestore.collection('dairies').doc(dairyId).collection('milk_entries');
  }

  Future<List<MilkEntryModel>> fetchEntries(String dairyId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _entriesRef(dairyId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      return MilkEntryModel(
        id: doc.id,
        dairyId: dairyId,
        customerId: (data['customerId'] as String?) ?? '',
        customerName: (data['customerName'] as String?) ?? '',
        shift: (data['shift'] as String?) ?? 'Morning',
        cattleType: (data['cattleType'] as String?) ?? 'Cow',
        liters: ((data['liters'] as num?) ?? 0).toDouble(),
        fat: ((data['fat'] as num?) ?? 0).toDouble(),
        snf: ((data['snf'] as num?) ?? 0).toDouble(),
        rate: ((data['rate'] as num?) ?? 0).toDouble(),
        amount: ((data['amount'] as num?) ?? 0).toDouble(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<MilkEntryModel> addEntry({
    required String dairyId,
    required CustomerModel customer,
    required String shift,
    required double liters,
    required double fat,
    required double snf,
  }) async {
    final double rate = DairyCalculations.calculateMilkRate(
      fat: fat,
      snf: snf,
      cattleType: customer.cattleType,
    );
    final String entryId = 'm_${DateTime.now().millisecondsSinceEpoch}';
    final MilkEntryModel entry = MilkEntryModel(
      id: entryId,
      dairyId: dairyId,
      customerId: customer.id,
      customerName: customer.name,
      shift: shift,
      cattleType: customer.cattleType,
      liters: liters,
      fat: fat,
      snf: snf,
      rate: rate,
      amount: DairyCalculations.calculateAmount(liters: liters, rate: rate),
      createdAt: DateTime.now(),
    );
    await _entriesRef(dairyId).doc(entry.id).set(<String, dynamic>{
      'customerId': entry.customerId,
      'customerName': entry.customerName,
      'shift': entry.shift,
      'cattleType': entry.cattleType,
      'liters': entry.liters,
      'fat': entry.fat,
      'snf': entry.snf,
      'rate': entry.rate,
      'amount': entry.amount,
      'createdAt': Timestamp.fromDate(entry.createdAt),
    });
    return entry;
  }

  Future<List<BillingSummaryModel>> buildBillingSummaries(String dairyId) async {
    final List<MilkEntryModel> dairyEntries = await fetchEntries(dairyId);
    final Map<String, List<MilkEntryModel>> grouped = <String, List<MilkEntryModel>>{};

    for (final MilkEntryModel entry in dairyEntries) {
      grouped.putIfAbsent(entry.customerId, () => <MilkEntryModel>[]).add(entry);
    }

    final List<BillingSummaryModel> summaries = grouped.entries.map((MapEntry<String, List<MilkEntryModel>> item) {
      final List<MilkEntryModel> entries = item.value;
      final double liters = entries.fold(
        0,
        (double sum, MilkEntryModel entry) => sum + entry.liters,
      );
      final double amount = entries.fold(
        0,
        (double sum, MilkEntryModel entry) => sum + entry.amount,
      );
      final double avgFat = DairyCalculations.calculateAverage(
        values: entries.map((MilkEntryModel entry) => entry.fat).toList(),
      );
      final double avgSnf = DairyCalculations.calculateAverage(
        values: entries.map((MilkEntryModel entry) => entry.snf).toList(),
      );

      return BillingSummaryModel(
        customerId: item.key,
        customerName: entries.first.customerName,
        totalLiters: liters,
        averageFat: avgFat,
        averageSnf: avgSnf,
        totalAmount: amount,
        entryCount: entries.length,
      );
    }).toList();

    summaries.sort(
      (BillingSummaryModel a, BillingSummaryModel b) =>
          b.totalAmount.compareTo(a.totalAmount),
    );

    return summaries;
  }

  Future<BillingDetailModel?> buildBillingDetail({
    required String dairyId,
    required BillingSummaryModel summary,
    required List<KhataEntryModel> khataEntries,
  }) async {
    final List<MilkEntryModel> entries = (await fetchEntries(dairyId))
        .where((MilkEntryModel entry) => entry.customerId == summary.customerId)
        .toList();

    if (entries.isEmpty) {
      return null;
    }

    double sumByType(String type) {
      return khataEntries
          .where((KhataEntryModel entry) => entry.type == type)
          .fold(0, (double sum, KhataEntryModel entry) => sum + entry.amount);
    }

    final double depositAmount = sumByType('deposit');
    final double feedAmount = sumByType('feed');
    final double advanceAmount = sumByType('advance');
    final double deductionAmount = sumByType('deduction');
    final double finalPayableAmount = summary.totalAmount -
        feedAmount -
        advanceAmount -
        deductionAmount +
        depositAmount;

    return BillingDetailModel(
      summary: summary,
      entries: entries,
      khataEntries: khataEntries,
      feedAmount: feedAmount,
      depositAmount: depositAmount,
      advanceAmount: advanceAmount,
      deductionAmount: deductionAmount,
      finalPayableAmount: finalPayableAmount,
    );
  }
}
