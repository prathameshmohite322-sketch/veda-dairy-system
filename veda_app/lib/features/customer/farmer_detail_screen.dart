import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../models/customer_model.dart';
import '../../models/khata_entry_model.dart';
import '../../services/customer_service.dart';
import '../../services/khata_service.dart';
import '../../utils/account_calculation.dart';
import 'add_khata_entry_screen.dart';

class FarmerDetailScreen extends StatefulWidget {
  const FarmerDetailScreen({
    super.key,
    required this.customer,
    required this.khataService,
    required this.customerService,
  });

  final CustomerModel customer;
  final KhataService khataService;
  final CustomerService customerService;

  @override
  State<FarmerDetailScreen> createState() => _FarmerDetailScreenState();
}

class _FarmerDetailScreenState extends State<FarmerDetailScreen> {
  late CustomerModel _customer;
  List<KhataEntryModel> _entries = <KhataEntryModel>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final List<KhataEntryModel> entries = await widget.khataService.fetchEntries(
      dairyId: _customer.dairyId,
      customerId: _customer.id,
    );
    final CustomerModel? freshCustomer =
        await widget.customerService.findCustomerById(_customer.id);

    if (!mounted) {
      return;
    }

    setState(() {
      if (freshCustomer != null) {
        _customer = freshCustomer;
      }
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _openAddKhataEntry() async {
    final KhataEntryModel? entry = await Navigator.of(context).push<KhataEntryModel>(
      MaterialPageRoute<KhataEntryModel>(
        builder: (_) => AddKhataEntryScreen(
          customer: _customer,
        ),
      ),
    );

    if (entry == null) {
      return;
    }

    await widget.khataService.addEntry(entry);
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double remainingAdvance = AccountCalculation.remainingAdvance(
      totalAdvance: _customer.totalAdvance,
      usedAdvance: _customer.usedAdvance,
    );

    final double totalDeposits = _sumByType('deposit');
    final double totalFeed = _sumByType('feed');
    final double totalAdvanceGiven = _sumByType('advance');
    final double totalDeductions = _sumByType('deduction');

    return Scaffold(
      appBar: AppBar(
        title: Text(_customer.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddKhataEntry,
        icon: const Icon(Icons.add),
        label: Text(l10n.t('khataEntry')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _customer.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_customer.village} | ${_customer.cattleType} | ${_customer.phone}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _KhataSummaryCard(
                  title: l10n.t('totalAdvance'),
                  value: 'Rs ${_customer.totalAdvance.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 12),
                _KhataSummaryCard(
                  title: l10n.t('usedAdvance'),
                  value: 'Rs ${_customer.usedAdvance.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 12),
                _KhataSummaryCard(
                  title: l10n.t('remainingAdvance'),
                  value: 'Rs ${remainingAdvance.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.t('khataSnapshot'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _MiniMetric(label: l10n.t('deposit'), value: totalDeposits),
                    _MiniMetric(label: l10n.t('feed'), value: totalFeed),
                    _MiniMetric(label: l10n.t('advance'), value: totalAdvanceGiven),
                    _MiniMetric(label: l10n.t('deductions'), value: totalDeductions),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.t('ledgerHistory'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (_entries.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.t('noKhataEntries')),
                    ),
                  ),
                ..._entries.map(
                  (KhataEntryModel entry) => Card(
                    child: ListTile(
                      title: Text(_titleForType(entry.type, l10n)),
                      subtitle: Text(entry.note),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text('Rs ${entry.amount.toStringAsFixed(0)}'),
                          Text(
                            _dateLabel(entry.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  double _sumByType(String type) {
    return _entries
        .where((KhataEntryModel entry) => entry.type == type)
        .fold(0, (double sum, KhataEntryModel entry) => sum + entry.amount);
  }

  String _titleForType(String type, AppLocalizations l10n) {
    switch (type) {
      case 'deposit':
        return l10n.t('deposit');
      case 'feed':
        return l10n.t('feed');
      case 'advance':
        return l10n.t('advance');
      case 'deduction':
        return l10n.t('manualDeduction');
      default:
        return type;
    }
  }

  String _dateLabel(DateTime value) {
    return '${value.day}/${value.month}/${value.year}';
  }
}

class _KhataSummaryCard extends StatelessWidget {
  const _KhataSummaryCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label),
          const SizedBox(height: 6),
          Text(
            'Rs ${value.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
