import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class Budget extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late double limit;

  @HiveField(3)
  late BudgetPeriod period;

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.period,
  });

  // Calculate remaining budget based on spent amount
  double getRemaining(double spent) {
    return limit - spent;
  }

  // Get percentage of budget used
  double getPercentage(double spent) {
    if (limit == 0) return 0;
    return (spent / limit) * 100;
  }

  // Check if budget is exceeded
  bool isExceeded(double spent) {
    return spent > limit;
  }

  // Create a copy with modifications
  Budget copyWith({
    String? id,
    String? categoryId,
    double? limit,
    BudgetPeriod? period,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      period: period ?? this.period,
    );
  }
}

@HiveType(typeId: 4)
enum BudgetPeriod {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  yearly,
}
