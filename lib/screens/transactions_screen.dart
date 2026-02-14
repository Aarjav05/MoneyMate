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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Transactions',
                              style: theme.textTheme.displaySmall,
                            ),
                          ),
                          // Search toggle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _showSearch
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _showSearch ? Icons.close : Icons.search,
                                color: _showSearch
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
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
                          ),
                          const SizedBox(width: 4),
                          // Filter button with badge
                          Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: filterCount > 0
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.tune_rounded,
                                    color: filterCount > 0
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                  onPressed: () => _showFilterSheet(context),
                                ),
                              ),
                              if (filterCount > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$filterCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search bar (animated)
                  SliverToBoxAdapter(
                    child: AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search transactions...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
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
                          ),
                          onChanged: (value) =>
                              _onSearchChanged(value, provider),
                        ),
                      ),
                      crossFadeState: _showSearch
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: provider.currentFilter.type == null,
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
                            icon: Icons.trending_up_rounded,
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
                            icon: Icons.trending_down_rounded,
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
                  ),

                  // Active filters chip
                  if (filterCount > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                        child: Chip(
                          label: Text(
                            '$filterCount active filter${filterCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            provider.clearFilters();
                          },
                          side: BorderSide.none,
                        ),
                      ),
                    ),

                  // Transaction list
                  if (transactions.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
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
                                  24,
                                  16,
                                  24,
                                  4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatDateHeader(entry.key),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Divider(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Transactions
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final transaction = entry.value[index];
                                final category = provider.getCategoryById(
                                  transaction.categoryId,
                                );

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: TransactionCard(
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
                                      provider.deleteTransaction(
                                        transaction.id,
                                      );
                                    },
                                  ),
                                );
                              }, childCount: entry.value.length),
                            ),
                          ];
                        })
                        .expand((element) => element),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
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
      return 'TODAY';
    } else if (date == yesterday) {
      return 'YESTERDAY';
    } else {
      return '${_getMonthName(date.month).toUpperCase()} ${date.day}, ${date.year}';
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
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
