import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/category_icon.dart';
import '../widgets/expense_pie_chart.dart';
import 'add_transaction_screen.dart';
import 'monthly_report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final monthLabel = MaterialLocalizations.of(context)
        .formatMonthYear(currentMonth);
    final transactions = provider.getTransactionsForMonth(currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MonthlyReportScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('View report'),
          ),
        ],
      ),
      body: Column(
        children: [
          BalanceSummaryCard(
            balance: provider.getBalanceForMonth(currentMonth),
            income: provider.getTotalIncomeForMonth(currentMonth),
            expense: provider.getTotalExpenseForMonth(currentMonth),
            balanceLabel: '$monthLabel balance',
          ),
          ExpensePieChart(
            expensesByCategory: provider.getExpenseTotalsByCategoryForMonth(
              currentMonth,
            ),
            totalExpense: provider.getTotalExpenseForMonth(currentMonth),
            periodLabel: monthLabel,
          ),
          if (provider.errorMessage != null && transactions.isNotEmpty)
            MaterialBanner(
              content: Text(provider.errorMessage!),
              actions: [
                TextButton(
                  onPressed: provider.loadTransactions,
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(
            child: _buildBody(context, provider, transactions, monthLabel),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        tooltip: 'Add transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransactionProvider provider,
    List<TransactionModel> transactions,
    String monthLabel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isLoading && provider.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.transactions.isEmpty && provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions for $monthLabel. Add one to begin.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isIncome = transaction.type == TransactionType.income;
        final transactionColors = Theme.of(context)
            .extension<TransactionColors>();
        final amountColor = isIncome
            ? transactionColors?.income
            : transactionColors?.expense;
        final amountPrefix = isIncome ? '+' : '-';

        return Dismissible(
          key: ValueKey(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: colorScheme.onError),
          ),
          onDismissed: (_) async {
            try {
              await context.read<TransactionProvider>().deleteTransaction(
                transaction.id!,
              );
            } catch (error) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not delete transaction: $error')),
              );
              await context.read<TransactionProvider>().loadTransactions();
            }
          },
          child: ListTile(
            leading: CategoryIcon(category: transaction.category),
            title: Text(transaction.title),
            subtitle: Text(
              '${transaction.category} · ${_formatDate(transaction.date)}',
            ),
            trailing: Text(
              '$amountPrefix${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: amountColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }
}
