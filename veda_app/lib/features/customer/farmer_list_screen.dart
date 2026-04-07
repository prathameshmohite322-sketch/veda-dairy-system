import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/customer_service.dart';
import '../../services/khata_service.dart';
import 'add_farmer_screen.dart';
import 'farmer_detail_screen.dart';

class FarmerListScreen extends StatelessWidget {
  const FarmerListScreen({
    super.key,
    required this.customers,
    required this.khataService,
    required this.dairyId,
    required this.onAddFarmer,
    required this.customerService,
  });

  final List<CustomerModel> customers;
  final KhataService khataService;
  final String dairyId;
  final Future<void> Function(CustomerModel customer) onAddFarmer;
  final CustomerService customerService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              final CustomerModel? customer = await Navigator.of(context).push<CustomerModel>(
                MaterialPageRoute<CustomerModel>(
                  builder: (_) => AddFarmerScreen(dairyId: dairyId),
                ),
              );
              if (customer != null) {
                await onAddFarmer(customer);
              }
            },
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
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
                      customerService: customerService,
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
