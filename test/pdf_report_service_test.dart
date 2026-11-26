import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker_pro/models/transaction_model.dart';
import 'package:expense_tracker_pro/services/pdf_report_service.dart';

void main() {
  test('builds a PDF from the supplied monthly report data', () async {
    final bytes = await PdfReportService().buildMonthlyReportPdf(
      monthLabel: 'November 2026',
      totalIncome: 100,
      totalExpense: 40,
      balance: 60,
      expensesByCategory: {'Food': 40},
      transactions: [
        TransactionModel(
          title: 'Lunch',
          amount: 40,
          type: TransactionType.expense,
          category: 'Food',
          date: DateTime(2026, 11, 25),
        ),
      ],
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
