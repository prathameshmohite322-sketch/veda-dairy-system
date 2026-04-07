import 'package:cloud_firestore/cloud_firestore.dart';

import 'customer_service.dart';
import 'offline_service.dart';

class SyncService {
  SyncService({
    FirebaseFirestore? firestore,
    OfflineService? offlineService,
    CustomerService? customerService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _offlineService = offlineService ?? OfflineService(),
        _customerService = customerService ??
            CustomerService(
              firestore: firestore,
              offlineService: offlineService,
            );

  final FirebaseFirestore _firestore;
  final OfflineService _offlineService;
  final CustomerService _customerService;
  bool _isSyncing = false;

  Future<void> syncPendingRecords() async {
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;
    final List<Map<String, dynamic>> queue =
        _offlineService.readPendingOperations();
    try {
      for (final Map<String, dynamic> operation in queue) {
        try {
          await _syncOperation(operation);
          await _offlineService
              .removePendingOperation(operation['id'] as String);
        } catch (_) {
          continue;
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncOperation(Map<String, dynamic> operation) async {
    final String type = operation['operationType'] as String? ?? '';
    final Map<String, dynamic> payload = Map<String, dynamic>.from(
        operation['payload'] as Map? ?? <String, dynamic>{});

    switch (type) {
      case 'customer_add':
        await _firestore
            .collection('dairies')
            .doc(payload['dairyId'] as String)
            .collection('customers')
            .doc(payload['id'] as String)
            .set(<String, dynamic>{
          'name': payload['name'],
          'phone': payload['phone'],
          'village': payload['village'],
          'cattleType': payload['cattleType'],
          'totalAdvance': payload['totalAdvance'],
          'usedAdvance': payload['usedAdvance'],
          'isActive': payload['isActive'],
          'createdAt': _timestampFrom(payload['createdAt']),
        });
        break;
      case 'milk_entry_add':
        await _firestore
            .collection('dairies')
            .doc(payload['dairyId'] as String)
            .collection('milk_entries')
            .doc(payload['id'] as String)
            .set(<String, dynamic>{
          'customerId': payload['customerId'],
          'customerName': payload['customerName'],
          'shift': payload['shift'],
          'cattleType': payload['cattleType'],
          'liters': payload['liters'],
          'fat': payload['fat'],
          'snf': payload['snf'],
          'rate': payload['rate'],
          'amount': payload['amount'],
          'createdAt': _timestampFrom(payload['createdAt']),
        });
        break;
      case 'khata_entry_add':
        await _firestore
            .collection('dairies')
            .doc(payload['dairyId'] as String)
            .collection('khata_entries')
            .doc(payload['id'] as String)
            .set(<String, dynamic>{
          'customerId': payload['customerId'],
          'type': payload['type'],
          'amount': payload['amount'],
          'note': payload['note'],
          'createdAt': _timestampFrom(payload['createdAt']),
        });
        await _customerService.updateAdvanceSummary(
          dairyId: payload['dairyId'] as String,
          customerId: payload['customerId'] as String,
          totalAdvance: await _sumKhataType(
            dairyId: payload['dairyId'] as String,
            customerId: payload['customerId'] as String,
            includeTypes: const <String>['advance'],
          ),
          usedAdvance: await _sumKhataType(
            dairyId: payload['dairyId'] as String,
            customerId: payload['customerId'] as String,
            includeTypes: const <String>['feed', 'deduction'],
          ),
        );
        break;
      case 'factory_sale_add':
        await _firestore
            .collection('dairies')
            .doc(payload['dairyId'] as String)
            .collection('factory_sales')
            .doc(payload['id'] as String)
            .set(<String, dynamic>{
          'factoryName': payload['factoryName'],
          'liters': payload['liters'],
          'saleRate': payload['saleRate'],
          'commissionPerLiter': payload['commissionPerLiter'],
          'totalAmount': payload['totalAmount'],
          'commissionAmount': payload['commissionAmount'],
          'netProfit': payload['netProfit'],
          'note': payload['note'],
          'createdAt': _timestampFrom(payload['createdAt']),
        });
        break;
      case 'subscription_request_add':
        await _firestore
            .collection('dairies')
            .doc(payload['dairyId'] as String)
            .collection('subscription_requests')
            .doc(payload['id'] as String)
            .set(<String, dynamic>{
          'userId': payload['userId'],
          'userEmail': payload['userEmail'],
          'planId': payload['planId'],
          'planName': payload['planName'],
          'amount': payload['amount'],
          'billingLabel': payload['billingLabel'],
          'status': payload['status'],
          'platform': payload['platform'],
          'createdAt': _timestampFrom(payload['createdAt']),
        });
        break;
      default:
        break;
    }
  }

  Future<double> _sumKhataType({
    required String dairyId,
    required String customerId,
    required List<String> includeTypes,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('dairies')
        .doc(dairyId)
        .collection('khata_entries')
        .where('customerId', isEqualTo: customerId)
        .get();
    return snapshot.docs.fold<double>(
      0,
      (double sum, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = doc.data();
        final String type = (data['type'] as String?) ?? '';
        if (!includeTypes.contains(type)) {
          return sum;
        }
        return sum + ((data['amount'] as num?)?.toDouble() ?? 0);
      },
    );
  }

  Timestamp _timestampFrom(Object? raw) {
    if (raw is Timestamp) {
      return raw;
    }
    return Timestamp.fromDate(
      DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
