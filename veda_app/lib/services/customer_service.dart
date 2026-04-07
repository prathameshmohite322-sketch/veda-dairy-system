import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';

class CustomerService {
  CustomerService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _customersRef(String dairyId) {
    return _firestore.collection('dairies').doc(dairyId).collection('customers');
  }

  Future<List<CustomerModel>> fetchCustomers(String dairyId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _customersRef(dairyId).orderBy('name').get();
    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      return CustomerModel(
        id: doc.id,
        dairyId: dairyId,
        name: (data['name'] as String?) ?? '',
        phone: (data['phone'] as String?) ?? '',
        village: (data['village'] as String?) ?? '',
        cattleType: (data['cattleType'] as String?) ?? 'Cow',
        totalAdvance: ((data['totalAdvance'] as num?) ?? 0).toDouble(),
        usedAdvance: ((data['usedAdvance'] as num?) ?? 0).toDouble(),
        isActive: (data['isActive'] as bool?) ?? true,
      );
    }).toList();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _customersRef(customer.dairyId).doc(customer.id).set(<String, dynamic>{
      'name': customer.name,
      'phone': customer.phone,
      'village': customer.village,
      'cattleType': customer.cattleType,
      'totalAdvance': customer.totalAdvance,
      'usedAdvance': customer.usedAdvance,
      'isActive': customer.isActive,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<CustomerModel?> findCustomerById(String customerId) async {
    final Query<Map<String, dynamic>> query = _firestore.collectionGroup('customers');
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await query.where(FieldPath.documentId, isEqualTo: customerId).limit(1).get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    final QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs.first;
    final Map<String, dynamic> data = doc.data();
    final String dairyId = doc.reference.parent.parent?.id ?? '';
    return CustomerModel(
      id: doc.id,
      dairyId: dairyId,
      name: (data['name'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      village: (data['village'] as String?) ?? '',
      cattleType: (data['cattleType'] as String?) ?? 'Cow',
      totalAdvance: ((data['totalAdvance'] as num?) ?? 0).toDouble(),
      usedAdvance: ((data['usedAdvance'] as num?) ?? 0).toDouble(),
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  Future<void> updateAdvanceSummary({
    required String dairyId,
    required String customerId,
    required double totalAdvance,
    required double usedAdvance,
  }) async {
    await _customersRef(dairyId).doc(customerId).update(<String, dynamic>{
      'totalAdvance': totalAdvance,
      'usedAdvance': usedAdvance,
    });
  }
}
