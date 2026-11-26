import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance {
    loadTransactions();
  }

  final DatabaseHelper _databaseHelper;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalIncome => _totalFor(TransactionType.income);
  double get totalExpense => _totalFor(TransactionType.expense);

  Map<String, double> getExpenseTotalsByCategory() {
    return _expenseTotalsByCategory(_transactions);
  }

  List<TransactionModel> getTransactionsForMonth(DateTime month) {
    return List.unmodifiable(_transactionsInMonth(month));
  }

  double getTotalIncomeForMonth(DateTime month) {
    return _totalForMonth(month, TransactionType.income);
  }

  double getTotalExpenseForMonth(DateTime month) {
    return _totalForMonth(month, TransactionType.expense);
  }

  double getBalanceForMonth(DateTime month) {
    return getTotalIncomeForMonth(month) - getTotalExpenseForMonth(month);
  }

  Map<String, double> getExpenseTotalsByCategoryForMonth(DateTime month) {
    return _expenseTotalsByCategory(_transactionsInMonth(month));
  }

  Iterable<TransactionModel> _transactionsInMonth(DateTime month) {
    return _transactions.where(
      (transaction) =>
          transaction.date.year == month.year &&
          transaction.date.month == month.month,
    );
  }

  double _totalForMonth(DateTime month, TransactionType type) {
    return _transactionsInMonth(month)
        .where((transaction) => transaction.type == type)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  Map<String, double> _expenseTotalsByCategory(
    Iterable<TransactionModel> transactions,
  ) {
    final totals = <String, double>{};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        totals.update(
          transaction.category,
          (total) => total + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }
    return Map.unmodifiable(totals);
  }

  double _totalFor(TransactionType type) {
    return _transactions
        .where((transaction) => transaction.type == type)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _databaseHelper.getAllTransactions();
    } catch (error) {
      _errorMessage = 'Could not load transactions: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _errorMessage = null;
    try {
      await _databaseHelper.addTransaction(transaction);
      _transactions = await _databaseHelper.getAllTransactions();
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Could not add transaction: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    _errorMessage = null;
    try {
      await _databaseHelper.deleteTransaction(id);
      _transactions = await _databaseHelper.getAllTransactions();
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Could not delete transaction: $error';
      notifyListeners();
      rethrow;
    }
  }
}
