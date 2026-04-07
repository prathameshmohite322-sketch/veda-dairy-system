import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const <Widget>[
        _SummaryCard(
          title: 'Total Dairies',
          value: '12',
          subtitle: 'Connected dairy accounts',
        ),
        SizedBox(height: 12),
        _SummaryCard(
          title: 'Active Staff',
          value: '28',
          subtitle: 'Users active in the last 7 days',
        ),
        SizedBox(height: 12),
        _SummaryCard(
          title: 'Pending Payments',
          value: '6',
          subtitle: 'Subscription requests waiting for review',
        ),
        SizedBox(height: 12),
        _SummaryCard(
          title: 'Platform Health',
          value: 'Stable',
          subtitle: 'Core systems running normally',
        ),
      ],
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
