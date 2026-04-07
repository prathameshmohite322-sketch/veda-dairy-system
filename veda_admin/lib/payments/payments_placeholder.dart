import 'package:flutter/material.dart';

import '../models/admin_payment_request.dart';
import '../services/admin_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({
    super.key,
    required this.adminService,
  });

  final AdminService adminService;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late Future<List<AdminPaymentRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = widget.adminService.fetchPaymentRequests();
  }

  Future<void> _reload() async {
    setState(() {
      _requestsFuture = widget.adminService.fetchPaymentRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminPaymentRequest>>(
      future: _requestsFuture,
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
                    onTap: () => _openReviewDialog(request),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<void> _openReviewDialog(AdminPaymentRequest request) async {
    final String? reviewStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Review Payment Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Plan: ${request.planName}'),
              Text('User: ${request.userEmail}'),
              Text('Amount: Rs ${request.amount.toStringAsFixed(0)}'),
              Text('Current status: ${request.status}'),
              if (request.statusMessage.trim().isNotEmpty)
                Text('Message: ${request.statusMessage}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('rejected'),
              child: const Text('Reject'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('approved'),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (reviewStatus == null) {
      return;
    }

    await widget.adminService.reviewPaymentRequest(
      request: request,
      reviewStatus: reviewStatus,
    );
    await _reload();
  }
}
