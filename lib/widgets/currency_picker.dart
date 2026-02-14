import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/storage_service.dart';

class CurrencyPicker extends StatelessWidget {
  final Currency? selectedCurrency;
  final Function(Currency) onChanged;

  const CurrencyPicker({
    super.key,
    this.selectedCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currencies = StorageService.currenciesBox.values.toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Currency>(
        value: selectedCurrency,
        decoration: const InputDecoration(
          labelText: 'Currency',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(Icons.attach_money),
        ),
        items: currencies.map((currency) {
          return DropdownMenuItem<Currency>(
            value: currency,
            child: Row(
              children: [
                Text(
                  currency.symbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  currency.code,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(
                  currency.name,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (currency) {
          if (currency != null) {
            onChanged(currency);
          }
        },
      ),
    );
  }
}
