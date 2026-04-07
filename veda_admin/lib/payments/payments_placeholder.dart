import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<Map<String, String>> requests = <Map<String, String>>[
      <String, String>{
        'plan': 'Growth',
        'amount': 'Rs 999',
        'status': 'Pending',
      },
      <String, String>{
        'plan': 'Starter',
        'amount': 'Rs 499',
        'status': 'Pending',
      },
      <String, String>{
        'plan': 'Premium',
        'amount': 'Rs 1499',
        'status': 'Success',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: requests
          .map(
            (Map<String, String> request) => Card(
              child: ListTile(
                title: Text(request['plan'] ?? ''),
                subtitle: Text(request['amount'] ?? ''),
                trailing: Chip(
                  label: Text(request['status'] ?? ''),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
