import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../providers/transaction_provider.dart';
import '../utils/helpers.dart';

class FilterBottomSheet extends StatefulWidget {
  final TransactionFilter currentFilter;

  const FilterBottomSheet({super.key, required this.currentFilter});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late TransactionFilter _filter;
  DateTime? _startDate;
  DateTime? _endDate;
  double _minAmount = 0;
  double _maxAmount = 100000;
  List<String> _selectedCategories = [];
  TransactionType? _selectedType;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _startDate = _filter.startDate;
    _endDate = _filter.endDate;
    _minAmount = _filter.minAmount ?? 0;
    _maxAmount = _filter.maxAmount ?? 100000;
    _selectedCategories = _filter.categoryIds ?? [];
    _selectedType = _filter.type;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final categories = provider.categories;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Date Range
          Text(
            'Date Range',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _startDate == null
                        ? 'Start Date'
                        : Helpers.formatDate(_startDate!),
                  ),
                  onPressed: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _endDate == null
                        ? 'End Date'
                        : Helpers.formatDate(_endDate!),
                  ),
                  onPressed: () => _pickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Amount Range
          Text(
            'Amount Range',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(Helpers.formatCurrency(_minAmount)),
              Expanded(
                child: RangeSlider(
                  values: RangeValues(_minAmount, _maxAmount),
                  min: 0,
                  max: 100000,
                  divisions: 100,
                  labels: RangeLabels(
                    Helpers.formatCurrency(_minAmount),
                    Helpers.formatCurrency(_maxAmount),
                  ),
                  onChanged: (values) {
                    setState(() {
                      _minAmount = values.start;
                      _maxAmount = values.end;
                    });
                  },
                ),
              ),
              Text(Helpers.formatCurrency(_maxAmount)),
            ],
          ),
          const SizedBox(height: 24),

          // Transaction Type
          Text(
            'Transaction Type',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SegmentedButton<TransactionType?>(
            segments: const [
              ButtonSegment(value: null, label: Text('All')),
              ButtonSegment(
                value: TransactionType.income,
                label: Text('Income'),
              ),
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('Expense'),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (Set<TransactionType?> selected) {
              setState(() {
                _selectedType = selected.first;
              });
            },
          ),
          const SizedBox(height: 24),

          // Categories
          Text(
            'Categories',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = _selectedCategories.contains(category.id);
              return FilterChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category.id);
                    } else {
                      _selectedCategories.remove(category.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _applyFilters,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Apply Filters'),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minAmount = 0;
      _maxAmount = 100000;
      _selectedCategories = [];
      _selectedType = null;
    });
  }

  void _applyFilters() {
    final filter = TransactionFilter(
      startDate: _startDate,
      endDate: _endDate,
      minAmount: _minAmount > 0 ? _minAmount : null,
      maxAmount: _maxAmount < 100000 ? _maxAmount : null,
      categoryIds: _selectedCategories.isNotEmpty ? _selectedCategories : null,
      type: _selectedType,
    );

    Navigator.pop(context, filter);
  }
}
