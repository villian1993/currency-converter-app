import 'package:currency_converter_app/src/core/app_error.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:currency_converter_app/src/features/converter/models/multi_currency_input.dart';

class ConverterCalculator {
  double calculateTotalInBase({
    required List<MultiCurrencyInput> inputs,
    required String baseCurrency,
    required ExchangeRates latest,
  }) {
    double total = 0;

    for (final input in inputs) {
      final text = input.amountText.trim();
      if (text.isEmpty) continue;
      final amount = double.tryParse(text);
      if (amount == null) {
        throw const InvalidAmountError();
      }
      if (amount == 0) continue;

      if (input.currencyCode == baseCurrency) {
        total += amount;
        continue;
      }

      final rate = latest.rates[input.currencyCode];
      if (rate == null || rate == 0) {
        throw UnsupportedCurrencyError(input.currencyCode);
      }
      total += amount / rate;
    }

    return total;
  }
}
