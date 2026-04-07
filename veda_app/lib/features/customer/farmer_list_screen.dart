import 'package:flutter/material.dart';

import '../../models/customer_model.dart';

class FarmerListScreen extends StatelessWidget {
  const FarmerListScreen({
    super.key,
    required this.customers,
  });

  final List<CustomerModel> customers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext context, int index) {
          final CustomerModel customer = customers[index];
          return Card(
            child: ListTile(
              title: Text(customer.name),
              subtitle: Text(
                '${customer.village} | ${customer.cattleType} | ${customer.phone}',
              ),
              trailing: customer.isActive
                  ? const Chip(label: Text('Active'))
                  : const Chip(label: Text('Inactive')),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: customers.length,
      ),
    );
  }
}
