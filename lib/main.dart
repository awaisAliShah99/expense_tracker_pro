import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
        home: const HomeScreen(),
      ),
    );
  }
}
