import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../models/app_user.dart';
import '../../models/customer_model.dart';
import '../../models/dashboard_report_model.dart';
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
  DashboardReportModel? _report;
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
    final double totalAdvanceOutstanding = customers.fold(
      0,
      (double sum, CustomerModel customer) =>
          sum + (customer.totalAdvance - customer.usedAdvance),
    );
    final DashboardReportModel report =
        await widget.milkEntryService.buildDashboardReport(
      dairyId: widget.user.dairyId,
      activeFarmers: customers.where((CustomerModel customer) => customer.isActive).length,
      totalAdvanceOutstanding: totalAdvanceOutstanding,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _customers = customers;
      _entries = entries;
      _report = report;
      _loading = false;
    });
  }

  Future<void> _addFarmer(CustomerModel customer) async {
    await widget.customerService.addCustomer(customer);
    await _loadData();
  }

  Future<void> _openBilling() async {
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BillingScreen(
          dairyId: widget.user.dairyId,
          milkEntryService: widget.milkEntryService,
          khataService: widget.khataService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DashboardReportModel report = _report ??
        const DashboardReportModel(
          todayMilkLiters: 0,
          todayMilkValue: 0,
          currentCycleAmount: 0,
          currentCycleLiters: 0,
          activeFarmers: 0,
          totalAdvanceOutstanding: 0,
          recentEntryCount: 0,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('appName')),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String code) {
              l10n.setLocale(Locale(code));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'en', child: Text(l10n.t('english'))),
              PopupMenuItem<String>(value: 'mr', child: Text(l10n.t('marathi'))),
            ],
          ),
          IconButton(
            tooltip: l10n.t('logout'),
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
        label: Text(l10n.t('milkEntry')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text(
                    l10n.t('welcome', <String, String>{'name': widget.user.name}),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _SummaryCard(
                    title: l10n.t('todayMilk'),
                    value: '${report.todayMilkLiters.toStringAsFixed(1)} L',
                    subtitle: l10n.t(
                      'todayValue',
                      <String, String>{'value': report.todayMilkValue.toStringAsFixed(0)},
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: l10n.t('currentCycle'),
                    value: 'Rs ${report.currentCycleAmount.toStringAsFixed(0)}',
                    subtitle: l10n.t(
                      'currentCycleSubtitle',
                      <String, String>{'liters': report.currentCycleLiters.toStringAsFixed(1)},
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: l10n.t('farmers'),
                    value: '${report.activeFarmers}',
                    subtitle: l10n.t('activeFarmersSubtitle'),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: l10n.t('advanceOutstanding'),
                    value: 'Rs ${report.totalAdvanceOutstanding.toStringAsFixed(0)}',
                    subtitle: l10n.t('advanceOutstandingSubtitle'),
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
                                  customerService: widget.customerService,
                                ),
                              ),
                            );
                          },
                          child: Text(l10n.t('viewFarmers')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _openBilling,
                          child: Text(l10n.t('openBilling')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.t('recentActivity'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_entries.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(l10n.t('noEntriesYet')),
                      ),
                    ),
                  ..._entries.take(5).map(
                    (MilkEntryModel entry) => Card(
                      child: ListTile(
                        title: Text(entry.customerName),
                        subtitle: Text(
                          '${entry.shift} | ${entry.cattleType} | ${_dateLabel(entry.createdAt)} | Fat ${entry.fat.toStringAsFixed(1)} | SNF ${entry.snf.toStringAsFixed(1)}',
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

  String _dateLabel(DateTime value) {
    return '${value.day}/${value.month}/${value.year}';
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
