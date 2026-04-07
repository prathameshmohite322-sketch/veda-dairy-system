import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/billing_detail_model.dart';
import 'bill_generator.dart';

class BillPdf {
  BillPdf({
    BillGenerator? generator,
  }) : _generator = generator ?? BillGenerator();

  final BillGenerator _generator;

  Future<Uint8List> generate({
    required BillingDetailModel bill,
    required String cycleLabel,
  }) async {
    final pw.Document document = pw.Document();
    final List<List<String>> entryRows = _generator.buildEntryRows(bill);
    final List<List<String>> khataRows = _generator.buildKhataRows(bill);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => <pw.Widget>[
          pw.Text(
            'Veda Dairy System',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('10-Day Bill'),
          pw.Text(cycleLabel),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                _summaryRow('Farmer', bill.summary.customerName),
                _summaryRow(
                  'Total liters',
                  '${bill.summary.totalLiters.toStringAsFixed(1)} L',
                ),
                _summaryRow(
                  'Average fat',
                  bill.summary.averageFat.toStringAsFixed(1),
                ),
                _summaryRow(
                  'Average SNF',
                  bill.summary.averageSnf.toStringAsFixed(1),
                ),
                _summaryRow(
                  'Gross amount',
                  'Rs ${bill.summary.totalAmount.toStringAsFixed(0)}',
                ),
                pw.Divider(),
                _summaryRow(
                  'Deposit',
                  'Rs ${bill.depositAmount.toStringAsFixed(0)}',
                ),
                _summaryRow(
                  'Feed',
                  'Rs ${bill.feedAmount.toStringAsFixed(0)}',
                ),
                _summaryRow(
                  'Advance',
                  'Rs ${bill.advanceAmount.toStringAsFixed(0)}',
                ),
                _summaryRow(
                  'Manual deduction',
                  'Rs ${bill.deductionAmount.toStringAsFixed(0)}',
                ),
                pw.Divider(),
                _summaryRow(
                  'Final payable',
                  'Rs ${bill.finalPayableAmount.toStringAsFixed(0)}',
                  emphasize: true,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Milk Entries',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const <String>[
              'Date',
              'Shift',
              'Liters',
              'Fat',
              'SNF',
              'Rate',
              'Amount',
            ],
            data: entryRows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Khata Adjustments',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const <String>['Date', 'Type', 'Note', 'Amount'],
            data: khataRows.isEmpty
                ? <List<String>>[
                    <String>['-', '-', 'No khata adjustments', '0'],
                  ]
                : khataRows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    final pw.TextStyle style = emphasize
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)
        : const pw.TextStyle(fontSize: 11);

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }
}
