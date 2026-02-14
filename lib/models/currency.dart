import 'package:hive/hive.dart';

part 'currency.g.dart';

@HiveType(typeId: 5)
class Currency extends HiveObject {
  @HiveField(0)
  late String code;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String symbol;

  @HiveField(3)
  late double exchangeRateToINR;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.exchangeRateToINR,
  });

  // Convert amount from this currency to INR
  double toINR(double amount) {
    return amount * exchangeRateToINR;
  }

  // Convert amount from INR to this currency
  double fromINR(double amountInINR) {
    return amountInINR / exchangeRateToINR;
  }

  // Popular currencies with approximate exchange rates (as of 2024)
  static List<Currency> getPopularCurrencies() {
    return [
      Currency(
        code: 'INR',
        name: 'Indian Rupee',
        symbol: '₹',
        exchangeRateToINR: 1.0,
      ),
      Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        exchangeRateToINR: 83.0,
      ),
      Currency(code: 'EUR', name: 'Euro', symbol: '€', exchangeRateToINR: 90.0),
      Currency(
        code: 'GBP',
        name: 'British Pound',
        symbol: '£',
        exchangeRateToINR: 105.0,
      ),
      Currency(
        code: 'AED',
        name: 'UAE Dirham',
        symbol: 'د.إ',
        exchangeRateToINR: 22.6,
      ),
      Currency(
        code: 'SGD',
        name: 'Singapore Dollar',
        symbol: 'S\$',
        exchangeRateToINR: 62.0,
      ),
    ];
  }

  // Find currency by code
  static Currency? findByCode(String code, List<Currency> currencies) {
    try {
      return currencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    double? exchangeRateToINR,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      exchangeRateToINR: exchangeRateToINR ?? this.exchangeRateToINR,
    );
  }
}
