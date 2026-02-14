import '../models/transaction.dart';

class TransactionFilter {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final List<String>? categoryIds;
  final TransactionType? type;

  TransactionFilter({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.categoryIds,
    this.type,
  });

  // Check if any filters are active
  bool get hasActiveFilters {
    return searchQuery != null ||
        startDate != null ||
        endDate != null ||
        minAmount != null ||
        maxAmount != null ||
        (categoryIds != null && categoryIds!.isNotEmpty) ||
        type != null;
  }

  // Count active filters
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (startDate != null || endDate != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (categoryIds != null && categoryIds!.isNotEmpty) count++;
    if (type != null) count++;
    return count;
  }

  // Create a copy with modifications
  TransactionFilter copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    List<String>? categoryIds,
    TransactionType? type,
    bool clearSearch = false,
    bool clearDates = false,
    bool clearAmounts = false,
    bool clearCategories = false,
    bool clearType = false,
  }) {
    return TransactionFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      minAmount: clearAmounts ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmounts ? null : (maxAmount ?? this.maxAmount),
      categoryIds: clearCategories ? null : (categoryIds ?? this.categoryIds),
      type: clearType ? null : (type ?? this.type),
    );
  }

  // Clear all filters
  static TransactionFilter empty() {
    return TransactionFilter();
  }
}
