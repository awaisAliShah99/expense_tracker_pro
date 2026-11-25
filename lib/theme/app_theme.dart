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

class AppTheme {
  static final ThemeData lightTheme = _buildTheme(
    Brightness.light,
    const TransactionColors(
      income: Color(0xFF1B5E20),
      expense: Color(0xFFB71C1C),
    ),
  );

  static final ThemeData darkTheme = _buildTheme(
    Brightness.dark,
    const TransactionColors(
      income: Color(0xFF81C784),
      expense: Color(0xFFEF9A9A),
    ),
  );

  static ThemeData _buildTheme(
    Brightness brightness,
    TransactionColors transactionColors,
  ) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [transactionColors],
    );
  }
}
