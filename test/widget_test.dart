import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:expense_tracker_pro/db/database_helper.dart';
import 'package:expense_tracker_pro/models/transaction_model.dart';
import 'package:expense_tracker_pro/providers/transaction_provider.dart';
import 'package:expense_tracker_pro/screens/home_screen.dart';
import 'package:expense_tracker_pro/screens/monthly_report_screen.dart';
import 'package:expense_tracker_pro/theme/app_theme.dart';

class _FakeDatabaseHelper implements DatabaseHelper {
  _FakeDatabaseHelper(this.transactions);

  final List<TransactionModel> transactions;

  @override
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<int> addTransaction(TransactionModel transaction) async => 0;

  @override
  Future<int> updateTransaction(TransactionModel transaction) async {
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index >= 0) {
      transactions[index] = transaction;
    }
    return index >= 0 ? 1 : 0;
  }

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

  testWidgets('monthly report shows a message when exporting an empty month', (
    tester,
  ) async {
    final provider = TransactionProvider(
      databaseHelper: _FakeDatabaseHelper([]),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MonthlyReportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final monthLabel = MaterialLocalizations.of(
      tester.element(find.byType(MonthlyReportScreen)),
    ).formatMonthYear(DateTime.now());
    await tester.tap(find.text('Export PDF'));
    await tester.pump();

    expect(
      find.text('No transactions for $monthLabel to export.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('tapping a transaction opens the prefilled edit form', (
    tester,
  ) async {
    final transaction = TransactionModel(
      id: 1,
      title: 'Lunch',
      amount: 12.5,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now(),
    );
    final provider = TransactionProvider(
      databaseHelper: _FakeDatabaseHelper([transaction]),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lunch'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsOneWidget);
    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(fields.first.controller?.text, 'Lunch');
    expect(fields.last.controller?.text, '12.5');
    expect(find.text('Food'), findsOneWidget);
    expect(find.textContaining('Date:'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Dinner');
    await tester.enterText(find.byType(TextFormField).last, '18.75');
    await tester.tap(find.text('Update Transaction'));
    await tester.pumpAndSettle();

    expect(provider.transactions.single.id, 1);
    expect(provider.transactions.single.title, 'Dinner');
    expect(provider.transactions.single.amount, 18.75);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });
}
