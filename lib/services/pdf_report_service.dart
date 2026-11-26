import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/transaction_model.dart';

class PdfReportService {
  Future<Uint8List> buildMonthlyReportPdf({
    required String monthLabel,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required Map<String, double> expensesByCategory,
    required List<TransactionModel> transactions,
  }) async {
    final document = pw.Document();
    final categoryRows = expensesByCategory.entries.map((entry) {
      final percentage = totalExpense > 0
          ? entry.value / totalExpense * 100
          : 0.0;
      return [
        entry.key,
        entry.value.toStringAsFixed(2),
        '${percentage.toStringAsFixed(1)}%',
      ];
    }).toList();
    final transactionRows = transactions
        .map(
          (transaction) => [
            _formatDate(transaction.date),
            transaction.title,
            transaction.category,
            _capitalize(transaction.type.name),
            transaction.amount.toStringAsFixed(2),
          ],
        )
        .toList();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('$monthLabel Report')),
          pw.TableHelper.fromTextArray(
            headers: const ['Summary', 'Amount'],
            data: [
              ['Total income', totalIncome.toStringAsFixed(2)],
              ['Total expense', totalExpense.toStringAsFixed(2)],
              ['Balance', balance.toStringAsFixed(2)],
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Expenses by category')),
          pw.TableHelper.fromTextArray(
            headers: const ['Category', 'Amount', 'Percentage'],
            data: categoryRows.isEmpty
                ? [
                    ['No expenses recorded', '-', '-'],
                  ]
                : categoryRows,
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Transactions')),
          pw.TableHelper.fromTextArray(
            headers: const ['Date', 'Title', 'Category', 'Type', 'Amount'],
            data: transactionRows.isEmpty
                ? [
                    ['No transactions recorded', '-', '-', '-', '-'],
                  ]
                : transactionRows,
          ),
        ],
      ),
    );

    return document.save();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _capitalize(String value) {
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
