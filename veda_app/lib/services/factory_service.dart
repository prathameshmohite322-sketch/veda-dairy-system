import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/factory_sale_model.dart';
import 'offline_service.dart';

class FactoryService {
  FactoryService({
    FirebaseFirestore? firestore,
    OfflineService? offlineService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _offlineService = offlineService ?? OfflineService();

  final FirebaseFirestore _firestore;
  final OfflineService _offlineService;

  CollectionReference<Map<String, dynamic>> _salesRef(String dairyId) {
    return _firestore
        .collection('dairies')
        .doc(dairyId)
        .collection('factory_sales');
  }

  Future<List<FactorySaleModel>> fetchSales(String dairyId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _salesRef(dairyId).orderBy('createdAt', descending: true).get();
      final List<FactorySaleModel> sales =
          snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return _fromMap(
          id: doc.id,
          dairyId: dairyId,
          data: doc.data(),
        );
      }).toList();

      await _offlineService.writeList(
        boxName: OfflineService.factorySalesBoxName,
        key: dairyId,
        items: sales.map(_toMap).toList(),
      );
      return sales;
    } catch (_) {
      final List<Map<String, dynamic>> cached = _offlineService.readList(
        boxName: OfflineService.factorySalesBoxName,
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

  Future<FactorySaleModel> addSale({
    required String dairyId,
    required String factoryName,
    required double liters,
    required double saleRate,
    required double commissionPerLiter,
    required String note,
  }) async {
    final String saleId = 'f_${DateTime.now().millisecondsSinceEpoch}';
    final double totalAmount = liters * saleRate;
    final double commissionAmount = liters * commissionPerLiter;
    final FactorySaleModel sale = FactorySaleModel(
      id: saleId,
      dairyId: dairyId,
      factoryName: factoryName,
      liters: liters,
      saleRate: saleRate,
      commissionPerLiter: commissionPerLiter,
      totalAmount: totalAmount,
      commissionAmount: commissionAmount,
      netProfit: totalAmount - commissionAmount,
      note: note,
      createdAt: DateTime.now(),
    );

    try {
      await _salesRef(dairyId).doc(sale.id).set(<String, dynamic>{
        'factoryName': sale.factoryName,
        'liters': sale.liters,
        'saleRate': sale.saleRate,
        'commissionPerLiter': sale.commissionPerLiter,
        'totalAmount': sale.totalAmount,
        'commissionAmount': sale.commissionAmount,
        'netProfit': sale.netProfit,
        'note': sale.note,
        'createdAt': Timestamp.fromDate(sale.createdAt),
      });
    } catch (_) {
      await _offlineService.enqueuePendingOperation(
        operationType: 'factory_sale_add',
        recordId: sale.id,
        payload: _toMap(sale),
      );
    }

    final List<FactorySaleModel> cachedSales =
        await _readCachedOrRemoteSales(dairyId);
    if (cachedSales.every((FactorySaleModel item) => item.id != sale.id)) {
      cachedSales.insert(0, sale);
      await _offlineService.writeList(
        boxName: OfflineService.factorySalesBoxName,
        key: dairyId,
        items: cachedSales.map(_toMap).toList(),
      );
    }

    return sale;
  }

  Future<List<FactorySaleModel>> _readCachedOrRemoteSales(
      String dairyId) async {
    final List<Map<String, dynamic>> cached = _offlineService.readList(
      boxName: OfflineService.factorySalesBoxName,
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
    return fetchSales(dairyId);
  }

  FactorySaleModel _fromMap({
    required String id,
    required String dairyId,
    required Map<String, dynamic> data,
  }) {
    final Object? createdAt = data['createdAt'];
    return FactorySaleModel(
      id: id,
      dairyId: dairyId,
      factoryName: (data['factoryName'] as String?) ?? '',
      liters: ((data['liters'] as num?) ?? 0).toDouble(),
      saleRate: ((data['saleRate'] as num?) ?? 0).toDouble(),
      commissionPerLiter:
          ((data['commissionPerLiter'] as num?) ?? 0).toDouble(),
      totalAmount: ((data['totalAmount'] as num?) ?? 0).toDouble(),
      commissionAmount: ((data['commissionAmount'] as num?) ?? 0).toDouble(),
      netProfit: ((data['netProfit'] as num?) ?? 0).toDouble(),
      note: (data['note'] as String?) ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _toMap(FactorySaleModel sale) {
    return <String, dynamic>{
      'id': sale.id,
      'dairyId': sale.dairyId,
      'factoryName': sale.factoryName,
      'liters': sale.liters,
      'saleRate': sale.saleRate,
      'commissionPerLiter': sale.commissionPerLiter,
      'totalAmount': sale.totalAmount,
      'commissionAmount': sale.commissionAmount,
      'netProfit': sale.netProfit,
      'note': sale.note,
      'createdAt': sale.createdAt.toIso8601String(),
    };
  }
}
