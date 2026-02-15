import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/category.dart' as models;
import '../models/transaction_filter.dart';
import '../services/storage_service.dart';

class TransactionProvider with ChangeNotifier {
  final _uuid = const Uuid();
  TransactionFilter _currentFilter = TransactionFilter();

  List<Transaction> get allTransactions {
    return StorageService.transactionsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<models.Category> get categories {
    return StorageService.categoriesBox.values.toList();
  }

  // Get transactions for current month
  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return allTransactions.where((t) {
      return t.date.isAfter(
            startOfMonth.subtract(const Duration(seconds: 1)),
          ) &&
          t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
    }).toList();
  }

  // Calculate total income for current month
  double get totalIncome {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Calculate total expenses for current month
  double get totalExpenses {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Calculate balance
  double get balance => totalIncome - totalExpenses;

  // Get spending by category
  Map<String, double> get spendingByCategory {
    final expenses = currentMonthTransactions.where(
      (t) => t.type == TransactionType.expense,
    );

    final Map<String, double> result = {};
    for (var transaction in expenses) {
      result[transaction.categoryId] =
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return result;
  }

  // Get income by category
  Map<String, double> get incomeByCategory {
    final income = currentMonthTransactions.where(
      (t) => t.type == TransactionType.income,
    );

    final Map<String, double> result = {};
    for (var transaction in income) {
      result[transaction.categoryId] =
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return result;
  }

  // Get category by ID
  models.Category? getCategoryById(String id) {
    return StorageService.categoriesBox.get(id);
  }

  // Get current filter
  TransactionFilter get currentFilter => _currentFilter;

  // Set filter
  void setFilter(TransactionFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _currentFilter = TransactionFilter.empty();
    notifyListeners();
  }

  // Get filtered transactions
  List<Transaction> get filteredTransactions {
    return applyFilter(allTransactions, _currentFilter);
  }

  // Apply filter to transaction list
  List<Transaction> applyFilter(
    List<Transaction> transactions,
    TransactionFilter filter,
  ) {
    return transactions.where((t) {
      // Search query
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        final matchesTitle = t.title.toLowerCase().contains(query);
        final matchesNotes = (t.notes ?? '').toLowerCase().contains(query);
        final matchesAmount = t.amount.toString().contains(query);
        if (!matchesTitle && !matchesNotes && !matchesAmount) return false;
      }

      // Date range
      if (filter.startDate != null && t.date.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null &&
          t.date.isAfter(filter.endDate!.add(const Duration(days: 1)))) {
        return false;
      }

      // Amount range
      if (filter.minAmount != null && t.amount < filter.minAmount!) {
        return false;
      }
      if (filter.maxAmount != null && t.amount > filter.maxAmount!) {
        return false;
      }

      // Categories
      if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty) {
        if (!filter.categoryIds!.contains(t.categoryId)) return false;
      }

      // Transaction type
      if (filter.type != null && t.type != filter.type) return false;

      return true;
    }).toList();
  }

  // Search transactions
  List<Transaction> searchTransactions(String query) {
    if (query.isEmpty) return allTransactions;
    final filter = TransactionFilter(searchQuery: query);
    return applyFilter(allTransactions, filter);
  }

  // Add transaction
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
    required TransactionType type,
    String? notes,
    String currencyCode = 'INR',
  }) async {
    final transaction = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: date,
      type: type,
      notes: notes,
      currencyCode: currencyCode,
    );

    await StorageService.transactionsBox.put(transaction.id, transaction);
    notifyListeners();
  }

  // Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await StorageService.transactionsBox.put(transaction.id, transaction);
    notifyListeners();
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    await StorageService.transactionsBox.delete(id);
    notifyListeners();
  }

  // Clear all transactions (for testing)
  Future<void> clearAllTransactions() async {
    await StorageService.transactionsBox.clear();
    notifyListeners();
  }

  // Get transactions grouped by date
  Map<DateTime, List<Transaction>> getTransactionsGroupedByDate() {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (var transaction in allTransactions) {
      final dateKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  // Filter transactions (legacy support)
  List<Transaction> filterTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
  }) {
    return allTransactions.where((t) {
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (type != null && t.type != type) return false;
      return true;
    }).toList();
  }

  // Multi-currency: Convert amount to base currency
  double convertToBaseCurrency(double amount, String currencyCode) {
    if (currencyCode == StorageService.baseCurrency) return amount;

    final currency = StorageService.currenciesBox.get(currencyCode);
    if (currency == null) return amount;

    return currency.toINR(amount);
  }

  // Calculate total income with multi-currency support
  double get totalIncomeConverted {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(
          0.0,
          (sum, t) => sum + convertToBaseCurrency(t.amount, t.currencyCode),
        );
  }

  // Calculate total expenses with multi-currency support
  double get totalExpensesConverted {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(
          0.0,
          (sum, t) => sum + convertToBaseCurrency(t.amount, t.currencyCode),
        );
  }

  // Calculate balance with multi-currency support
  double get balanceConverted => totalIncomeConverted - totalExpensesConverted;
}
