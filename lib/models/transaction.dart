import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String categoryId;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late TransactionType type;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  String currencyCode;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.type,
    this.notes,
    this.currencyCode = 'INR',
  });

  // Helper methods
  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  // Create a copy with modifications
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    TransactionType? type,
    String? notes,
    String? currencyCode,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}
