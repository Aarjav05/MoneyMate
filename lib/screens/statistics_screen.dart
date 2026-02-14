import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/spending_pie_chart.dart';
import '../utils/helpers.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final spendingByCategory = provider.spendingByCategory;
            final categoryColors = <String, Color>{};
            final categoryNames = <String, String>{};

            for (var categoryId in spendingByCategory.keys) {
              final category = provider.getCategoryById(categoryId);
              if (category != null) {
                categoryColors[categoryId] = category.color;
                categoryNames[categoryId] = category.name;
              }
            }

            final sortedSpending = spendingByCategory.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Statistics', style: theme.textTheme.displaySmall),
                        const SizedBox(height: 8),
                        // Period chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                Helpers.formatMonthYear(DateTime.now()),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary stat cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AnimatedStatCard(
                            controller: _animController,
                            delay: 0.0,
                            title: 'Total Income',
                            value: Helpers.formatCurrency(
                              provider.totalIncomeConverted,
                            ),
                            color: const Color(0xFF10B981),
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _AnimatedStatCard(
                            controller: _animController,
                            delay: 0.1,
                            title: 'Total Expenses',
                            value: Helpers.formatCurrency(
                              provider.totalExpensesConverted,
                            ),
                            color: theme.colorScheme.error,
                            icon: Icons.trending_down_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section: Spending by Category
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Text(
                      'Spending by Category',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ),

                // Pie chart card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SpendingPieChart(
                          categorySpending: spendingByCategory,
                          categoryColors: categoryColors,
                          categoryNames: categoryNames,
                        ),
                      ),
                    ),
                  ),
                ),

                // Section: top spending
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: Text(
                      'Top Spending',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ),

                if (sortedSpending.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.08,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bar_chart,
                                size: 48,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No expenses this month',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = sortedSpending[index];
                      final category = provider.getCategoryById(entry.key);
                      final percentage = Helpers.calculatePercentage(
                        entry.value,
                        provider.totalExpensesConverted,
                      );

                      return _AnimatedCategoryRow(
                        controller: _animController,
                        index: index,
                        category: category,
                        amount: entry.value,
                        percentage: percentage,
                      );
                    }, childCount: sortedSpending.length.clamp(0, 6)),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _AnimatedStatCard({
    required this.controller,
    required this.delay,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final end = (delay + 0.4).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(delay, end, curve: Curves.easeOut),
          ),
        );
        final slide = Tween<double>(begin: 24, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(delay, end, curve: Curves.easeOutCubic),
          ),
        );
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(
            offset: Offset(0, slide.value),
            child: child,
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCategoryRow extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final dynamic category;
  final double amount;
  final double percentage;

  const _AnimatedCategoryRow({
    required this.controller,
    required this.index,
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = (0.3 + index * 0.08).clamp(0.0, 0.8);
    final end = (start + 0.3).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );
        final progressAnim = Tween<double>(begin: 0, end: percentage / 100)
            .animate(
              CurvedAnimation(
                parent: controller,
                curve: Interval(start, end, curve: Curves.easeOutCubic),
              ),
            );
        return Opacity(
          opacity: fade.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (category?.color as Color? ?? Colors.grey)
                                    .withValues(alpha: 0.15),
                                (category?.color as Color? ?? Colors.grey)
                                    .withValues(alpha: 0.25),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category?.icon as IconData? ?? Icons.label,
                            color: category?.color as Color? ?? Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category?.name as String? ?? 'Unknown',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFFF1F5F9)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Text(
                          Helpers.formatCurrency(amount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Animated progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressAnim.value,
                        backgroundColor:
                            (category?.color as Color? ?? Colors.grey)
                                .withValues(alpha: 0.1),
                        color: category?.color as Color? ?? Colors.grey,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${percentage.toStringAsFixed(1)}% of total',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
