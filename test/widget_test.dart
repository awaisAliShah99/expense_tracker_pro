import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:expense_tracker_pro/db/database_helper.dart';
import 'package:expense_tracker_pro/models/transaction_model.dart';
import 'package:expense_tracker_pro/providers/transaction_provider.dart';
import 'package:expense_tracker_pro/screens/home_screen.dart';
import 'package:expense_tracker_pro/theme/app_theme.dart';

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
  testWidgets('home shows current month data and opens the monthly report', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final provider = TransactionProvider(
      databaseHelper: _FakeDatabaseHelper([
        TransactionModel(
          id: 1,
          title: 'Current income',
          amount: 100,
          type: TransactionType.income,
          category: 'Salary',
          date: currentMonth,
        ),
        TransactionModel(
          id: 2,
          title: 'Current expense',
          amount: 140,
          type: TransactionType.expense,
          category: 'Food',
          date: currentMonth,
        ),
        TransactionModel(
          id: 3,
          title: 'Previous month expense',
          amount: 10,
          type: TransactionType.expense,
          category: 'Housing',
          date: previousMonth,
        ),
      ]),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final monthLabel = MaterialLocalizations.of(
      tester.element(find.byType(HomeScreen)),
    ).formatMonthYear(currentMonth);
    expect(find.text('$monthLabel balance'), findsOneWidget);
    expect(find.text('-40.00'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('-40.00')).style?.color,
      AppTheme.lightTheme.extension<TransactionColors>()!.expense,
    );
    expect(find.text('100.00'), findsOneWidget);
    expect(find.text('140.00'), findsNWidgets(2));
    expect(find.text('$monthLabel · Expenses by category'), findsOneWidget);
    expect(find.text('Current income'), findsOneWidget);
    expect(find.text('Current expense'), findsOneWidget);
    expect(find.text('Previous month expense'), findsNothing);
    expect(find.text('View report'), findsOneWidget);

    await tester.tap(find.text('View report'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly Report'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });
}
