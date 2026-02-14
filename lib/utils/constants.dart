import 'package:flutter/material.dart';
import '../models/category.dart';

class AppConstants {
  // Predefined categories
  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: 'food',
        name: 'Food & Dining',
        iconCodePoint: Icons.restaurant.codePoint,
        colorValue: const Color(0xFFFF6B6B).toARGB32(),
      ),
      Category(
        id: 'transport',
        name: 'Transportation',
        iconCodePoint: Icons.directions_car.codePoint,
        colorValue: const Color(0xFF4ECDC4).toARGB32(),
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        iconCodePoint: Icons.shopping_bag.codePoint,
        colorValue: const Color(0xFFFFBE0B).toARGB32(),
      ),
      Category(
        id: 'bills',
        name: 'Bills & Utilities',
        iconCodePoint: Icons.receipt_long.codePoint,
        colorValue: const Color(0xFFFB5607).toARGB32(),
      ),
      Category(
        id: 'entertainment',
        name: 'Entertainment',
        iconCodePoint: Icons.movie.codePoint,
        colorValue: const Color(0xFF8338EC).toARGB32(),
      ),
      Category(
        id: 'health',
        name: 'Health & Fitness',
        iconCodePoint: Icons.favorite.codePoint,
        colorValue: const Color(0xFFFF006E).toARGB32(),
      ),
      Category(
        id: 'education',
        name: 'Education',
        iconCodePoint: Icons.school.codePoint,
        colorValue: const Color(0xFF3A86FF).toARGB32(),
      ),
      Category(
        id: 'salary',
        name: 'Salary',
        iconCodePoint: Icons.account_balance_wallet.codePoint,
        colorValue: const Color(0xFF06FFA5).toARGB32(),
      ),
      Category(
        id: 'investment',
        name: 'Investment',
        iconCodePoint: Icons.trending_up.codePoint,
        colorValue: const Color(0xFF06D6A0).toARGB32(),
      ),
      Category(
        id: 'gifts',
        name: 'Gifts',
        iconCodePoint: Icons.card_giftcard.codePoint,
        colorValue: const Color(0xFFFFAFCC).toARGB32(),
      ),
      Category(
        id: 'other',
        name: 'Other',
        iconCodePoint: Icons.more_horiz.codePoint,
        colorValue: const Color(0xFF6C757D).toARGB32(),
      ),
    ];
  }

  // Color palette
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFFEC4899);

  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
