import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: _buildBody(context, provider, transactions),
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
  ) {
    if (provider.isLoading && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty && provider.errorMessage != null) {
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
      return const Center(
        child: Text('No transactions yet. Add one to begin.'),
      );
    }

    return Column(
      children: [
        if (provider.errorMessage != null)
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
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncome = transaction.type == TransactionType.income;
              final amountColor = isIncome ? Colors.green : Colors.red;
              final amountPrefix = isIncome ? '+' : '-';

              return Dismissible(
                key: ValueKey(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  try {
                    await context.read<TransactionProvider>().deleteTransaction(
                      transaction.id!,
                    );
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not delete transaction: $error'),
                      ),
                    );
                    await context
                        .read<TransactionProvider>()
                        .loadTransactions();
                  }
                },
                child: ListTile(
                  title: Text(transaction.title),
                  subtitle: Text(
                    '${transaction.category} · ${_formatDate(transaction.date)}',
                  ),
                  trailing: Text(
                    '$amountPrefix${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }
}
