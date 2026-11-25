import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'expense_tracker_pro.db';
  static const _databaseVersion = 1;
  static const _tableName = 'transactions';

  Database? _database;

  Future<Database> get database async {
    final existingDatabase = _database;
    if (existingDatabase != null) {
      return existingDatabase;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    final database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert(_tableName, transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'date DESC, id DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
