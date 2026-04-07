import 'package:flutter/material.dart';

import '../models/admin_payment_request.dart';
import '../services/admin_service.dart';
import '../widgets/admin_error_view.dart';

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
  String _selectedStatus = 'all';
  String _selectedPlatform = 'all';

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
        if (snapshot.hasError) {
          return AdminErrorView(
            title: 'Payments Load Failed',
            error: snapshot.error!,
            onRetry: _reload,
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<AdminPaymentRequest> allRequests = snapshot.data!;
        if (allRequests.isEmpty) {
          return const Center(child: Text('No subscription requests found.'));
        }

        final List<String> platformOptions = <String>{
          'all',
          ...allRequests.map((AdminPaymentRequest request) => request.platform),
        }.toList()
          ..sort();

        final List<AdminPaymentRequest> requests =
            allRequests.where((AdminPaymentRequest request) {
          final bool matchesStatus =
              _selectedStatus == 'all' || request.status == _selectedStatus;
          final bool matchesPlatform = _selectedPlatform == 'all' ||
              request.platform == _selectedPlatform;
          return matchesStatus && matchesPlatform;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status filter',
                      border: OutlineInputBorder(),
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                          value: 'all', child: Text('All statuses')),
                      DropdownMenuItem<String>(
                          value: 'pending', child: Text('Pending')),
                      DropdownMenuItem<String>(
                          value: 'approved', child: Text('Approved')),
                      DropdownMenuItem<String>(
                          value: 'rejected', child: Text('Rejected')),
                      DropdownMenuItem<String>(
                          value: 'success', child: Text('Success')),
                      DropdownMenuItem<String>(
                          value: 'failed', child: Text('Failed')),
                    ],
                    onChanged: (String? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPlatform,
                    decoration: const InputDecoration(
                      labelText: 'Platform filter',
                      border: OutlineInputBorder(),
                    ),
                    items: platformOptions
                        .map(
                          (String platform) => DropdownMenuItem<String>(
                            value: platform,
                            child: Text(
                              platform == 'all' ? 'All platforms' : platform,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedPlatform = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (requests.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child:
                      Text('No payment requests match the selected filters.'),
                ),
              ),
            ...requests.map(
              (AdminPaymentRequest request) => Card(
                child: ListTile(
                  title: Text('${request.planName} | ${request.userEmail}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${request.dairyId} | Rs ${request.amount.toStringAsFixed(0)}',
                      ),
                      if (request.statusMessage.trim().isNotEmpty)
                        Text(
                          request.statusMessage,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: _StatusChip(
                    status: request.status,
                    platform: request.platform,
                  ),
                  onTap: () => _openReviewDialog(request),
                ),
              ),
            ),
          ],
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
              Text('Platform: ${request.platform}'),
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
              onPressed: request.status == 'rejected'
                  ? null
                  : () => Navigator.of(context).pop('rejected'),
              child: const Text('Reject'),
            ),
            TextButton(
              onPressed: request.status == 'pending'
                  ? null
                  : () => Navigator.of(context).pop('pending'),
              child: const Text('Mark Pending'),
            ),
            FilledButton(
              onPressed: request.status == 'approved'
                  ? null
                  : () => Navigator.of(context).pop('approved'),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (reviewStatus == null || reviewStatus == request.status) {
      return;
    }

    await widget.adminService.reviewPaymentRequest(
      request: request,
      reviewStatus: reviewStatus,
    );
    await _reload();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.platform,
  });

  final String status;
  final String platform;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      'pending' => Colors.orange,
      'approved' => Colors.blue,
      'rejected' => Colors.red,
      'success' => Colors.green,
      'failed' => Colors.redAccent,
      _ => Colors.grey,
    };

    return Chip(
      label: Text('$status ($platform)'),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
    );
  }
}
