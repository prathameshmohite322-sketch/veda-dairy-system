import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> reports = <String>[
      'Milk collection trend',
      '10-day billing summary',
      'Khata outstanding analysis',
      'Factory commission report',
      'Subscription request report',
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: reports
          .map(
            (String report) => Card(
              child: ListTile(
                leading: const Icon(Icons.assessment_outlined),
                title: Text(report),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          )
          .toList(),
    );
  }
}
