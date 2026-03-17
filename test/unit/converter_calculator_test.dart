import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:currency_converter_app/src/features/converter/models/multi_currency_input.dart';
import 'package:currency_converter_app/src/features/converter/services/converter_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates normalized total in base currency', () {
    final calc = ConverterCalculator();
    final latest = ExchangeRates(
      base: 'USD',
      date: '2026-03-17',
      rates: {
        'EUR': 0.5, // 1 USD = 0.5 EUR => 1 EUR = 2 USD
        'INR': 80.0, // 1 USD = 80 INR => 1 INR = 0.0125 USD
      },
    );

    final total = calc.calculateTotalInBase(
      baseCurrency: 'USD',
      latest: latest,
      inputs: const [
        MultiCurrencyInput(id: 'a', currencyCode: 'EUR', amountText: '10'),
        MultiCurrencyInput(id: 'b', currencyCode: 'USD', amountText: '5'),
        MultiCurrencyInput(id: 'c', currencyCode: 'INR', amountText: '160'),
      ],
    );

    // 10 EUR -> 20 USD, + 5 USD, + 160 INR -> 2 USD
    expect(total, closeTo(27.0, 1e-9));
  });
}
