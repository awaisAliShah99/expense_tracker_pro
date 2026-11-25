import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/category_icon.dart';
import '../widgets/expense_pie_chart.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.getTransactionsForMonth(_selectedMonth);
    final monthLabel = MaterialLocalizations.of(context)
        .formatMonthYear(_selectedMonth);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  tooltip: 'Previous month',
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(monthLabel, style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  tooltip: 'Next month',
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          BalanceSummaryCard(
            balance: provider.getBalanceForMonth(_selectedMonth),
            income: provider.getTotalIncomeForMonth(_selectedMonth),
            expense: provider.getTotalExpenseForMonth(_selectedMonth),
          ),
          ExpensePieChart(
            expensesByCategory: provider.getExpenseTotalsByCategoryForMonth(
              _selectedMonth,
            ),
            totalExpense: provider.getTotalExpenseForMonth(_selectedMonth),
          ),
          Expanded(
            child: _buildTransactionList(
              context,
              provider,
              transactions,
              monthLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    TransactionProvider provider,
    List<TransactionModel> transactions,
    String monthLabel,
  ) {
    if (provider.isLoading && provider.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: provider.loadTransactions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions for $monthLabel.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final transactionColors = Theme.of(context).extension<TransactionColors>();
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isIncome = transaction.type == TransactionType.income;
        final amountColor = isIncome
            ? transactionColors?.income
            : transactionColors?.expense;
        final amountPrefix = isIncome ? '+' : '-';

        return ListTile(
          leading: CategoryIcon(category: transaction.category),
          title: Text(transaction.title),
          subtitle: Text(transaction.category),
          trailing: Text(
            '$amountPrefix${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: amountColor ?? colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
