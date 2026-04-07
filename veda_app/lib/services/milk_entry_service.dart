import '../core/calculations.dart';
import '../models/customer_model.dart';
import '../models/milk_entry_model.dart';

class MilkEntryService {
  final List<MilkEntryModel> _entries = <MilkEntryModel>[
    MilkEntryModel(
      id: 'm1',
      dairyId: 'dairy_veda_001',
      customerId: 'c1',
      customerName: 'Amit Patil',
      shift: 'Morning',
      cattleType: 'Cow',
      liters: 12.6,
      fat: 4.2,
      snf: 8.4,
      rate: 44.22,
      amount: 557.17,
      createdAt: DateTime.now(),
    ),
    MilkEntryModel(
      id: 'm2',
      dairyId: 'dairy_veda_001',
      customerId: 'c2',
      customerName: 'Sunita Jadhav',
      shift: 'Evening',
      cattleType: 'Buffalo',
      liters: 9.4,
      fat: 6.8,
      snf: 9.1,
      rate: 57.75,
      amount: 542.85,
      createdAt: DateTime.now(),
    ),
  ];

  Future<List<MilkEntryModel>> fetchEntries(String dairyId) async {
    final List<MilkEntryModel> items = _entries
        .where((MilkEntryModel entry) => entry.dairyId == dairyId)
        .toList();
    items.sort(
      (MilkEntryModel a, MilkEntryModel b) => b.createdAt.compareTo(a.createdAt),
    );
    return items;
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
    final MilkEntryModel entry = MilkEntryModel(
      id: 'm${_entries.length + 1}',
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
    _entries.insert(0, entry);
    return entry;
  }
}
