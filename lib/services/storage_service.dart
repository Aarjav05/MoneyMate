import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/currency.dart';
import '../utils/constants.dart';

class StorageService {
  static const String _transactionsBox = 'transactions';
  static const String _categoriesBox = 'categories';
  static const String _budgetsBox = 'budgets';
  static const String _currenciesBox = 'currencies';
  static const String _settingsBox = 'settings';

  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(
      CurrencyAdapter(),
    ); // Added CurrencyAdapter registration

    // Open boxes
    await Hive.openBox<Transaction>(_transactionsBox);
    await Hive.openBox<Category>(_categoriesBox);
    await Hive.openBox<Budget>(_budgetsBox);
    await Hive.openBox<Currency>(
      _currenciesBox,
    ); // Added currencies box opening
    await Hive.openBox(_settingsBox);

    // Seed default categories and currencies
    await _seedCategories();
    await _seedCurrencies(); // Added call to seed currencies
  }

  // Seed default categories
  static Future<void> _seedCategories() async {
    final categoryBox = Hive.box<Category>(_categoriesBox);
    if (categoryBox.isEmpty) {
      final defaultCategories = AppConstants.getDefaultCategories();
      for (var category in defaultCategories) {
        await categoryBox.put(category.id, category);
      }
    }
  }

  // Seed currencies
  static Future<void> _seedCurrencies() async {
    final currencyBox = Hive.box<Currency>(_currenciesBox);
    if (currencyBox.isEmpty) {
      final currencies = Currency.getPopularCurrencies();
      for (var currency in currencies) {
        await currencyBox.put(currency.code, currency);
      }
    }
  }

  // Get boxes
  static Box<Transaction> get transactionsBox =>
      Hive.box<Transaction>(_transactionsBox);

  static Box<Category> get categoriesBox => Hive.box<Category>(_categoriesBox);

  static Box<Budget> get budgetsBox => Hive.box<Budget>(_budgetsBox);

  static Box<Currency> get currenciesBox => Hive.box<Currency>(_currenciesBox);

  static Box get settingsBox => Hive.box(_settingsBox);

  // Settings helpers
  static bool get isDarkMode =>
      settingsBox.get('isDarkMode', defaultValue: false);

  static Future<void> setDarkMode(bool value) async {
    await settingsBox.put('isDarkMode', value);
  }

  static String get baseCurrency =>
      settingsBox.get('baseCurrency', defaultValue: 'INR');

  static Future<void> setBaseCurrency(String code) async {
    await settingsBox.put('baseCurrency', code);
  }
}
