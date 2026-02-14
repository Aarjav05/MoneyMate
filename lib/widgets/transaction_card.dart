import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../utils/helpers.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.category,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense
        ? theme.colorScheme.error
        : const Color(0xFF10B981);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: Text('Delete "${transaction.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.error.withValues(alpha: 0.1),
              theme.colorScheme.error.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: theme.colorScheme.error),
            const SizedBox(height: 2),
            Text(
              'Delete',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon with gradient background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (category?.color ?? theme.colorScheme.primary)
                            .withValues(alpha: 0.15),
                        (category?.color ?? theme.colorScheme.primary)
                            .withValues(alpha: 0.25),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    category?.icon ?? Icons.help_outline,
                    color: category?.color ?? theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            category?.icon ?? Icons.label,
                            size: 13,
                            color:
                                category?.color ??
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.6,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category?.name ?? 'Unknown',
                            style: theme.textTheme.bodySmall,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color:
                                  theme.textTheme.bodySmall?.color?.withValues(
                                    alpha: 0.4,
                                  ) ??
                                  Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            Helpers.formatDate(transaction.date),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: amountColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isExpense ? '-' : '+'}${_formatAmount()}',
                        style: TextStyle(
                          color: amountColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (transaction.currencyCode != 'INR')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          transaction.currencyCode,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount() {
    final currency = StorageService.currenciesBox.get(transaction.currencyCode);
    return Helpers.formatCurrencyWithCode(
      transaction.amount,
      transaction.currencyCode,
      currency,
    );
  }
}
