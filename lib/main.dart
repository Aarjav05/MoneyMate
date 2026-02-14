import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'services/storage_service.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'models/transaction.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await StorageService.init();

  // Add sample data if no transactions exist
  await _addSampleDataIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _addSampleDataIfNeeded() async {
  final transactionsBox = StorageService.transactionsBox;

  // Only add sample data if there are no transactions
  if (transactionsBox.isEmpty) {
    const uuid = Uuid();
    final now = DateTime.now();

    // Sample transactions for the current month
    final sampleTransactions = [
      // Income
      Transaction(
        id: uuid.v4(),
        title: 'Monthly Salary',
        amount: 50000,
        categoryId: 'salary',
        date: DateTime(now.year, now.month, 1),
        type: TransactionType.income,
        notes: 'Monthly salary deposit',
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Freelance Project',
        amount: 15000,
        categoryId: 'salary',
        date: DateTime(now.year, now.month, 5),
        type: TransactionType.income,
      ),

      // Expenses
      Transaction(
        id: uuid.v4(),
        title: 'Grocery Shopping',
        amount: 3500,
        categoryId: 'food',
        date: DateTime(now.year, now.month, 2),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Restaurant Dinner',
        amount: 1200,
        categoryId: 'food',
        date: DateTime(now.year, now.month, 7),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Coffee Shop',
        amount: 450,
        categoryId: 'food',
        date: DateTime(now.year, now.month, 10),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Uber Ride',
        amount: 280,
        categoryId: 'transport',
        date: DateTime(now.year, now.month, 3),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Petrol',
        amount: 2000,
        categoryId: 'transport',
        date: DateTime(now.year, now.month, 8),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'New Shoes',
        amount: 2500,
        categoryId: 'shopping',
        date: DateTime(now.year, now.month, 4),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Online Shopping',
        amount: 1800,
        categoryId: 'shopping',
        date: DateTime(now.year, now.month, 11),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Electricity Bill',
        amount: 1500,
        categoryId: 'bills',
        date: DateTime(now.year, now.month, 1),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Internet Bill',
        amount: 999,
        categoryId: 'bills',
        date: DateTime(now.year, now.month, 5),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Movie Tickets',
        amount: 600,
        categoryId: 'entertainment',
        date: DateTime(now.year, now.month, 6),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Netflix Subscription',
        amount: 199,
        categoryId: 'entertainment',
        date: DateTime(now.year, now.month, 1),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Gym Membership',
        amount: 1500,
        categoryId: 'health',
        date: DateTime(now.year, now.month, 1),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Medicine',
        amount: 450,
        categoryId: 'health',
        date: DateTime(now.year, now.month, 9),
        type: TransactionType.expense,
      ),
      Transaction(
        id: uuid.v4(),
        title: 'Birthday Gift',
        amount: 1200,
        categoryId: 'gifts',
        date: DateTime(now.year, now.month, 12),
        type: TransactionType.expense,
      ),
    ];

    // Add all sample transactions
    for (var transaction in sampleTransactions) {
      await transactionsBox.put(transaction.id, transaction);
    }
  }
}
