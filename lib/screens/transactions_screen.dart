import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/empty_state.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, TransactionProvider provider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final currentFilter = provider.currentFilter;
      provider.setFilter(currentFilter.copyWith(searchQuery: query));
    });
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final result = await showModalBottomSheet<TransactionFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          FilterBottomSheet(currentFilter: provider.currentFilter),
    );

    if (result != null) {
      provider.setFilter(result);
    }
  }

  Future<void> _refreshData(TransactionProvider provider) async {
    await Future.delayed(const Duration(seconds: 1));
    // Data automatically refreshes through provider
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final transactions =
                provider.filteredTransactions.isNotEmpty ||
                    provider.currentFilter.hasActiveFilters
                ? provider.filteredTransactions
                : provider.allTransactions;

            final groupedTransactions = _groupByDate(transactions);
            final filterCount = provider.currentFilter.activeFilterCount;

            return RefreshIndicator(
              onRefresh: () => _refreshData(provider),
              child: CustomScrollView(
                slivers: [
                  // App Bar with Search
                  SliverAppBar(
                    expandedHeight: _showSearch ? 180 : 120,
                    floating: true,
                    pinned: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(
                        left: 20,
                        bottom: _showSearch ? 120 : 60,
                      ),
                      title: Text(
                        'Transactions',
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    actions: [
                      // Search Icon
                      IconButton(
                        icon: Icon(_showSearch ? Icons.close : Icons.search),
                        onPressed: () {
                          setState(() {
                            _showSearch = !_showSearch;
                            if (!_showSearch) {
                              _searchController.clear();
                              provider.setFilter(
                                provider.currentFilter.copyWith(
                                  clearSearch: true,
                                ),
                              );
                            }
                          });
                        },
                      ),
                      // Filter Icon with Badge
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () => _showFilterSheet(context),
                          ),
                          if (filterCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$filterCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(_showSearch ? 108 : 48),
                      child: Column(
                        children: [
                          // Search Bar
                          if (_showSearch)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search transactions...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            provider.setFilter(
                                              provider.currentFilter.copyWith(
                                                clearSearch: true,
                                              ),
                                            );
                                          },
                                        )
                                      : null,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onChanged: (value) =>
                                    _onSearchChanged(value, provider),
                              ),
                            ),
                          // Type Filter Chips
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'All',
                                  isSelected:
                                      provider.currentFilter.type == null,
                                  onTap: () {
                                    provider.setFilter(
                                      provider.currentFilter.copyWith(
                                        clearType: true,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Income',
                                  isSelected:
                                      provider.currentFilter.type ==
                                      TransactionType.income,
                                  onTap: () {
                                    provider.setFilter(
                                      provider.currentFilter.copyWith(
                                        type: TransactionType.income,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Expenses',
                                  isSelected:
                                      provider.currentFilter.type ==
                                      TransactionType.expense,
                                  onTap: () {
                                    provider.setFilter(
                                      provider.currentFilter.copyWith(
                                        type: TransactionType.expense,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Active Filters Indicator
                  if (filterCount > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Chip(
                          label: Text(
                            '$filterCount active filter${filterCount > 1 ? 's' : ''}',
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            provider.clearFilters();
                          },
                        ),
                      ),
                    ),

                  // Transactions List
                  if (transactions.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyState(
                        icon: provider.currentFilter.hasActiveFilters
                            ? Icons.search_off
                            : Icons.receipt_long,
                        title: provider.currentFilter.hasActiveFilters
                            ? 'No Results'
                            : 'No Transactions',
                        message: provider.currentFilter.hasActiveFilters
                            ? 'Try adjusting your filters'
                            : 'Add your first transaction to get started',
                      ),
                    )
                  else
                    ...groupedTransactions.entries
                        .map((entry) {
                          return [
                            // Date header
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  20,
                                  20,
                                  8,
                                ),
                                child: Text(
                                  _formatDateHeader(entry.key),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Transactions for this date
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final transaction = entry.value[index];
                                final category = provider.getCategoryById(
                                  transaction.categoryId,
                                );

                                return TransactionCard(
                                  transaction: transaction,
                                  category: category,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddTransactionScreen(
                                              transaction: transaction,
                                            ),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    provider.deleteTransaction(transaction.id);
                                  },
                                );
                              }, childCount: entry.value.length),
                            ),
                          ];
                        })
                        .expand((element) => element),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Map<DateTime, List<Transaction>> _groupByDate(
    List<Transaction> transactions,
  ) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (var transaction in transactions) {
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

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
