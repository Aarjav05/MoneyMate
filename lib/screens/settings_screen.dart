import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text('Settings', style: theme.textTheme.displaySmall),
              ),
            ),

            // Profile card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('💰', style: TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MoneyMate User',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Personal Finance',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Preferences
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Preferences'),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return _SettingsTile(
                                icon: themeProvider.isDarkMode
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                iconColor: themeProvider.isDarkMode
                                    ? const Color(0xFFA78BFA)
                                    : const Color(0xFFF59E0B),
                                title: 'Dark Mode',
                                subtitle: themeProvider.isDarkMode
                                    ? 'Currently using dark theme'
                                    : 'Currently using light theme',
                                trailing: Switch.adaptive(
                                  value: themeProvider.isDarkMode,
                                  onChanged: (value) {
                                    themeProvider.toggleTheme();
                                  },
                                  activeTrackColor: theme.colorScheme.primary,
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

            // Data
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Data Management'),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.delete_sweep_rounded,
                            iconColor: theme.colorScheme.error,
                            title: 'Clear All Transactions',
                            subtitle: 'Delete all transaction data',
                            onTap: () => _showClearDataDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // About
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'About'),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.info_outline_rounded,
                            iconColor: theme.colorScheme.primary,
                            title: 'Version',
                            subtitle: '1.0.0',
                          ),
                          Divider(
                            height: 1,
                            indent: 60,
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                          _SettingsTile(
                            icon: Icons.description_outlined,
                            iconColor: const Color(0xFF10B981),
                            title: 'About MoneyMate',
                            onTap: () => _showAboutInfo(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Transactions'),
        content: const Text(
          'Are you sure you want to delete all transactions? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () {
              Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).clearAllTransactions();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All transactions cleared'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAboutInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MoneyMate',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('💰', style: TextStyle(fontSize: 24))),
      ),
      children: [
        const Text(
          'A beautiful personal finance tracker built with Flutter. '
          'Track your income and expenses, visualize spending patterns, '
          'and manage your budget with ease.',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.brightness == Brightness.dark
              ? const Color(0xFFF1F5F9)
              : const Color(0xFF1E293B),
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: theme.textTheme.bodySmall?.color,
                )
              : null),
    );
  }
}
