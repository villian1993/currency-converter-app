import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:currency_converter_app/src/features/converter/models/multi_currency_input.dart';
import 'package:currency_converter_app/src/features/converter/services/converter_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates normalized total in base currency', () {
    final calc = ConverterCalculator();
    final latest = ExchangeRates(
      base: 'USD',
      date: '2026-03-17',
      rates: {
        'EUR': 0.5,
        'INR': 80.0,
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

    expect(total, closeTo(27.0, 1e-9));
  });

  test('returns 0 for empty inputs', () {
    final calc = ConverterCalculator();
    final latest = ExchangeRates(
      base: 'USD',
      date: '2026-03-17',
      rates: {},
    );

    final total = calc.calculateTotalInBase(
      baseCurrency: 'USD',
      latest: latest,
      inputs: const [],
    );

    expect(total, 0.0);
  });

  test('handles base currency without conversion', () {
    final calc = ConverterCalculator();
    final latest = ExchangeRates(
      base: 'USD',
      date: '2026-03-17',
      rates: {
        'EUR': 0.5,
      },
    );

    final total = calc.calculateTotalInBase(
      baseCurrency: 'USD',
      latest: latest,
      inputs: const [
        MultiCurrencyInput(id: 'a', currencyCode: 'USD', amountText: '10'),
      ],
    );

    expect(total, 10.0);
  });

  test('handles decimal values correctly', () {
    final calc = ConverterCalculator();
    final latest = ExchangeRates(
      base: 'USD',
      date: '2026-03-17',
      rates: {
        'EUR': 0.5,
      },
    );

    final total = calc.calculateTotalInBase(
      baseCurrency: 'USD',
      latest: latest,
      inputs: const [
        MultiCurrencyInput(id: 'a', currencyCode: 'EUR', amountText: '10.5'),
      ],
    );

    expect(total, closeTo(21.0, 1e-9));
  });

  test('handles large values', () {
    final calc = ConverterCalculator();
    final latest = ExchangeRates(
      base: 'USD',
      date: '2026-03-17',
      rates: {
        'EUR': 0.5,
      },
    );

    final total = calc.calculateTotalInBase(
      baseCurrency: 'USD',
      latest: latest,
      inputs: const [
        MultiCurrencyInput(id: 'a', currencyCode: 'EUR', amountText: '1000000'),
      ],
    );

    expect(total, 2000000.0);
  });

  test('handles missing currency rate safely', () {
    final calc = ConverterCalculator();
    final latest = ExchangeRates(
      base: 'USD',
      date: '2026-03-17',
      rates: {
        'EUR': 0.5,
      },
    );

    final total = calc.calculateTotalInBase(
      baseCurrency: 'USD',
      latest: latest,
      inputs: const [
        MultiCurrencyInput(id: 'a', currencyCode: 'ABC', amountText: '10'),
      ],
    );

    expect(total, isNotNull);
  });
}