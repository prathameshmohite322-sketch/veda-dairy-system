import 'package:flutter/material.dart';

import '../models/admin_dairy_summary.dart';
import '../models/admin_reports_summary.dart';
import '../services/admin_service.dart';
import '../widgets/admin_error_view.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({
    super.key,
    required this.adminService,
  });

  final AdminService adminService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminReportsSummary>(
      future: adminService.loadReportsSummary(),
      builder:
          (BuildContext context, AsyncSnapshot<AdminReportsSummary> snapshot) {
        if (snapshot.hasError) {
          return AdminErrorView(
            title: 'Reports Load Failed',
            error: snapshot.error!,
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final AdminReportsSummary summary = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _StatusCard(
                  title: 'Pending',
                  value: '${summary.totalPending}',
                  color: Colors.orange,
                ),
                _StatusCard(
                  title: 'Approved',
                  value: '${summary.totalApproved}',
                  color: Colors.blue,
                ),
                _StatusCard(
                  title: 'Rejected',
                  value: '${summary.totalRejected}',
                  color: Colors.red,
                ),
                _StatusCard(
                  title: 'Success',
                  value: '${summary.totalSuccess}',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Dairy Summaries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (summary.dairies.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No dairy summary data found.'),
                ),
              ),
            ...summary.dairies.map(
              (AdminDairySummary dairy) => Card(
                child: ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: Text(dairy.dairyId),
                  subtitle: Text(
                    'Users ${dairy.userCount} | Pending ${dairy.pendingPayments} | Success ${dairy.completedPayments}',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
