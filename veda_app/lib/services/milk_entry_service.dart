import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/calculations.dart';
import '../models/billing_cycle_model.dart';
import '../models/billing_detail_model.dart';
import '../models/billing_summary_model.dart';
import '../models/dashboard_report_model.dart';
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
    final BillingCycleModel cycle = currentBillingCycle();
    return buildBillingSummariesForCycle(
      dairyId: dairyId,
      cycle: cycle,
    );
  }

  BillingCycleModel currentBillingCycle() {
    final DateTime now = DateTime.now();
    final int cycleStartDay = now.day <= 10 ? 1 : (now.day <= 20 ? 11 : 21);
    final DateTime startDate = DateTime(now.year, now.month, cycleStartDay);
    final DateTime endDate = cycleStartDay == 21
        ? DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1))
        : DateTime(now.year, now.month, cycleStartDay + 9);

    return BillingCycleModel(
      startDate: startDate,
      endDate: endDate,
      label: '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
    );
  }

  List<BillingCycleModel> recentBillingCycles({int count = 6}) {
    final DateTime now = DateTime.now();
    DateTime anchor = DateTime(now.year, now.month, now.day);
    final List<BillingCycleModel> cycles = <BillingCycleModel>[];

    while (cycles.length < count) {
      final BillingCycleModel cycle = _cycleForDate(anchor);
      if (cycles.every((BillingCycleModel existing) => existing.label != cycle.label)) {
        cycles.add(cycle);
      }
      anchor = cycle.startDate.subtract(const Duration(days: 1));
    }

    return cycles;
  }

  BillingCycleModel _cycleForDate(DateTime date) {
    final int cycleStartDay = date.day <= 10 ? 1 : (date.day <= 20 ? 11 : 21);
    final DateTime startDate = DateTime(date.year, date.month, cycleStartDay);
    final DateTime endDate = cycleStartDay == 21
        ? DateTime(date.year, date.month + 1, 1).subtract(const Duration(days: 1))
        : DateTime(date.year, date.month, cycleStartDay + 9);

    return BillingCycleModel(
      startDate: startDate,
      endDate: endDate,
      label: '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
    );
  }

  Future<List<BillingSummaryModel>> buildBillingSummariesForCycle({
    required String dairyId,
    required BillingCycleModel cycle,
  }) async {
    final List<MilkEntryModel> dairyEntries = (await fetchEntries(dairyId))
        .where((MilkEntryModel entry) => _isWithinCycle(entry.createdAt, cycle))
        .toList();
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
        cycleStart: cycle.startDate,
        cycleEnd: cycle.endDate,
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
        .where((MilkEntryModel entry) {
          return entry.customerId == summary.customerId &&
              !entry.createdAt.isBefore(summary.cycleStart) &&
              !entry.createdAt.isAfter(
                summary.cycleEnd.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)),
              );
        })
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

  Future<DashboardReportModel> buildDashboardReport({
    required String dairyId,
    required int activeFarmers,
    required double totalAdvanceOutstanding,
  }) async {
    final List<MilkEntryModel> entries = await fetchEntries(dairyId);
    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final BillingCycleModel cycle = currentBillingCycle();

    final List<MilkEntryModel> todayEntries = entries.where((MilkEntryModel entry) {
      return !entry.createdAt.isBefore(todayStart) && !entry.createdAt.isAfter(todayEnd);
    }).toList();

    final List<MilkEntryModel> cycleEntries = entries.where((MilkEntryModel entry) {
      return _isWithinCycle(entry.createdAt, cycle);
    }).toList();

    final double todayMilkLiters = todayEntries.fold(
      0,
      (double sum, MilkEntryModel entry) => sum + entry.liters,
    );
    final double todayMilkValue = todayEntries.fold(
      0,
      (double sum, MilkEntryModel entry) => sum + entry.amount,
    );
    final double currentCycleAmount = cycleEntries.fold(
      0,
      (double sum, MilkEntryModel entry) => sum + entry.amount,
    );
    final double currentCycleLiters = cycleEntries.fold(
      0,
      (double sum, MilkEntryModel entry) => sum + entry.liters,
    );

    return DashboardReportModel(
      todayMilkLiters: todayMilkLiters,
      todayMilkValue: todayMilkValue,
      currentCycleAmount: currentCycleAmount,
      currentCycleLiters: currentCycleLiters,
      activeFarmers: activeFarmers,
      totalAdvanceOutstanding: totalAdvanceOutstanding,
      recentEntryCount: entries.take(5).length,
    );
  }

  bool _isWithinCycle(DateTime date, BillingCycleModel cycle) {
    final DateTime cycleStart = DateTime(
      cycle.startDate.year,
      cycle.startDate.month,
      cycle.startDate.day,
    );
    final DateTime cycleEnd = DateTime(
      cycle.endDate.year,
      cycle.endDate.month,
      cycle.endDate.day,
      23,
      59,
      59,
      999,
    );
    return !date.isBefore(cycleStart) && !date.isAfter(cycleEnd);
  }
}
