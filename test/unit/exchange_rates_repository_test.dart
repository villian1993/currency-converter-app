import 'package:currency_converter_app/src/config/api_config.dart';
import 'package:currency_converter_app/src/data/api/exchange_rates_api.dart';
import 'package:currency_converter_app/src/data/cache/rates_cache.dart';
import 'package:currency_converter_app/src/data/repositories/exchange_rates_repository.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  group('Repository + Cache Tests', () {
    test('uses cache for symbols after first fetch', () async {
      final api = FakeDataSource();
      final cache = MemoryRatesCache();

      final repo = ExchangeRatesRepository(
        api: api,
        cache: cache,
        config: FakeApiConfig(),
      );

      final first = await repo.getSymbols();
      final second = await repo.getSymbols();

      expect(first.length, 2);
      expect(second.length, 2);
      expect(api.symbolsCalls, 1);
    });

    test('uses cache for latest rates when fresh', () async {
      final api = FakeDataSource();
      final cache = MemoryRatesCache();

      final repo = ExchangeRatesRepository(
        api: api,
        cache: cache,
        config: FakeApiConfig(),
      );

      final first = await repo.getLatestRates(baseCurrency: 'USD');
      final second = await repo.getLatestRates(baseCurrency: 'USD');

      expect(first.base, 'USD');
      expect(second.base, 'USD');
      expect(api.latestCalls, 1);
    });

    test('repository writes symbols to cache after fetch', () async {
      final api = FakeDataSource();
      final cache = MemoryRatesCache();

      final repo = ExchangeRatesRepository(
        api: api,
        cache: cache,
        config: FakeApiConfig(),
      );

      await repo.getSymbols();

      final cached = await cache.readSymbols();

      expect(cached?.isNotEmpty, true);
    });

    test('repository caches latest rates per base currency', () async {
      final api = FakeDataSource();
      final cache = MemoryRatesCache();

      final repo = ExchangeRatesRepository(
        api: api,
        cache: cache,
        config: FakeApiConfig(),
      );

      await repo.getLatestRates(baseCurrency: 'USD');
      await repo.getLatestRates(baseCurrency: 'EUR');

      final usd = await cache.readLatest(baseCurrency: 'USD');
      final eur = await cache.readLatest(baseCurrency: 'EUR');

      expect(usd?.latest.base, 'USD');
      expect(eur?.latest.base, 'EUR');
    });
  });

  group('MemoryRatesCache Tests', () {
    test('returns null when empty', () async {
      final cache = MemoryRatesCache();

      expect(await cache.readSymbols(), null);
      expect(await cache.readBaseCurrency(), null);
      expect(await cache.readLatest(baseCurrency: 'USD'), null);
    });

    test('stores and overwrites symbols', () async {
      final cache = MemoryRatesCache();

      await cache.writeSymbols([
        const CurrencySymbol(code: 'USD', name: 'USD'),
      ]);

      await cache.writeSymbols([
        const CurrencySymbol(code: 'EUR', name: 'EUR'),
      ]);

      final result = await cache.readSymbols();

      expect(result?.length, 1);
      expect(result?.first.code, 'EUR');
    });

    test('stores base currency', () async {
      final cache = MemoryRatesCache();

      await cache.writeBaseCurrency('INR');

      final result = await cache.readBaseCurrency();

      expect(result, 'INR');
    });

    test('stores latest rates per base', () async {
      final cache = MemoryRatesCache();

      await cache.writeLatest(
        CachedLatestRates(
          fetchedAtMs: 1,
          latest: ExchangeRates(
            base: 'USD',
            date: '2026-03-17',
            rates: const {'EUR': 0.5},
          ),
        ),
      );

      final result = await cache.readLatest(baseCurrency: 'USD');

      expect(result?.latest.base, 'USD');
    });

    test('overwrites latest for same base currency', () async {
      final cache = MemoryRatesCache();

      await cache.writeLatest(
        CachedLatestRates(
          fetchedAtMs: 1,
          latest: ExchangeRates(
            base: 'USD',
            date: '2026-03-17',
            rates: const {'EUR': 0.4},
          ),
        ),
      );

      await cache.writeLatest(
        CachedLatestRates(
          fetchedAtMs: 2,
          latest: ExchangeRates(
            base: 'USD',
            date: '2026-03-18',
            rates: const {'EUR': 0.5},
          ),
        ),
      );

      final result = await cache.readLatest(baseCurrency: 'USD');

      expect(result?.fetchedAtMs, 2);
    });
  });

  group('SharedPreferences Cache Safety Tests', () {
    test('handles corrupted symbols JSON safely', () async {
      SharedPreferences.setMockInitialValues({
        'symbols.v1': '{invalid json',
      });

      final cache = SharedPreferencesRatesCache();

      final result = await cache.readSymbols();

      expect(result, null);
    });

    test('handles corrupted latest JSON safely', () async {
      SharedPreferences.setMockInitialValues({
        'latest.v1.USD': '{bad json',
      });

      final cache = SharedPreferencesRatesCache();

      final result = await cache.readLatest(baseCurrency: 'USD');

      expect(result, null);
    });
  });
}