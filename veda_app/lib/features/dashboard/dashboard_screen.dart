import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/billing_summary_model.dart';
import '../../models/customer_model.dart';
import '../../models/milk_entry_model.dart';
import '../../services/auth_service.dart';
import '../../services/customer_service.dart';
import '../../services/khata_service.dart';
import '../../services/milk_entry_service.dart';
import '../billing/billing_screen.dart';
import '../customer/farmer_list_screen.dart';
import '../milk_entry/milk_entry_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.customerService,
    required this.khataService,
    required this.milkEntryService,
    required this.onLogout,
  });

  final AppUser user;
  final AuthService authService;
  final CustomerService customerService;
  final KhataService khataService;
  final MilkEntryService milkEntryService;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<CustomerModel> _customers = <CustomerModel>[];
  List<MilkEntryModel> _entries = <MilkEntryModel>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final List<CustomerModel> customers =
        await widget.customerService.fetchCustomers(widget.user.dairyId);
    final List<MilkEntryModel> entries =
        await widget.milkEntryService.fetchEntries(widget.user.dairyId);

    if (!mounted) {
      return;
    }

    setState(() {
      _customers = customers;
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _addFarmer(CustomerModel customer) async {
    await widget.customerService.addCustomer(customer);
    await _loadData();
  }

  Future<void> _openBilling() async {
    final List<BillingSummaryModel> summaries =
        await widget.milkEntryService.buildBillingSummaries(widget.user.dairyId);

    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BillingScreen(
          summaries: summaries,
          cycleLabel: 'Current 10-day cycle',
          dairyId: widget.user.dairyId,
          milkEntryService: widget.milkEntryService,
          khataService: widget.khataService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalMilk = _entries.fold(
      0,
      (double sum, MilkEntryModel item) => sum + item.liters,
    );
    final double totalAmount = _entries.fold(
      0,
      (double sum, MilkEntryModel item) => sum + item.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Veda Dairy - ${widget.user.role}'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await widget.authService.signOut();
              widget.onLogout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _customers.isEmpty
            ? null
            : () async {
                final bool? created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => MilkEntryScreen(
                      customers: _customers,
                      milkEntryService: widget.milkEntryService,
                      dairyId: widget.user.dairyId,
                    ),
                  ),
                );
                if (created == true) {
                  _loadData();
                }
              },
        icon: const Icon(Icons.add),
        label: const Text('Milk Entry'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text(
                    'Welcome, ${widget.user.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _SummaryCard(
                    title: 'Milk Collection',
                    value: '${totalMilk.toStringAsFixed(1)} L',
                    subtitle: '${_entries.length} entries recorded today',
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Collection Value',
                    value: 'Rs ${totalAmount.toStringAsFixed(0)}',
                    subtitle: 'Auto-calculated from liters, fat, and SNF',
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Farmers',
                    value: '${_customers.length}',
                    subtitle: 'Active farmers in this dairy',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => FarmerListScreen(
                                  customers: _customers,
                                  khataService: widget.khataService,
                                  dairyId: widget.user.dairyId,
                                  onAddFarmer: _addFarmer,
                                ),
                              ),
                            );
                          },
                          child: const Text('View Farmers'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _openBilling,
                          child: const Text('Open Billing'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Recent Milk Entries',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_entries.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No entries yet. Add the first milk collection.'),
                      ),
                    ),
                  ..._entries.map(
                    (MilkEntryModel entry) => Card(
                      child: ListTile(
                        title: Text(entry.customerName),
                        subtitle: Text(
                          '${entry.shift} | ${entry.cattleType} | Fat ${entry.fat.toStringAsFixed(1)} | SNF ${entry.snf.toStringAsFixed(1)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text('${entry.liters.toStringAsFixed(1)} L'),
                            Text('Rs ${entry.amount.toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
