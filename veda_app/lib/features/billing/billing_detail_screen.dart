import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/billing_detail_model.dart';
import '../../models/khata_entry_model.dart';
import '../../models/milk_entry_model.dart';
import '../../services/bill_export_service.dart';
import '../../utils/bill_generator.dart';
import '../../utils/bill_pdf.dart';

class BillingDetailScreen extends StatefulWidget {
  const BillingDetailScreen({
    super.key,
    required this.bill,
    required this.cycleLabel,
  });

  final BillingDetailModel bill;
  final String cycleLabel;

  @override
  State<BillingDetailScreen> createState() => _BillingDetailScreenState();
}

class _BillingDetailScreenState extends State<BillingDetailScreen> {
  final BillPdf _billPdf = BillPdf();
  final BillGenerator _billGenerator = BillGenerator();
  final BillExportService _billExportService = BillExportService();
  bool _generating = false;

  Future<void> _exportPdf() async {
    setState(() {
      _generating = true;
    });

    final Uint8List pdfBytes = await _billPdf.generate(
      bill: widget.bill,
      cycleLabel: widget.cycleLabel,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _generating = false;
    });

    final String fileName = _billGenerator.buildFileName(
      widget.bill,
      widget.cycleLabel,
    );

    await _billExportService.exportPdf(
      pdfBytes: pdfBytes,
      fileName: fileName,
      customerName: widget.bill.summary.customerName,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bill ready to share or save: $fileName'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bill.summary.customerName} Bill'),
        actions: <Widget>[
          IconButton(
            onPressed: _generating ? null : _exportPdf,
            icon: _generating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
          ),
        ],
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
                    '10-Day Bill',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(widget.cycleLabel),
                  const Divider(height: 24),
                  _BillRow(
                    label: 'Farmer',
                    value: widget.bill.summary.customerName,
                  ),
                  _BillRow(
                    label: 'Total liters',
                    value: '${widget.bill.summary.totalLiters.toStringAsFixed(1)} L',
                  ),
                  _BillRow(
                    label: 'Avg fat',
                    value: widget.bill.summary.averageFat.toStringAsFixed(1),
                  ),
                  _BillRow(
                    label: 'Avg SNF',
                    value: widget.bill.summary.averageSnf.toStringAsFixed(1),
                  ),
                  _BillRow(
                    label: 'Gross amount',
                    value: 'Rs ${widget.bill.summary.totalAmount.toStringAsFixed(0)}',
                  ),
                  const Divider(height: 24),
                  _BillRow(
                    label: 'Deposit',
                    value: 'Rs ${widget.bill.depositAmount.toStringAsFixed(0)}',
                  ),
                  _BillRow(
                    label: 'Feed',
                    value: 'Rs ${widget.bill.feedAmount.toStringAsFixed(0)}',
                  ),
                  _BillRow(
                    label: 'Advance',
                    value: 'Rs ${widget.bill.advanceAmount.toStringAsFixed(0)}',
                  ),
                  _BillRow(
                    label: 'Manual deduction',
                    value: 'Rs ${widget.bill.deductionAmount.toStringAsFixed(0)}',
                  ),
                  const Divider(height: 24),
                  _BillRow(
                    label: 'Final payable',
                    value: 'Rs ${widget.bill.finalPayableAmount.toStringAsFixed(0)}',
                    emphasize: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Date-wise Milk Entries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...widget.bill.entries.map(_entryCard),
          const SizedBox(height: 16),
          Text(
            'Khata Adjustments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (widget.bill.khataEntries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No khata adjustments in this cycle.'),
              ),
            ),
          ...widget.bill.khataEntries.map(_khataCard),
        ],
      ),
    );
  }

  Widget _entryCard(MilkEntryModel entry) {
    return Card(
      child: ListTile(
        title: Text('${entry.shift} | ${_dateLabel(entry.createdAt)}'),
        subtitle: Text(
          'Liters ${entry.liters.toStringAsFixed(1)} | Fat ${entry.fat.toStringAsFixed(1)} | SNF ${entry.snf.toStringAsFixed(1)} | Rate ${entry.rate.toStringAsFixed(2)}',
        ),
        trailing: Text('Rs ${entry.amount.toStringAsFixed(0)}'),
      ),
    );
  }

  Widget _khataCard(KhataEntryModel entry) {
    return Card(
      child: ListTile(
        title: Text(_khataLabel(entry.type)),
        subtitle: Text('${entry.note} | ${_dateLabel(entry.createdAt)}'),
        trailing: Text('Rs ${entry.amount.toStringAsFixed(0)}'),
      ),
    );
  }

  String _dateLabel(DateTime value) {
    return '${value.day}/${value.month}/${value.year}';
  }

  String _khataLabel(String type) {
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
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
