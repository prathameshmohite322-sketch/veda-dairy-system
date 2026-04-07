import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

class BillExportService {
  Future<void> exportPdf({
    required Uint8List pdfBytes,
    required String fileName,
    required String customerName,
  }) async {
    final XFile file = XFile.fromData(
      pdfBytes,
      mimeType: 'application/pdf',
      name: fileName,
    );

    await Share.shareXFiles(
      <XFile>[file],
      text: 'Veda Dairy bill for $customerName',
      subject: fileName,
    );
  }
}
