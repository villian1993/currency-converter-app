import '../models/multi_currency_input.dart';

class InputValidator {
  static Map<String, String?> validate(List<MultiCurrencyInput> inputs) {
    final errors = <String, String?>{};

    for (final input in inputs) {
      final value = input.amountText.trim();

      if (value.isEmpty) {
        errors[input.id] = 'Please enter amount';
      } else {
        final parsed = double.tryParse(value);

        if (parsed == null) {
          errors[input.id] = 'Enter valid number (e.g. 100.50)';
        } else if (parsed <= 0) {
          errors[input.id] = 'Amount must be greater than 0';
        } else if (parsed > 1000000000) {
          errors[input.id] = 'Amount too large';
        } else if (!_isValidDecimal(value)) {
          errors[input.id] = 'Max 2 decimal places allowed';
        }
      }
    }

    return errors;
  }

  static bool _isValidDecimal(String value) {
    final regex = RegExp(r'^\d+(\.\d{1,2})?$');
    return regex.hasMatch(value);
  }
}
