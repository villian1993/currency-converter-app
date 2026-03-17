import 'package:currency_converter_app/src/app/providers.dart';
import 'package:currency_converter_app/src/features/converter/views/currencies_list_screen.dart';
import 'package:currency_converter_app/src/features/converter/views/settings_screen.dart';
import 'package:currency_converter_app/src/features/converter/views/widgets/currency_picker_sheet.dart';
import 'package:currency_converter_app/src/features/converter/views/widgets/multi_currency_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(converterViewModelProvider, (prev, next) {
      final prevMsg = prev?.valueOrNull?.message;
      final nextMsg = next.valueOrNull?.message;
      if (nextMsg == null || nextMsg.isEmpty) return;
      if (nextMsg == prevMsg) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(nextMsg)));
      ref.read(converterViewModelProvider.notifier).clearMessage();
    });

    final asyncState = ref.watch(converterViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            tooltip: 'Currencies',
            onPressed: () =>
                Navigator.of(context).pushNamed(CurrenciesListScreen.routeName),
            icon: const Icon(Icons.list),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (vmState) => RefreshIndicator(
          onRefresh: () => ref.read(converterViewModelProvider.notifier).refreshSymbols(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const Text('Base currency:'),
                  const SizedBox(width: 8),
                  Chip(label: Text(vmState.baseCurrency)),
                  const Spacer(),
                  if (vmState.isBusy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Enter amounts in different currencies, then calculate the normalized total in your base currency.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ...vmState.inputs.map(
                (input) => MultiCurrencyRow(
                  input: input,
                  canRemove: vmState.inputs.length > 1,
                  onPickCurrency: () async {
                    if (vmState.symbols.isEmpty) return;
                    final picked = await showModalBottomSheet<String>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (_) => CurrencyPickerSheet(
                        symbols: vmState.symbols,
                        selectedCode: input.currencyCode,
                      ),
                    );
                    if (picked != null) {
                      ref
                          .read(converterViewModelProvider.notifier)
                          .updateCurrency(input.id, picked);
                    }
                  },
                  onAmountChanged: (v) => ref
                      .read(converterViewModelProvider.notifier)
                      .updateAmount(input.id, v),
                  onRemove: () => ref
                      .read(converterViewModelProvider.notifier)
                      .removeCurrencyField(input.id),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () =>
                      ref.read(converterViewModelProvider.notifier).addCurrencyField(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Currency'),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: vmState.isBusy
                    ? null
                    : () => ref
                        .read(converterViewModelProvider.notifier)
                        .calculateTotal(),
                child: const Text('Calculate Total'),
              ),
              const SizedBox(height: 16),
              _ResultCard(
                baseCurrency: vmState.baseCurrency,
                total: vmState.normalizedTotal,
                lastRatesDate: vmState.lastRatesDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.baseCurrency,
    required this.total,
    required this.lastRatesDate,
  });

  final String baseCurrency;
  final double? total;
  final String? lastRatesDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Normalized Total', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              total == null
                  ? '—'
                  : '${total!.toStringAsFixed(2)} $baseCurrency',
              style: theme.textTheme.headlineSmall,
            ),
            if (lastRatesDate != null) ...[
              const SizedBox(height: 6),
              Text(
                'Rates date: $lastRatesDate',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
