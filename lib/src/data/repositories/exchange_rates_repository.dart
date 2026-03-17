import 'package:currency_converter_app/src/core/app_error.dart';
import 'package:currency_converter_app/src/data/api/exchange_rates_api.dart';
import 'package:currency_converter_app/src/data/cache/rates_cache.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:currency_converter_app/src/config/env.dart';

class ExchangeRatesRepository {
  ExchangeRatesRepository({
    required ExchangeRatesDataSource api,
    required RatesCache cache,
  })
      : _api = api,
        _cache = cache;

  final ExchangeRatesDataSource _api;
  final RatesCache _cache;

  static const Duration cacheTtl = Duration(hours: 6);

  Future<void> setApiKey(String apiKey) => _cache.writeApiKey(apiKey);

  Future<String?> getSavedApiKey() => _cache.readApiKey();

  Future<String> _resolveApiKey() async {
    final fromDefine = Env.apilayerApiKey.trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    final saved = (await _cache.readApiKey())?.trim() ?? '';
    if (saved.isNotEmpty) return saved;
    throw const MissingApiKeyError();
  }

  Future<List<CurrencySymbol>> getSymbols({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.readSymbols();
      if (cached != null && cached.isNotEmpty) return cached;
    }

    try {
      final apiKey = await _resolveApiKey();
      final symbols = await _api.fetchSymbols(apiKey: apiKey);
      await _cache.writeSymbols(symbols);
      return symbols;
    } catch (e) {
      final cached = await _cache.readSymbols();
      if (cached != null && cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<String> getBaseCurrency({String defaultValue = 'USD'}) async {
    final cached = await _cache.readBaseCurrency();
    if (cached != null && cached.trim().isNotEmpty) return cached;
    return defaultValue;
  }

  Future<void> setBaseCurrency(String code) => _cache.writeBaseCurrency(code);

  Future<ExchangeRates> getLatestRates({
    required String baseCurrency,
    bool forceRefresh = false,
  }) async {
    final cached = await _cache.readLatest(baseCurrency: baseCurrency);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isFresh = cached != null &&
        Duration(milliseconds: nowMs - cached.fetchedAtMs) <= cacheTtl;

    if (!forceRefresh && isFresh) {
      return cached.latest;
    }

    try {
      final apiKey = await _resolveApiKey();
      final latest =
          await _api.fetchLatest(apiKey: apiKey, baseCurrency: baseCurrency);
      await _cache.writeLatest(
        CachedLatestRates(fetchedAtMs: nowMs, latest: latest),
      );
      return latest;
    } catch (e) {
      if (cached != null) return cached.latest;
      if (e is AppError) rethrow;
      throw NetworkError('Failed to fetch latest rates.');
    }
  }
}
