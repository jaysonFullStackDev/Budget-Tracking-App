// lib/services/export_service.dart
// Exports transaction data to CSV and shares via native share sheet.

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

class ExportService {
  static final _csvUnsafe = RegExp(r'^[=+\-@\t\r]');

  static String _sanitizeCsvField(String field) {
    final cleaned = field.replaceAll('"', '""');
    if (_csvUnsafe.hasMatch(cleaned) || cleaned.contains(',') || cleaned.contains('\n')) {
      return '"\' $cleaned"';
    }
    return cleaned;
  }

  static Future<void> exportToCsv(List<TransactionModel> transactions) async {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln('Date,Type,Category,Amount,Description');

    // CSV Rows
    for (final t in transactions) {
      final date = DateHelpers.formatDate(t.date);
      final type = t.transactionType;
      final category = t.category;
      final amount = t.amount.toStringAsFixed(2);
      final desc = _sanitizeCsvField(t.description);
      buffer.writeln('$date,$type,$category,$amount,$desc');
    }

    // Write to temp file
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/budgettrack_export.csv');
    await file.writeAsString(buffer.toString());

    // Share via native share sheet
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'BudgetTrack Transactions Export',
    );
  }
}
