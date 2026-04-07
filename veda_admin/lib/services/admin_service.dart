import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_dashboard_summary.dart';
import '../models/admin_payment_request.dart';
import '../models/admin_user_record.dart';

class AdminService {
  AdminService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<AdminDashboardSummary> loadSummary() async {
    final List<AdminUserRecord> users = await fetchUsers();
    final List<AdminPaymentRequest> requests = await fetchPaymentRequests();
    final Set<String> dairies = users
        .map((AdminUserRecord user) => user.dairyId)
        .toSet()
      ..removeWhere((String dairyId) => dairyId.trim().isEmpty);

    return AdminDashboardSummary(
      totalUsers: users.length,
      totalDairies: dairies.length,
      pendingSubscriptionRequests: requests
          .where((AdminPaymentRequest request) => request.status == 'pending')
          .length,
      completedSubscriptionRequests: requests
          .where((AdminPaymentRequest request) => request.status == 'success')
          .length,
    );
  }

  Future<List<AdminUserRecord>> fetchUsers() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').orderBy('name').get();

    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      return AdminUserRecord(
        id: doc.id,
        name: (data['name'] as String?) ?? '',
        email: (data['email'] as String?) ?? '',
        role: (data['role'] as String?) ?? '',
        dairyId: (data['dairyId'] as String?) ?? '',
      );
    }).toList();
  }

  Future<List<AdminPaymentRequest>> fetchPaymentRequests() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collectionGroup('subscription_requests').get();

    final List<AdminPaymentRequest> requests =
        snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      final String dairyId = doc.reference.parent.parent?.id ?? '';
      return AdminPaymentRequest(
        id: doc.id,
        dairyId: dairyId,
        userEmail: (data['userEmail'] as String?) ?? '',
        planName: (data['planName'] as String?) ?? '',
        amount: ((data['amount'] as num?) ?? 0).toDouble(),
        status: (data['status'] as String?) ?? 'pending',
        platform: (data['platform'] as String?) ?? 'unknown',
      );
    }).toList();

    requests.sort((AdminPaymentRequest a, AdminPaymentRequest b) =>
        a.status.compareTo(b.status));
    return requests;
  }
}
