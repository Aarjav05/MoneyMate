import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/spending_pie_chart.dart';
import '../utils/helpers.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

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

            // Build category maps
            for (var categoryId in spendingByCategory.keys) {
              final category = provider.getCategoryById(categoryId);
              if (category != null) {
                categoryColors[categoryId] = category.color;
                categoryNames[categoryId] = category.name;
              }
            }

            // Sort spending by amount
            final sortedSpending = spendingByCategory.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 80,
                  floating: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: Text(
                      'Statistics',
                      style: theme.textTheme.displaySmall,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Period Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            Helpers.formatMonthYear(DateTime.now()),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Summary Stats
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total Income',
                                value: Helpers.formatCurrency(
                                  provider.totalIncome,
                                ),
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Total Expenses',
                                value: Helpers.formatCurrency(
                                  provider.totalExpenses,
                                ),
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Spending Chart Title
                        Text(
                          'Spending by Category',
                          style: theme.textTheme.headlineMedium,
                        ),

                        const SizedBox(height: 16),

                        // Pie Chart
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SpendingPieChart(
                              categorySpending: spendingByCategory,
                              categoryColors: categoryColors,
                              categoryNames: categoryNames,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Top Spending Categories
                        Text(
                          'Top Spending Categories',
                          style: theme.textTheme.headlineMedium,
                        ),

                        const SizedBox(height: 16),

                        if (sortedSpending.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    size: 64,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No expenses this month',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...sortedSpending.take(5).map((entry) {
                            final category = provider.getCategoryById(
                              entry.key,
                            );
                            final percentage = Helpers.calculatePercentage(
                              entry.value,
                              provider.totalExpenses,
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: category?.color.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            category?.icon,
                                            color: category?.color,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            category?.name ?? 'Unknown',
                                            style: theme.textTheme.titleMedium,
                                          ),
                                        ),
                                        Text(
                                          Helpers.formatCurrency(entry.value),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: category?.color
                                          .withOpacity(0.2),
                                      color: category?.color,
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${percentage.toStringAsFixed(1)}% of total expenses',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
