import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({required this.category, super.key});

  final String category;

  static const Map<String, IconData> _icons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_transit,
    'Housing': Icons.home,
    'Bills': Icons.receipt_long,
    'Shopping': Icons.shopping_bag,
    'Health': Icons.medical_services,
    'Entertainment': Icons.movie,
    'Salary': Icons.payments,
    'Freelance': Icons.work,
    'Investment': Icons.trending_up,
    'Gift': Icons.card_giftcard,
    'Other': Icons.category,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      child: Icon(_icons[category] ?? Icons.category),
    );
  }
}
