import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/khata_entry_model.dart';
import 'customer_service.dart';
import 'offline_service.dart';

class KhataService {
  KhataService({
    FirebaseFirestore? firestore,
    CustomerService? customerService,
    OfflineService? offlineService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _customerService =
            customerService ?? CustomerService(firestore: firestore),
        _offlineService = offlineService ?? OfflineService();

  final FirebaseFirestore _firestore;
  final CustomerService _customerService;
  final OfflineService _offlineService;

  CollectionReference<Map<String, dynamic>> _khataRef(String dairyId) {
    return _firestore
        .collection('dairies')
        .doc(dairyId)
        .collection('khata_entries');
  }

  Future<List<KhataEntryModel>> fetchEntries({
    required String dairyId,
    required String customerId,
  }) async {
    final String cacheKey = '$dairyId::$customerId';
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _khataRef(dairyId)
              .where('customerId', isEqualTo: customerId)
              .orderBy('createdAt', descending: true)
              .get();
      final List<KhataEntryModel> entries =
          snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return _fromMap(
          id: doc.id,
          dairyId: dairyId,
          data: doc.data(),
        );
      }).toList();

      await _offlineService.writeList(
        boxName: OfflineService.khataEntriesBoxName,
        key: cacheKey,
        items: entries.map(_toMap).toList(),
      );
      return entries;
    } catch (_) {
      final List<Map<String, dynamic>> cached = _offlineService.readList(
        boxName: OfflineService.khataEntriesBoxName,
        key: cacheKey,
      );
      return cached
          .map((Map<String, dynamic> item) => _fromMap(
                id: item['id'] as String? ?? '',
                dairyId: dairyId,
                data: item,
              ))
          .toList();
    }
  }

  Future<void> addEntry(KhataEntryModel entry) async {
    try {
      await _khataRef(entry.dairyId).doc(entry.id).set(<String, dynamic>{
        'customerId': entry.customerId,
        'type': entry.type,
        'amount': entry.amount,
        'note': entry.note,
        'createdAt': Timestamp.fromDate(entry.createdAt),
      });
    } catch (_) {
      await _offlineService.enqueuePendingOperation(
        operationType: 'khata_entry_add',
        recordId: entry.id,
        payload: _toMap(entry),
      );
    }
    final String cacheKey = '${entry.dairyId}::${entry.customerId}';
    final List<KhataEntryModel> cachedEntries =
        await _readCachedOrRemoteEntries(
      dairyId: entry.dairyId,
      customerId: entry.customerId,
    );
    if (cachedEntries.every((KhataEntryModel item) => item.id != entry.id)) {
      cachedEntries.insert(0, entry);
      await _offlineService.writeList(
        boxName: OfflineService.khataEntriesBoxName,
        key: cacheKey,
        items: cachedEntries.map(_toMap).toList(),
      );
    }
    await recalculateAdvanceSummary(
      dairyId: entry.dairyId,
      customerId: entry.customerId,
    );
  }

  Future<void> recalculateAdvanceSummary({
    required String dairyId,
    required String customerId,
  }) async {
    final List<KhataEntryModel> entries = await fetchEntries(
      dairyId: dairyId,
      customerId: customerId,
    );

    final double totalAdvance = entries
        .where((KhataEntryModel entry) => entry.type == 'advance')
        .fold(0, (double sum, KhataEntryModel entry) => sum + entry.amount);

    final double usedAdvance = entries.where((KhataEntryModel entry) {
      return entry.type == 'deduction' || entry.type == 'feed';
    }).fold(0, (double sum, KhataEntryModel entry) => sum + entry.amount);

    await _customerService.updateAdvanceSummary(
      dairyId: dairyId,
      customerId: customerId,
      totalAdvance: totalAdvance,
      usedAdvance: usedAdvance,
    );
  }

  KhataEntryModel _fromMap({
    required String id,
    required String dairyId,
    required Map<String, dynamic> data,
  }) {
    final Object? createdAt = data['createdAt'];
    return KhataEntryModel(
      id: id,
      dairyId: dairyId,
      customerId: (data['customerId'] as String?) ?? '',
      type: (data['type'] as String?) ?? '',
      amount: ((data['amount'] as num?) ?? 0).toDouble(),
      note: (data['note'] as String?) ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _toMap(KhataEntryModel entry) {
    return <String, dynamic>{
      'id': entry.id,
      'dairyId': entry.dairyId,
      'customerId': entry.customerId,
      'type': entry.type,
      'amount': entry.amount,
      'note': entry.note,
      'createdAt': entry.createdAt.toIso8601String(),
    };
  }

  Future<List<KhataEntryModel>> _readCachedOrRemoteEntries({
    required String dairyId,
    required String customerId,
  }) async {
    final List<Map<String, dynamic>> cached = _offlineService.readList(
      boxName: OfflineService.khataEntriesBoxName,
      key: '$dairyId::$customerId',
    );
    if (cached.isNotEmpty) {
      return cached
          .map((Map<String, dynamic> item) => _fromMap(
                id: item['id'] as String? ?? '',
                dairyId: dairyId,
                data: item,
              ))
          .toList();
    }
    return fetchEntries(dairyId: dairyId, customerId: customerId);
  }
}
