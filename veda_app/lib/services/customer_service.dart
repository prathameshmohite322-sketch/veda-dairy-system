import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';
import 'offline_service.dart';

class CustomerService {
  CustomerService({
    FirebaseFirestore? firestore,
    OfflineService? offlineService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _offlineService = offlineService ?? OfflineService();

  final FirebaseFirestore _firestore;
  final OfflineService _offlineService;

  CollectionReference<Map<String, dynamic>> _customersRef(String dairyId) {
    return _firestore
        .collection('dairies')
        .doc(dairyId)
        .collection('customers');
  }

  Future<List<CustomerModel>> fetchCustomers(String dairyId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _customersRef(dairyId).orderBy('name').get();
      final List<CustomerModel> customers =
          snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return _fromMap(
          id: doc.id,
          dairyId: dairyId,
          data: doc.data(),
        );
      }).toList();

      await _offlineService.writeList(
        boxName: OfflineService.customersBoxName,
        key: dairyId,
        items: customers.map(_toMap).toList(),
      );
      return customers;
    } catch (_) {
      final List<Map<String, dynamic>> cached = _offlineService.readList(
        boxName: OfflineService.customersBoxName,
        key: dairyId,
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

  Future<void> addCustomer(CustomerModel customer) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'id': customer.id,
      'dairyId': customer.dairyId,
      'name': customer.name,
      'phone': customer.phone,
      'village': customer.village,
      'cattleType': customer.cattleType,
      'totalAdvance': customer.totalAdvance,
      'usedAdvance': customer.usedAdvance,
      'isActive': customer.isActive,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      await _customersRef(customer.dairyId)
          .doc(customer.id)
          .set(<String, dynamic>{
        'name': customer.name,
        'phone': customer.phone,
        'village': customer.village,
        'cattleType': customer.cattleType,
        'totalAdvance': customer.totalAdvance,
        'usedAdvance': customer.usedAdvance,
        'isActive': customer.isActive,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await _offlineService.enqueuePendingOperation(
        operationType: 'customer_add',
        recordId: customer.id,
        payload: payload,
      );
    }

    final List<CustomerModel> cachedCustomers =
        await _readCachedOrRemoteCustomers(customer.dairyId);
    if (cachedCustomers.every((CustomerModel item) => item.id != customer.id)) {
      cachedCustomers.add(customer);
      cachedCustomers.sort(
        (CustomerModel a, CustomerModel b) => a.name.compareTo(b.name),
      );
      await _offlineService.writeList(
        boxName: OfflineService.customersBoxName,
        key: customer.dairyId,
        items: cachedCustomers.map(_toMap).toList(),
      );
    }
  }

  Future<CustomerModel?> findCustomerById(String customerId) async {
    final Query<Map<String, dynamic>> query =
        _firestore.collectionGroup('customers');
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query
        .where(FieldPath.documentId, isEqualTo: customerId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    final QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs.first;
    final Map<String, dynamic> data = doc.data();
    final String dairyId = doc.reference.parent.parent?.id ?? '';
    return _fromMap(
      id: doc.id,
      dairyId: dairyId,
      data: data,
    );
  }

  Future<void> updateAdvanceSummary({
    required String dairyId,
    required String customerId,
    required double totalAdvance,
    required double usedAdvance,
  }) async {
    final List<CustomerModel> customers =
        await _readCachedOrRemoteCustomers(dairyId);
    final List<CustomerModel> updatedCustomers = customers
        .map((CustomerModel customer) => customer.id != customerId
            ? customer
            : CustomerModel(
                id: customer.id,
                dairyId: customer.dairyId,
                name: customer.name,
                phone: customer.phone,
                village: customer.village,
                cattleType: customer.cattleType,
                totalAdvance: totalAdvance,
                usedAdvance: usedAdvance,
                isActive: customer.isActive,
              ))
        .toList();

    await _offlineService.writeList(
      boxName: OfflineService.customersBoxName,
      key: dairyId,
      items: updatedCustomers.map(_toMap).toList(),
    );

    try {
      await _customersRef(dairyId).doc(customerId).update(<String, dynamic>{
        'totalAdvance': totalAdvance,
        'usedAdvance': usedAdvance,
      });
    } catch (_) {
      return;
    }
  }

  Future<List<CustomerModel>> _readCachedOrRemoteCustomers(
      String dairyId) async {
    final List<Map<String, dynamic>> cached = _offlineService.readList(
      boxName: OfflineService.customersBoxName,
      key: dairyId,
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
    return fetchCustomers(dairyId);
  }

  CustomerModel _fromMap({
    required String id,
    required String dairyId,
    required Map<String, dynamic> data,
  }) {
    return CustomerModel(
      id: id,
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

  Map<String, dynamic> _toMap(CustomerModel customer) {
    return <String, dynamic>{
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
      'village': customer.village,
      'cattleType': customer.cattleType,
      'totalAdvance': customer.totalAdvance,
      'usedAdvance': customer.usedAdvance,
      'isActive': customer.isActive,
    };
  }
}
