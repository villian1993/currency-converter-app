import 'package:currency_converter_app/src/app/providers.dart';
import 'package:currency_converter_app/src/data/api/exchange_rates_api.dart';
import 'package:currency_converter_app/src/data/cache/rates_cache.dart';
import 'package:currency_converter_app/src/data/repositories/exchange_rates_repository.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeDataSource implements ExchangeRatesDataSource {
  @override
  Future<List<CurrencySymbol>> fetchSymbols({required String apiKey}) async {
    return const [
      CurrencySymbol(code: 'USD', name: 'United States Dollar'),
      CurrencySymbol(code: 'EUR', name: 'Euro'),
    ];
  }

  @override
  Future<ExchangeRates> fetchLatest({
    required String apiKey,
    required String baseCurrency,
  }) async {
    return ExchangeRates(
      base: baseCurrency,
      date: '2026-03-17',
      rates: const {'USD': 1, 'EUR': 0.5},
    );
  }
}

void main() {
  test('initializes with symbols and base currency', () async {
    final repo = ExchangeRatesRepository(
      api: FakeDataSource(),
      cache: MemoryRatesCache(),
    );
    await repo.setApiKey('test-key');
    final container = ProviderContainer(
      overrides: [
        exchangeRatesRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final vmState = await container.read(converterViewModelProvider.future);
    expect(vmState.symbols.isNotEmpty, true);
    expect(vmState.baseCurrency, 'USD');
  });

  test('calculates normalized total', () async {
    final repo = ExchangeRatesRepository(
      api: FakeDataSource(),
      cache: MemoryRatesCache(),
    );
    await repo.setApiKey('test-key');
    final container = ProviderContainer(
      overrides: [
        exchangeRatesRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(converterViewModelProvider.future);
    final notifier = container.read(converterViewModelProvider.notifier);
    notifier.updateCurrency('0', 'EUR');
    notifier.updateAmount('0', '10');

    await notifier.calculateTotal();

    final vmState = container.read(converterViewModelProvider).valueOrNull;
    expect(vmState?.normalizedTotal, closeTo(20.0, 1e-9));
  });
}
