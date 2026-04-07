import 'package:flutter/material.dart';

import '../models/admin_payment_request.dart';
import '../services/admin_service.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({
    super.key,
    required this.adminService,
  });

  final AdminService adminService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminPaymentRequest>>(
      future: adminService.fetchPaymentRequests(),
      builder: (BuildContext context,
          AsyncSnapshot<List<AdminPaymentRequest>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<AdminPaymentRequest> requests = snapshot.data!;
        if (requests.isEmpty) {
          return const Center(child: Text('No subscription requests found.'));
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: requests
              .map(
                (AdminPaymentRequest request) => Card(
                  child: ListTile(
                    title: Text('${request.planName} | ${request.userEmail}'),
                    subtitle: Text(
                        '${request.dairyId} | Rs ${request.amount.toStringAsFixed(0)}'),
                    trailing: Chip(
                      label: Text('${request.status} (${request.platform})'),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
