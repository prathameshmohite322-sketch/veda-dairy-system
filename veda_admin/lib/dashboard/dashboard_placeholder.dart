import 'package:flutter/material.dart';

import '../models/admin_dashboard_summary.dart';
import '../services/admin_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.adminService,
  });

  final AdminService adminService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminDashboardSummary>(
      future: adminService.loadSummary(),
      builder: (BuildContext context,
          AsyncSnapshot<AdminDashboardSummary> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final AdminDashboardSummary summary = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _SummaryCard(
              title: 'Total Dairies',
              value: '${summary.totalDairies}',
              subtitle: 'Connected dairy accounts',
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              title: 'Total Users',
              value: '${summary.totalUsers}',
              subtitle: 'Owners, staff, and admins',
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              title: 'Pending Payments',
              value: '${summary.pendingSubscriptionRequests}',
              subtitle: 'Subscription requests waiting for review',
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              title: 'Completed Payments',
              value: '${summary.completedSubscriptionRequests}',
              subtitle: 'Requests marked as success',
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
