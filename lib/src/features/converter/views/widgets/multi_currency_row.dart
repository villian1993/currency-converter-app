import 'package:currency_converter_app/src/features/converter/models/multi_currency_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_font.dart';
import '../../../../core/widgets/app_text.dart';

class MultiCurrencyRow extends StatelessWidget {
  const MultiCurrencyRow({
    super.key,
    required this.input,
    required this.onPickCurrency,
    required this.onAmountChanged,
    required this.onRemove,
    required this.canRemove,
    this.errorText,
  });

  final MultiCurrencyInput input;
  final VoidCallback onPickCurrency;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onRemove;
  final bool canRemove;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;

            // Currency Picker Button
            final currencyButton = InkWell(
              onTap: onPickCurrency,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightCL,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.currency_exchange, size: 16),
                    const SizedBox(width: 6),
                    AppText(
                      input.currencyCode,
                      fontWeight: AppFont.manropeSemiBold,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
            );

            // Amount Field
            final amountField = TextFormField(
              key: ValueKey('amount_${input.id}'),
              initialValue: input.amountText,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),

              // restrict input
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],

              decoration: InputDecoration(
                hintText: 'Enter amount',
                isDense: true,
                errorText: errorText,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onChanged: onAmountChanged,
            );

            // Remove Button
            final removeButton = InkWell(
              onTap: canRemove ? onRemove : null,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: canRemove
                      ? Colors.red.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: canRemove ? Colors.red : Colors.grey,
                ),
              ),
            );

            // Narrow Layout
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      currencyButton,
                      const Spacer(),
                      removeButton,
                    ],
                  ),
                  const SizedBox(height: 10),
                  amountField,
                ],
              );
            }

            // Wide Layout
            return Row(
              children: [
                currencyButton,
                const SizedBox(width: 10),
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
