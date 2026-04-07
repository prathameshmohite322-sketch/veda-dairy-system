import 'package:hive_flutter/hive_flutter.dart';

class OfflineService {
  static const String customersBoxName = 'customers_cache';
  static const String milkEntriesBoxName = 'milk_entries_cache';
  static const String khataEntriesBoxName = 'khata_entries_cache';
  static const String factorySalesBoxName = 'factory_sales_cache';
  static const String pendingSyncBoxName = 'pending_sync_queue';

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait(<Future<void>>[
      Hive.openBox<List<dynamic>>(customersBoxName),
      Hive.openBox<List<dynamic>>(milkEntriesBoxName),
      Hive.openBox<List<dynamic>>(khataEntriesBoxName),
      Hive.openBox<List<dynamic>>(factorySalesBoxName),
      Hive.openBox<List<dynamic>>(pendingSyncBoxName),
    ]);
  }

  Future<void> writeList({
    required String boxName,
    required String key,
    required List<Map<String, dynamic>> items,
  }) async {
    final Box<List<dynamic>> box = Hive.box<List<dynamic>>(boxName);
    await box.put(key, items);
  }

  List<Map<String, dynamic>> readList({
    required String boxName,
    required String key,
  }) {
    final Box<List<dynamic>> box = Hive.box<List<dynamic>>(boxName);
    final List<dynamic>? raw = box.get(key);
    if (raw == null) {
      return <Map<String, dynamic>>[];
    }
    return raw
        .map((dynamic item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> enqueuePendingOperation({
    required String operationType,
    required String recordId,
    required Map<String, dynamic> payload,
  }) async {
    final List<Map<String, dynamic>> queue = readPendingOperations();
    final bool alreadyQueued = queue.any(
      (Map<String, dynamic> item) =>
          item['operationType'] == operationType &&
          item['recordId'] == recordId,
    );
    if (alreadyQueued) {
      return;
    }

    queue.add(<String, dynamic>{
      'id': '${DateTime.now().millisecondsSinceEpoch}_$recordId',
      'operationType': operationType,
      'recordId': recordId,
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await writeList(
      boxName: pendingSyncBoxName,
      key: 'queue',
      items: queue,
    );
  }

  List<Map<String, dynamic>> readPendingOperations() {
    return readList(
      boxName: pendingSyncBoxName,
      key: 'queue',
    );
  }

  Future<void> removePendingOperation(String operationId) async {
    final List<Map<String, dynamic>> queue = readPendingOperations()
      ..removeWhere((Map<String, dynamic> item) => item['id'] == operationId);
    await writeList(
      boxName: pendingSyncBoxName,
      key: 'queue',
      items: queue,
    );
  }
}
