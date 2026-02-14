import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final recentTransactions = provider.currentMonthTransactions
                .take(5)
                .toList();

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
                      Helpers.getGreeting(),
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
                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'Income',
                                amount: Helpers.formatCurrencyCompact(
                                  provider.totalIncomeConverted,
                                ),
                                icon: Icons.arrow_downward,
                                gradient: AppConstants.incomeGradient,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SummaryCard(
                                title: 'Expenses',
                                amount: Helpers.formatCurrencyCompact(
                                  provider.totalExpensesConverted,
                                ),
                                icon: Icons.arrow_upward,
                                gradient: AppConstants.expenseGradient,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Balance Card
                        SummaryCard(
                          title:
                              'Balance (${Helpers.formatMonthYear(DateTime.now())})',
                          amount: Helpers.formatCurrency(
                            provider.balanceConverted,
                          ),
                          icon: Icons.account_balance_wallet,
                          gradient: AppConstants.primaryGradient,
                        ),

                        const SizedBox(height: 32),

                        // Recent Transactions Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: theme.textTheme.headlineMedium,
                            ),
                            if (recentTransactions.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  // Navigate to transactions tab (we'll handle this in the app.dart)
                                },
                                child: const Text('See All'),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Recent Transactions List
                if (recentTransactions.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 80,
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your first transaction',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final transaction = recentTransactions[index];
                      final category = provider.getCategoryById(
                        transaction.categoryId,
                      );

                      return TransactionCard(
                        transaction: transaction,
                        category: category,
                        onTap: () {
                          // Edit transaction
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTransactionScreen(
                                transaction: transaction,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          provider.deleteTransaction(transaction.id);
                        },
                      );
                    }, childCount: recentTransactions.length),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
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
}
