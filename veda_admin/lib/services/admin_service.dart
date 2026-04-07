import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_dashboard_summary.dart';
import '../models/admin_dairy_summary.dart';
import '../models/admin_payment_request.dart';
import '../models/admin_reports_summary.dart';
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
        statusMessage: (data['statusMessage'] as String?) ?? '',
      );
    }).toList();

    requests.sort((AdminPaymentRequest a, AdminPaymentRequest b) =>
        a.status.compareTo(b.status));
    return requests;
  }

  Future<void> reviewPaymentRequest({
    required AdminPaymentRequest request,
    required String reviewStatus,
  }) async {
    await _firestore
        .collection('dairies')
        .doc(request.dairyId)
        .collection('subscription_requests')
        .doc(request.id)
        .update(<String, dynamic>{
      'status': reviewStatus,
      'statusMessage': 'Reviewed by admin',
      'reviewedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<AdminReportsSummary> loadReportsSummary() async {
    final List<AdminUserRecord> users = await fetchUsers();
    final List<AdminPaymentRequest> requests = await fetchPaymentRequests();
    final Set<String> dairyIds = <String>{
      ...users.map((AdminUserRecord user) => user.dairyId),
      ...requests.map((AdminPaymentRequest request) => request.dairyId),
    }..removeWhere((String dairyId) => dairyId.trim().isEmpty);

    final List<AdminDairySummary> dairies = dairyIds.map((String dairyId) {
      final int userCount =
          users.where((AdminUserRecord user) => user.dairyId == dairyId).length;
      final int pendingPayments = requests.where((AdminPaymentRequest request) {
        return request.dairyId == dairyId && request.status == 'pending';
      }).length;
      final int completedPayments =
          requests.where((AdminPaymentRequest request) {
        return request.dairyId == dairyId && request.status == 'success';
      }).length;

      return AdminDairySummary(
        dairyId: dairyId,
        userCount: userCount,
        pendingPayments: pendingPayments,
        completedPayments: completedPayments,
      );
    }).toList()
      ..sort(
        (AdminDairySummary a, AdminDairySummary b) =>
            a.dairyId.compareTo(b.dairyId),
      );

    return AdminReportsSummary(
      totalPending: requests
          .where((AdminPaymentRequest request) => request.status == 'pending')
          .length,
      totalApproved: requests
          .where((AdminPaymentRequest request) => request.status == 'approved')
          .length,
      totalRejected: requests
          .where((AdminPaymentRequest request) => request.status == 'rejected')
          .length,
      totalSuccess: requests
          .where((AdminPaymentRequest request) => request.status == 'success')
          .length,
      dairies: dairies,
    );
  }
}
