import 'package:flutter/material.dart';

import '../../models/billing_cycle_model.dart';
import '../../models/billing_summary_model.dart';
import '../../services/khata_service.dart';
import '../../services/milk_entry_service.dart';
import 'billing_detail_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({
    super.key,
    required this.dairyId,
    required this.milkEntryService,
    required this.khataService,
  });

  final String dairyId;
  final MilkEntryService milkEntryService;
  final KhataService khataService;

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late final List<BillingCycleModel> _cycles;
  BillingCycleModel? _selectedCycle;
  List<BillingSummaryModel> _summaries = <BillingSummaryModel>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cycles = widget.milkEntryService.recentBillingCycles();
    _selectedCycle = _cycles.isEmpty ? null : _cycles.first;
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    if (_selectedCycle == null) {
      return;
    }

    final List<BillingSummaryModel> summaries =
        await widget.milkEntryService.buildBillingSummariesForCycle(
      dairyId: widget.dairyId,
      cycle: _selectedCycle!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _summaries = summaries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = _summaries.fold(
      0,
      (double sum, BillingSummaryModel item) => sum + item.totalAmount,
    );
    final double totalLiters = _summaries.fold(
      0,
      (double sum, BillingSummaryModel item) => sum + item.totalLiters,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('10-Day Billing'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                DropdownButtonFormField<BillingCycleModel>(
                  initialValue: _selectedCycle,
                  decoration: const InputDecoration(
                    labelText: 'Billing cycle',
                    border: OutlineInputBorder(),
                  ),
                  items: _cycles
                      .map(
                        (BillingCycleModel cycle) =>
                            DropdownMenuItem<BillingCycleModel>(
                          value: cycle,
                          child: Text(cycle.label),
                        ),
                      )
                      .toList(),
                  onChanged: (BillingCycleModel? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedCycle = value;
                      _loading = true;
                    });
                    _loadSummaries();
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _selectedCycle?.label ?? 'No cycle selected',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Total liters: ${totalLiters.toStringAsFixed(1)} L'),
                        Text('Total amount: Rs ${totalAmount.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_summaries.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No billing data available for this cycle.'),
                    ),
                  ),
                ..._summaries.map(
                  (BillingSummaryModel item) => Card(
                    child: ListTile(
                      onTap: () async {
                        final bill = await widget.milkEntryService.buildBillingDetail(
                          dairyId: widget.dairyId,
                          summary: item,
                          khataEntries: await widget.khataService.fetchEntries(
                            dairyId: widget.dairyId,
                            customerId: item.customerId,
                          ),
                        );
                        if (bill == null || !context.mounted) {
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BillingDetailScreen(
                              bill: bill,
                              cycleLabel: _selectedCycle?.label ?? item.customerName,
                            ),
                          ),
                        );
                      },
                      title: Text(item.customerName),
                      subtitle: Text(
                        '${item.entryCount} entries | Fat ${item.averageFat.toStringAsFixed(1)} | SNF ${item.averageSnf.toStringAsFixed(1)}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text('${item.totalLiters.toStringAsFixed(1)} L'),
                          Text('Rs ${item.totalAmount.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
