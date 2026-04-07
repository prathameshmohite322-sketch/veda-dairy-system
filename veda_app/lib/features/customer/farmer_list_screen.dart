import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/khata_service.dart';
import 'farmer_detail_screen.dart';

class FarmerListScreen extends StatelessWidget {
  const FarmerListScreen({
    super.key,
    required this.customers,
    required this.khataService,
  });

  final List<CustomerModel> customers;
  final KhataService khataService;

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
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FarmerDetailScreen(
                      customer: customer,
                      khataService: khataService,
                    ),
                  ),
                );
              },
              title: Text(customer.name),
              subtitle: Text(
                '${customer.village} | ${customer.cattleType} | ${customer.phone}',
              ),
              trailing: customer.isActive
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Chip(label: Text('Active')),
                        Icon(Icons.chevron_right),
                      ],
                    )
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
