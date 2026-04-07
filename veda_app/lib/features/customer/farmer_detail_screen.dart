import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../models/khata_entry_model.dart';
import '../../services/khata_service.dart';
import '../../utils/account_calculation.dart';

class FarmerDetailScreen extends StatefulWidget {
  const FarmerDetailScreen({
    super.key,
    required this.customer,
    required this.khataService,
  });

  final CustomerModel customer;
  final KhataService khataService;

  @override
  State<FarmerDetailScreen> createState() => _FarmerDetailScreenState();
}

class _FarmerDetailScreenState extends State<FarmerDetailScreen> {
  List<KhataEntryModel> _entries = <KhataEntryModel>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final List<KhataEntryModel> entries = await widget.khataService.fetchEntries(
      dairyId: widget.customer.dairyId,
      customerId: widget.customer.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double remainingAdvance = AccountCalculation.remainingAdvance(
      totalAdvance: widget.customer.totalAdvance,
      usedAdvance: widget.customer.usedAdvance,
    );

    final double totalDeposits = _sumByType('deposit');
    final double totalFeed = _sumByType('feed');
    final double totalAdvanceGiven = _sumByType('advance');
    final double totalDeductions = _sumByType('deduction');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
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
                          widget.customer.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.customer.village} | ${widget.customer.cattleType} | ${widget.customer.phone}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _KhataSummaryCard(
                  title: 'Total Advance',
                  value: 'Rs ${widget.customer.totalAdvance.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 12),
                _KhataSummaryCard(
                  title: 'Used Advance',
                  value: 'Rs ${widget.customer.usedAdvance.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 12),
                _KhataSummaryCard(
                  title: 'Remaining Advance',
                  value: 'Rs ${remainingAdvance.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 16),
                Text(
                  'Khata Snapshot',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _MiniMetric(label: 'Deposits', value: totalDeposits),
                    _MiniMetric(label: 'Feed', value: totalFeed),
                    _MiniMetric(label: 'Advance', value: totalAdvanceGiven),
                    _MiniMetric(label: 'Deductions', value: totalDeductions),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Ledger History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (_entries.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No khata entries for this farmer yet.'),
                    ),
                  ),
                ..._entries.map(
                  (KhataEntryModel entry) => Card(
                    child: ListTile(
                      title: Text(_titleForType(entry.type)),
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

  String _titleForType(String type) {
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'feed':
        return 'Feed';
      case 'advance':
        return 'Advance';
      case 'deduction':
        return 'Manual Deduction';
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
