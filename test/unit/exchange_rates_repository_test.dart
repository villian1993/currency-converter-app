import 'package:currency_converter_app/src/data/api/exchange_rates_api.dart';
import 'package:currency_converter_app/src/data/cache/rates_cache.dart';
import 'package:currency_converter_app/src/data/repositories/exchange_rates_repository.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:flutter_test/flutter_test.dart';

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
  test('uses cache for symbols after first fetch', () async {
    final api = FakeDataSource();
    final cache = MemoryRatesCache();
    final repo = ExchangeRatesRepository(api: api, cache: cache);
    await repo.setApiKey('test-key');

    final first = await repo.getSymbols();
    final second = await repo.getSymbols();

    expect(first.length, 2);
    expect(second.length, 2);
    expect(api.symbolsCalls, 1);
  });

  test('uses cache for latest rates when fresh', () async {
    final api = FakeDataSource();
    final cache = MemoryRatesCache();
    final repo = ExchangeRatesRepository(api: api, cache: cache);
    await repo.setApiKey('test-key');

    final first = await repo.getLatestRates(baseCurrency: 'USD');
    final second = await repo.getLatestRates(baseCurrency: 'USD');

    expect(first.base, 'USD');
    expect(second.base, 'USD');
    expect(api.latestCalls, 1);
  });
}
