import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({
    required this.expensesByCategory,
    required this.totalExpense,
    super.key,
  });

  final Map<String, double> expensesByCategory;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final entries =
        expensesByCategory.entries.where((entry) => entry.value > 0).toList()
          ..sort((first, second) => second.value.compareTo(first.value));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses by category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty || totalExpense <= 0)
              _buildEmptyState(context)
            else
              _buildChart(context, entries),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 132,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No expenses to chart yet.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<MapEntry<String, double>> entries,
  ) {
    final theme = Theme.of(context);
    final categoryColors = theme.extension<CategoryColors>();
    final chartSize = 140.0;

    return SizedBox(
      height: 164,
      child: Row(
        children: [
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: [
                  for (final entry in entries)
                    PieChartSectionData(
                      value: entry.value,
                      color: categoryColors?.colorFor(
                        entry.key,
                        theme.colorScheme.primary,
                      ),
                      title: '',
                      radius: 48,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final percentage = entry.value / totalExpense * 100;
                final color = categoryColors?.colorFor(
                  entry.key,
                  theme.colorScheme.primary,
                );
                return SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            entry.value.toStringAsFixed(2),
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
