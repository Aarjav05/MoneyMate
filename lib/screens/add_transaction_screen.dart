import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/category.dart' as models;
import '../models/currency.dart';
import '../providers/transaction_provider.dart';
import '../services/storage_service.dart';
import '../widgets/category_icon.dart';
import '../widgets/currency_picker.dart';
import '../utils/helpers.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late TransactionType _type;
  models.Category? _selectedCategory;
  Currency? _selectedCurrency;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();

    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _notesController.text = widget.transaction!.notes ?? '';
      _type = widget.transaction!.type;
      _selectedDate = widget.transaction!.date;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<TransactionProvider>(
          context,
          listen: false,
        );
        _selectedCategory = provider.getCategoryById(
          widget.transaction!.categoryId,
        );
        setState(() {});
      });
    } else {
      _type = TransactionType.expense;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedCurrency = StorageService.currenciesBox.get('INR');
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final amount = double.parse(_amountController.text);

    try {
      if (widget.transaction != null) {
        await provider.updateTransaction(
          widget.transaction!.copyWith(
            title: _titleController.text,
            amount: amount,
            categoryId: _selectedCategory!.id,
            date: _selectedDate,
            type: _type,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          ),
        );
      } else {
        await provider.addTransaction(
          title: _titleController.text,
          amount: amount,
          categoryId: _selectedCategory!.id,
          date: _selectedDate,
          type: _type,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          currencyCode: _selectedCurrency?.code ?? 'INR',
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAnimatedSection({
    required double start,
    required double end,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, c) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );
        final slide = Tween<double>(begin: 20, end: 0).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        );
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(offset: Offset(0, slide.value), child: c),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'New Transaction'),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final categories = provider.categories;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Selector
                    _buildAnimatedSection(
                      start: 0.0,
                      end: 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TypeButton(
                                label: 'Expense',
                                icon: Icons.arrow_upward_rounded,
                                isSelected: _type == TransactionType.expense,
                                color: theme.colorScheme.error,
                                onTap: () => setState(
                                  () => _type = TransactionType.expense,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _TypeButton(
                                label: 'Income',
                                icon: Icons.arrow_downward_rounded,
                                isSelected: _type == TransactionType.income,
                                color: const Color(0xFF10B981),
                                onTap: () => setState(
                                  () => _type = TransactionType.income,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Amount
                    _buildAnimatedSection(
                      start: 0.08,
                      end: 0.38,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixIcon: Container(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  '₹',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Amount must be greater than 0';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    _buildAnimatedSection(
                      start: 0.15,
                      end: 0.45,
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g., Grocery Shopping',
                          prefixIcon: Icon(Icons.edit_outlined, size: 20),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date & Currency row
                    _buildAnimatedSection(
                      start: 0.22,
                      end: 0.52,
                      child: Row(
                        children: [
                          // Date
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                  ),
                                ),
                                child: Text(Helpers.formatDate(_selectedDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Currency
                          if (_selectedCurrency != null)
                            Expanded(
                              child: CurrencyPicker(
                                selectedCurrency: _selectedCurrency,
                                onChanged: (currency) {
                                  setState(() {
                                    _selectedCurrency = currency;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Category Selector
                    _buildAnimatedSection(
                      start: 0.3,
                      end: 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CATEGORY',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 14,
                            children: categories.map((
                              models.Category category,
                            ) {
                              final isSelected =
                                  _selectedCategory?.id == category.id;
                              return GestureDetector(
                                onTap: () => setState(
                                  () => _selectedCategory = category,
                                ),
                                child: Column(
                                  children: [
                                    CategoryIcon(
                                      icon: category.icon,
                                      color: category.color,
                                      isSelected: isSelected,
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 64,
                                      child: Text(
                                        category.name,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? category.color
                                                  : null,
                                            ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notes
                    _buildAnimatedSection(
                      start: 0.4,
                      end: 0.7,
                      child: TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Add any additional details',
                          prefixIcon: Icon(Icons.notes_outlined, size: 20),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Save Button
                    _buildAnimatedSection(
                      start: 0.5,
                      end: 0.8,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _saveTransaction,
                          icon: Icon(
                            isEditing ? Icons.check_rounded : Icons.add_rounded,
                          ),
                          label: Text(
                            isEditing
                                ? 'Update Transaction'
                                : 'Add Transaction',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.4), width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
