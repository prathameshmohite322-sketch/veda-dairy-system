import '../models/khata_entry_model.dart';

class KhataService {
  final List<KhataEntryModel> _entries = <KhataEntryModel>[
    KhataEntryModel(
      id: 'k1',
      dairyId: 'dairy_veda_001',
      customerId: 'c1',
      type: 'deposit',
      amount: 2500,
      note: 'Cash deposit against balance',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    KhataEntryModel(
      id: 'k2',
      dairyId: 'dairy_veda_001',
      customerId: 'c1',
      type: 'feed',
      amount: 1800,
      note: 'Cattle feed bags issued',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    KhataEntryModel(
      id: 'k3',
      dairyId: 'dairy_veda_001',
      customerId: 'c2',
      type: 'advance',
      amount: 4000,
      note: 'Emergency advance approved by owner',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    KhataEntryModel(
      id: 'k4',
      dairyId: 'dairy_veda_001',
      customerId: 'c2',
      type: 'deduction',
      amount: 1500,
      note: 'Manual deduction for 10-day cycle',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    KhataEntryModel(
      id: 'k5',
      dairyId: 'dairy_veda_001',
      customerId: 'c3',
      type: 'deposit',
      amount: 1200,
      note: 'UPI deposit',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  Future<List<KhataEntryModel>> fetchEntries({
    required String dairyId,
    required String customerId,
  }) async {
    final List<KhataEntryModel> items = _entries.where((KhataEntryModel entry) {
      return entry.dairyId == dairyId && entry.customerId == customerId;
    }).toList();
    items.sort(
      (KhataEntryModel a, KhataEntryModel b) => b.createdAt.compareTo(a.createdAt),
    );
    return items;
  }

  Future<void> addEntry(KhataEntryModel entry) async {
    _entries.insert(0, entry);
  }
}
