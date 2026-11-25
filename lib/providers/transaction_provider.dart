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
