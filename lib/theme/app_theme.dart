import 'package:flutter/material.dart';

@immutable
class TransactionColors extends ThemeExtension<TransactionColors> {
  const TransactionColors({required this.income, required this.expense});

  final Color income;
  final Color expense;

  @override
  TransactionColors copyWith({Color? income, Color? expense}) {
    return TransactionColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }

  @override
  TransactionColors lerp(
    covariant ThemeExtension<TransactionColors>? other,
    double t,
  ) {
    if (other is! TransactionColors) return this;
    return TransactionColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
    );
  }
}

@immutable
class CategoryColors extends ThemeExtension<CategoryColors> {
  const CategoryColors(this.colors);

  final Map<String, Color> colors;

  Color colorFor(String category, Color fallback) {
    return colors[category] ?? fallback;
  }

  @override
  CategoryColors copyWith({Map<String, Color>? colors}) {
    return CategoryColors(colors ?? this.colors);
  }

  @override
  CategoryColors lerp(
    covariant ThemeExtension<CategoryColors>? other,
    double t,
  ) {
    if (other is! CategoryColors) return this;

    final categories = {...colors.keys, ...other.colors.keys};
    return CategoryColors({
      for (final category in categories)
        category: Color.lerp(
          colors[category] ?? other.colors[category]!,
          other.colors[category] ?? colors[category]!,
          t,
        )!,
    });
  }
}

class AppTheme {
  static final ThemeData lightTheme = _buildTheme(
    Brightness.light,
    const TransactionColors(
      income: Color(0xFF1B5E20),
      expense: Color(0xFFB71C1C),
    ),
    const CategoryColors({
      'Food': Color(0xFF00796B),
      'Transport': Color(0xFF1565C0),
      'Housing': Color(0xFF6D4C41),
      'Bills': Color(0xFFEF6C00),
      'Shopping': Color(0xFF7B1FA2),
      'Health': Color(0xFF558B2F),
      'Entertainment': Color(0xFFC2185B),
      'Salary': Color(0xFF00838F),
      'Freelance': Color(0xFF3949AB),
      'Investment': Color(0xFF827717),
      'Gift': Color(0xFFD84315),
      'Other': Color(0xFF546E7A),
    }),
  );

  static final ThemeData darkTheme = _buildTheme(
    Brightness.dark,
    const TransactionColors(
      income: Color(0xFF81C784),
      expense: Color(0xFFEF9A9A),
    ),
    const CategoryColors({
      'Food': Color(0xFF80CBC4),
      'Transport': Color(0xFF90CAF9),
      'Housing': Color(0xFFBCAAA4),
      'Bills': Color(0xFFFFCC80),
      'Shopping': Color(0xFFCE93D8),
      'Health': Color(0xFFC5E1A5),
      'Entertainment': Color(0xFFF48FB1),
      'Salary': Color(0xFF80DEEA),
      'Freelance': Color(0xFF9FA8DA),
      'Investment': Color(0xFFE6EE9C),
      'Gift': Color(0xFFFFAB91),
      'Other': Color(0xFFB0BEC5),
    }),
  );

  static ThemeData _buildTheme(
    Brightness brightness,
    TransactionColors transactionColors,
    CategoryColors categoryColors,
  ) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [transactionColors, categoryColors],
    );
  }
}
