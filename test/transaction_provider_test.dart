import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:expense_tracker_pro/db/database_helper.dart';
import 'package:expense_tracker_pro/models/transaction_model.dart';
import 'package:expense_tracker_pro/providers/transaction_provider.dart';

class _FakeDatabaseHelper implements DatabaseHelper {
  _FakeDatabaseHelper(this.transactions);

  final List<TransactionModel> transactions;

  @override
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<int> addTransaction(TransactionModel transaction) async => 0;

  @override
  Future<int> deleteTransaction(int id) async => 0;

  @override
  Future<List<TransactionModel>> getAllTransactions() async => transactions;
}

void main() {
  test('groups expense totals by category and excludes income', () async {
    final provider = TransactionProvider(
      databaseHelper: _FakeDatabaseHelper([
        TransactionModel(
          id: 1,
          title: 'Lunch',
          amount: 12.5,
          type: TransactionType.expense,
          category: 'Food',
          date: DateTime(2026, 11, 25),
        ),
        TransactionModel(
          id: 2,
          title: 'Dinner',
          amount: 20,
          type: TransactionType.expense,
          category: 'Food',
          date: DateTime(2026, 11, 25),
        ),
        TransactionModel(
          id: 3,
          title: 'Pay',
          amount: 100,
          type: TransactionType.income,
          category: 'Salary',
          date: DateTime(2026, 11, 25),
        ),
      ]),
    );

    await provider.loadTransactions();

    expect(provider.getExpenseTotalsByCategory(), {'Food': 32.5});
    provider.dispose();
  });
}
