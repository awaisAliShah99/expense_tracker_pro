import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const Map<TransactionType, List<String>> _categories = {
    TransactionType.expense: [
      'Food',
      'Transport',
      'Housing',
      'Bills',
      'Shopping',
      'Health',
      'Entertainment',
      'Other',
    ],
    TransactionType.income: [
      'Salary',
      'Freelance',
      'Investment',
      'Gift',
      'Other',
    ],
  };

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  late String _category = _categories[_type]!.first;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() => _date = selectedDate);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final transaction = TransactionModel(
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      type: _type,
      category: _category,
      date: _date,
    );

    try {
      await context.read<TransactionProvider>().addTransaction(transaction);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save transaction: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories[_type]!;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || !amount.isFinite || amount <= 0) {
                  return 'Enter an amount greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.remove),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.add),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() {
                  _type = selection.first;
                  if (!(_categories[_type]!.contains(_category))) {
                    _category = _categories[_type]!.first;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (category) {
                if (category != null) {
                  setState(() => _category = category);
                }
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Date: ${_date.month.toString().padLeft(2, '0')}/'
                '${_date.day.toString().padLeft(2, '0')}/${_date.year}',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _saveTransaction,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
