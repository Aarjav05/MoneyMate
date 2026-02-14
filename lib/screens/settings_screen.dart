import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 80,
              floating: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text('Settings', style: theme.textTheme.displaySmall),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance Section
                    Text('Appearance', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),

                    Card(
                      child: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle: const Text(
                              'Toggle between light and dark theme',
                            ),
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                            secondary: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Data Section
                    Text('Data', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),

                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_sweep),
                            title: const Text('Clear All Transactions'),
                            subtitle: const Text('Delete all transaction data'),
                            onTap: () => _showClearDataDialog(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // About Section
                    Text('About', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),

                    Card(
                      child: Column(
                        children: [
                          const ListTile(
                            leading: Icon(Icons.info_outline),
                            title: Text('Version'),
                            subtitle: Text('1.0.0'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: const Text('About MoneyMate'),
                            onTap: () => _showAboutDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
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
          TextButton(
            onPressed: () {
              Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).clearAllTransactions();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All transactions cleared')),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MoneyMate',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
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
