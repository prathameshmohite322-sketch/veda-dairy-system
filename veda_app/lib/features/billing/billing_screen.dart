import 'package:flutter/material.dart';

import '../../models/billing_summary_model.dart';
import '../../services/khata_service.dart';
import '../../services/milk_entry_service.dart';
import 'billing_detail_screen.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({
    super.key,
    required this.summaries,
    required this.cycleLabel,
    required this.dairyId,
    required this.milkEntryService,
    required this.khataService,
  });

  final List<BillingSummaryModel> summaries;
  final String cycleLabel;
  final String dairyId;
  final MilkEntryService milkEntryService;
  final KhataService khataService;

  @override
  Widget build(BuildContext context) {
    final double totalAmount = summaries.fold(
      0,
      (double sum, BillingSummaryModel item) => sum + item.totalAmount,
    );
    final double totalLiters = summaries.fold(
      0,
      (double sum, BillingSummaryModel item) => sum + item.totalLiters,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('10-Day Billing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    cycleLabel,
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
          if (summaries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No billing data available for this cycle.'),
              ),
            ),
          ...summaries.map(
            (BillingSummaryModel item) => Card(
              child: ListTile(
                onTap: () async {
                  final bill = await milkEntryService.buildBillingDetail(
                    dairyId: dairyId,
                    summary: item,
                    khataEntries: await khataService.fetchEntries(
                      dairyId: dairyId,
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
                        cycleLabel: cycleLabel,
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
