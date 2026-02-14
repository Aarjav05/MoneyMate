import 'package:intl/intl.dart';
import '../models/currency.dart';

class Helpers {
  // Format currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return formatter.format(amount);
  }

  // Format currency with specific currency
  static String formatCurrencyWithCode(
    double amount,
    String currencyCode, [
    Currency? currency,
  ]) {
    String symbol = '₹';
    if (currency != null) {
      symbol = currency.symbol;
    } else {
      final symbols = {
        'USD': '\$',
        'EUR': '€',
        'GBP': '£',
        'AED': 'د.إ',
        'SGD': 'S\$',
        'INR': '₹',
      };
      symbol = symbols[currencyCode] ?? currencyCode;
    }
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  // Format currency compact (for large numbers)
  static String formatCurrencyCompact(
    double amount, [
    String currencyCode = 'INR',
  ]) {
    String symbol = currencyCode == 'INR' ? '₹' : '\$';
    if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currencyCode == 'INR'
        ? formatCurrency(amount)
        : formatCurrencyWithCode(amount, currencyCode);
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format date with day name
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEE, MMM dd').format(date);
  }

  // Format month and year
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is in current month
  static bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  // Get start of week
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // Get end of week
  static DateTime getEndOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(
      Duration(days: 7 - weekday, hours: 23, minutes: 59, seconds: 59),
    );
  }

  // Calculate percentage
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
