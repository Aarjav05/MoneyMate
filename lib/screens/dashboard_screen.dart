import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import '../widgets/empty_state.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _makeSlide(double begin, double end) {
    return Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Animation<double> _makeFade(double begin, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
  }

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

            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Greeting header
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _staggerController,
                      builder: (context, child) {
                        final fade = _makeFade(0.0, 0.3);
                        final slide = _makeSlide(0.0, 0.3);
                        return Opacity(
                          opacity: fade.value,
                          child: Transform.translate(
                            offset: Offset(0, slide.value),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: AppConstants.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '💰',
                                      style: TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Helpers.getGreeting(),
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        Helpers.formatMonthYear(DateTime.now()),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Balance hero card
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _staggerController,
                      builder: (context, child) {
                        final fade = _makeFade(0.1, 0.4);
                        final slide = _makeSlide(0.1, 0.4);
                        return Opacity(
                          opacity: fade.value,
                          child: Transform.translate(
                            offset: Offset(0, slide.value),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                                Color(0xFFA78BFA),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      Helpers.formatMonthYear(DateTime.now()),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    size: 28,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Total Balance',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Helpers.formatCurrency(
                                    provider.balanceConverted,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Glassmorphic divider
                              Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              const SizedBox(height: 16),
                              // Income/Expense row
                              Row(
                                children: [
                                  _BalanceDetail(
                                    icon: Icons.arrow_downward_rounded,
                                    label: 'Income',
                                    amount: Helpers.formatCurrencyCompact(
                                      provider.totalIncomeConverted,
                                    ),
                                    iconColor: const Color(0xFF34D399),
                                  ),
                                  const Spacer(),
                                  _BalanceDetail(
                                    icon: Icons.arrow_upward_rounded,
                                    label: 'Expenses',
                                    amount: Helpers.formatCurrencyCompact(
                                      provider.totalExpensesConverted,
                                    ),
                                    iconColor: const Color(0xFFFCA5A5),
                                    alignRight: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Quick actions row
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _staggerController,
                      builder: (context, child) {
                        final fade = _makeFade(0.25, 0.5);
                        final slide = _makeSlide(0.25, 0.5);
                        return Opacity(
                          opacity: fade.value,
                          child: Transform.translate(
                            offset: Offset(0, slide.value),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'Income',
                                amount: Helpers.formatCurrencyCompact(
                                  provider.totalIncomeConverted,
                                ),
                                icon: Icons.trending_up_rounded,
                                gradient: AppConstants.incomeGradient,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: SummaryCard(
                                title: 'Expenses',
                                amount: Helpers.formatCurrencyCompact(
                                  provider.totalExpensesConverted,
                                ),
                                icon: Icons.trending_down_rounded,
                                gradient: AppConstants.expenseGradient,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recent Transactions header
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _staggerController,
                      builder: (context, child) {
                        final fade = _makeFade(0.4, 0.65);
                        return Opacity(opacity: fade.value, child: child);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: theme.textTheme.headlineMedium,
                            ),
                            if (recentTransactions.isNotEmpty)
                              TextButton.icon(
                                onPressed: () {
                                  // Could navigate; handled by bottom nav
                                },
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('See All'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Transaction list or empty state
                  if (recentTransactions.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: EmptyState(
                          icon: Icons.receipt_long,
                          title: 'No transactions yet',
                          message:
                              'Tap the + button to add your first transaction',
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

                        return AnimatedBuilder(
                          animation: _staggerController,
                          builder: (context, child) {
                            final start = 0.5 + (index * 0.06);
                            final end = (start + 0.2).clamp(0.0, 1.0);
                            final fade = _makeFade(start, end);
                            final slide = _makeSlide(start, end);
                            return Opacity(
                              opacity: fade.value,
                              child: Transform.translate(
                                offset: Offset(0, slide.value),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: TransactionCard(
                              transaction: transaction,
                              category: category,
                              onTap: () {
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
                            ),
                          ),
                        );
                      }, childCount: recentTransactions.length),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BalanceDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color iconColor;
  final bool alignRight;

  const _BalanceDetail({
    required this.icon,
    required this.label,
    required this.amount,
    required this.iconColor,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!alignRight)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        if (!alignRight) const SizedBox(width: 10),
        Column(
          crossAxisAlignment: alignRight
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (alignRight) const SizedBox(width: 10),
        if (alignRight)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
      ],
    );
  }
}
