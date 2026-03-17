import 'package:currency_converter_app/src/features/converter/models/multi_currency_input.dart';
import 'package:flutter/material.dart';

class MultiCurrencyRow extends StatelessWidget {
  const MultiCurrencyRow({
    super.key,
    required this.input,
    required this.onPickCurrency,
    required this.onAmountChanged,
    required this.onRemove,
    required this.canRemove,
  });

  final MultiCurrencyInput input;
  final VoidCallback onPickCurrency;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: onPickCurrency,
              icon: const Icon(Icons.currency_exchange),
              label: Text(input.currencyCode),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                key: ValueKey('amount_${input.id}'),
                initialValue: input.amountText,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                onChanged: onAmountChanged,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: canRemove ? onRemove : null,
              tooltip: 'Remove',
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
