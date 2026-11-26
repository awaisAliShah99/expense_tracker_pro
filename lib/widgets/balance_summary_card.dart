import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({
    required this.balance,
    required this.income,
    required this.expense,
    this.balanceLabel = 'Total balance',
    this.periodLabel,
    super.key,
  });

  final double balance;
  final double income;
  final double expense;
  final String balanceLabel;
  final String? periodLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionColors = theme.extension<TransactionColors>();

    return Card(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.tertiaryContainer,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              balanceLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              balance.toStringAsFixed(2),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: balance < 0
                    ? transactionColors?.expense ?? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (periodLabel != null) ...[
              Text(
                periodLabel!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: _SummaryAmount(
                    label: 'Income',
                    amount: income,
                    color:
                        transactionColors?.income ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                Expanded(
                  child: _SummaryAmount(
                    label: 'Expense',
                    amount: expense,
                    color:
                        transactionColors?.expense ??
                        theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryAmount extends StatelessWidget {
  const _SummaryAmount({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textStyle.bodyMedium?.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(
          amount.toStringAsFixed(2),
          style: textStyle.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
