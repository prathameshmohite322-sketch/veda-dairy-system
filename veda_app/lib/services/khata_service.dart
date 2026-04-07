import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/khata_entry_model.dart';

class KhataService {
  KhataService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _khataRef(String dairyId) {
    return _firestore.collection('dairies').doc(dairyId).collection('khata_entries');
  }

  Future<List<KhataEntryModel>> fetchEntries({
    required String dairyId,
    required String customerId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _khataRef(dairyId)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      return KhataEntryModel(
        id: doc.id,
        dairyId: dairyId,
        customerId: (data['customerId'] as String?) ?? '',
        type: (data['type'] as String?) ?? '',
        amount: ((data['amount'] as num?) ?? 0).toDouble(),
        note: (data['note'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> addEntry(KhataEntryModel entry) async {
    await _khataRef(entry.dairyId).doc(entry.id).set(<String, dynamic>{
      'customerId': entry.customerId,
      'type': entry.type,
      'amount': entry.amount,
      'note': entry.note,
      'createdAt': Timestamp.fromDate(entry.createdAt),
    });
  }
}
