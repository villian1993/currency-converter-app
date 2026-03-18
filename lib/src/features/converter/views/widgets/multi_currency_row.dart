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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;

            final currencyButton = OutlinedButton.icon(
              onPressed: onPickCurrency,
              icon: const Icon(Icons.currency_exchange),
              label: Text(input.currencyCode),
            );

            final amountField = TextFormField(
              key: ValueKey('amount_${input.id}'),
              initialValue: input.amountText,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              onChanged: onAmountChanged,
            );

            final removeButton = IconButton(
              onPressed: canRemove ? onRemove : null,
              tooltip: 'Remove',
              icon: const Icon(Icons.close),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [currencyButton, const Spacer(), removeButton]),
                  const SizedBox(height: 12),
                  amountField,
                ],
              );
            }

            return Row(
              children: [
                currencyButton,
                const SizedBox(width: 12),
                Expanded(child: amountField),
                const SizedBox(width: 8),
                removeButton,
              ],
            );
          },
        ),
      ),
    );
  }
}
