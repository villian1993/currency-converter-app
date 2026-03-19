import 'package:currency_converter_app/src/app/providers.dart';
import 'package:currency_converter_app/src/config/api_config.dart';
import 'package:currency_converter_app/src/data/api/exchange_rates_api.dart';
import 'package:currency_converter_app/src/data/cache/rates_cache.dart';
import 'package:currency_converter_app/src/data/repositories/exchange_rates_repository.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeApiConfig extends ApiConfig {
  FakeApiConfig()
      : super(
    baseUrl: 'https://test.com',
    apiKey: 'test_key',
  );
}

class FakeDataSource implements ExchangeRatesDataSource {
  int symbolsCalls = 0;
  int latestCalls = 0;

  @override
  Future<List<CurrencySymbol>> fetchSymbols({required String apiKey}) async {
    symbolsCalls++;
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
    latestCalls++;
    return ExchangeRates(
      base: baseCurrency,
      date: '2026-03-17',
      rates: const {'USD': 1, 'EUR': 0.5},
    );
  }
}

void main() {
  group('ConverterViewModel Tests - Extended', () {
    test('duplicate currencies not allowed', () async {
      final repo = ExchangeRatesRepository(
        api: FakeDataSource(),
        cache: MemoryRatesCache(),
        config: FakeApiConfig(),
      );

      final container = ProviderContainer(
        overrides: [
          exchangeRatesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(converterViewModelProvider.future);
      final notifier = container.read(converterViewModelProvider.notifier);

      notifier.updateAmount('0', '10');
      notifier.addCurrencyField();

      final stateBefore = container.read(converterViewModelProvider).value!;
      final secondId = stateBefore.inputs.last.id;

      notifier.updateCurrency(secondId, stateBefore.inputs.first.currencyCode);
      notifier.updateAmount(secondId, '5');

      await notifier.calculateTotal();

      final state = container.read(converterViewModelProvider).valueOrNull;

      expect(state?.message, 'Duplicate currencies not allowed.');
    });

    test('empty amount shows error', () async {
      final repo = ExchangeRatesRepository(
        api: FakeDataSource(),
        cache: MemoryRatesCache(),
        config: FakeApiConfig(),
      );

      final container = ProviderContainer(
        overrides: [
          exchangeRatesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(converterViewModelProvider.future);
      final notifier = container.read(converterViewModelProvider.notifier);

      notifier.updateAmount('0', '');

      await notifier.calculateTotal();

      final state = container.read(converterViewModelProvider).valueOrNull;

      expect(state?.message, 'Amount cannot be empty.');
    });

    test('invalid number shows error', () async {
      final repo = ExchangeRatesRepository(
        api: FakeDataSource(),
        cache: MemoryRatesCache(),
        config: FakeApiConfig(),
      );

      final container = ProviderContainer(
        overrides: [
          exchangeRatesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(converterViewModelProvider.future);
      final notifier = container.read(converterViewModelProvider.notifier);

      notifier.updateAmount('0', 'abc');

      await notifier.calculateTotal();

      final state = container.read(converterViewModelProvider).valueOrNull;

      expect(state?.message, 'Invalid number entered.');
    });

    test('zero or negative amount shows error', () async {
      final repo = ExchangeRatesRepository(
        api: FakeDataSource(),
        cache: MemoryRatesCache(),
        config: FakeApiConfig(),
      );

      final container = ProviderContainer(
        overrides: [
          exchangeRatesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(converterViewModelProvider.future);
      final notifier = container.read(converterViewModelProvider.notifier);

      notifier.updateAmount('0', '0');

      await notifier.calculateTotal();

      final state = container.read(converterViewModelProvider).valueOrNull;

      expect(state?.message, 'Amount must be greater than 0.');
    });

    test('clear message works', () async {
      final repo = ExchangeRatesRepository(
        api: FakeDataSource(),
        cache: MemoryRatesCache(),
        config: FakeApiConfig(),
      );

      final container = ProviderContainer(
        overrides: [
          exchangeRatesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(converterViewModelProvider.future);
      final notifier = container.read(converterViewModelProvider.notifier);

      notifier.updateAmount('0', 'abc');
      await notifier.calculateTotal();

      notifier.clearMessage();

      final state = container.read(converterViewModelProvider).valueOrNull;

      expect(state?.message, null);
    });

    test('add and remove currency fields', () async {
      final repo = ExchangeRatesRepository(
        api: FakeDataSource(),
        cache: MemoryRatesCache(),
        config: FakeApiConfig(),
      );

      final container = ProviderContainer(
        overrides: [
          exchangeRatesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(converterViewModelProvider.future);
      final notifier = container.read(converterViewModelProvider.notifier);

      final before = container.read(converterViewModelProvider).value!.inputs.length;

      notifier.addCurrencyField();
      final afterAdd = container.read(converterViewModelProvider).value!.inputs.length;

      expect(afterAdd, before + 1);

      final lastId = container.read(converterViewModelProvider).value!.inputs.last.id;

      notifier.removeCurrencyField(lastId);

      final afterRemove = container.read(converterViewModelProvider).value!.inputs.length;

      expect(afterRemove, before);
    });

    test('calculates multiple currencies correctly', () async {
      final repo = ExchangeRatesRepository(
        api: FakeDataSource(),
        cache: MemoryRatesCache(),
        config: FakeApiConfig(),
      );

      final container = ProviderContainer(
        overrides: [
          exchangeRatesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(converterViewModelProvider.future);
      final notifier = container.read(converterViewModelProvider.notifier);

      notifier.updateAmount('0', '10');
      notifier.addCurrencyField();

      final state1 = container.read(converterViewModelProvider).value!;
      final secondId = state1.inputs.last.id;

      notifier.updateCurrency(secondId, 'EUR');
      notifier.updateAmount(secondId, '10');

      await notifier.calculateTotal();

      final state = container.read(converterViewModelProvider).valueOrNull;

      expect(state?.normalizedTotal, closeTo(30.0, 1e-9));
    });
  });
}