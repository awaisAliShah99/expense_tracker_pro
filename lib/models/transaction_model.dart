enum TransactionType { income, expense }

class TransactionModel {
  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  final int? id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.byName(map['type'] as String),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
