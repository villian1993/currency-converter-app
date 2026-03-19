import 'dart:io';
import 'package:currency_converter_app/src/core/common_error/app_error.dart';
import 'package:currency_converter_app/src/data/api/exchange_rates_api.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/config/api_config.dart';
import 'package:dio/dio.dart';
import '../../features/converter/models/exchange_rates.dart';
import '../../core/network/network_checker.dart';
import '../cache/rates_cache.dart';

class ExchangeRatesRepository {
  ExchangeRatesRepository({
    required ExchangeRatesDataSource api,
    required RatesCache cache,
    required ApiConfig config,
  }) : _api = api,
       _cache = cache,
       _config = config;

  final ExchangeRatesDataSource _api;
  final RatesCache _cache;
  final ApiConfig _config;

  static const Duration cacheTtl = Duration(minutes: 6);

  // Get Currency Symbols
  Future<List<CurrencySymbol>> getSymbols({bool forceRefresh = false}) async {
    // 1. Try cache first
    if (!forceRefresh) {
      final cached = await _cache.readSymbols();
      if (cached != null && cached.isNotEmpty) return cached;
    }

    //2. Check internet BEFORE API call
    final hasInternet = await NetworkChecker.isConnected();

    if (!hasInternet) {
      final cached = await _cache.readSymbols();

      if (cached != null && cached.isNotEmpty) {
        // UX: return cached data (offline mode)
        return cached;
      }

      // No cache + no internet
      throw const NetworkError();
    }

    // 3. Call API
    try {
      final apiKey = _config.apiKey;
      final symbols = await _api.fetchSymbols(apiKey: apiKey);

      await _cache.writeSymbols(symbols);
      return symbols;
    } on DioException catch (_) {
      final cached = await _cache.readSymbols();
      if (cached != null && cached.isNotEmpty) return cached;

      throw const NetworkError();
    } on SocketException {
      final cached = await _cache.readSymbols();
      if (cached != null && cached.isNotEmpty) return cached;

      throw const NetworkError();
    } catch (e) {
      final cached = await _cache.readSymbols();
      if (cached != null && cached.isNotEmpty) return cached;

      if (e is AppError) rethrow;
      throw const NetworkError();
    }
  }

  // Get Base Currency
  Future<String> getBaseCurrency({String defaultValue = 'USD'}) async {
    final cached = await _cache.readBaseCurrency();
    if (cached != null && cached.trim().isNotEmpty) {
      return cached;
    }
    return defaultValue;
  }

  // Set Base Currency
  Future<void> setBaseCurrency(String code) async {
    await _cache.writeBaseCurrency(code);
  }

  // Get Latest Exchange Rates
  Future<ExchangeRates> getLatestRates({
    required String baseCurrency,
    bool forceRefresh = false,
  }) async {
    final cached = await _cache.readLatest(baseCurrency: baseCurrency);

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final isFresh =
        cached != null &&
        Duration(milliseconds: nowMs - cached.fetchedAtMs) <= cacheTtl;

    // USE CACHE FIRST
    if (!forceRefresh && isFresh) {
      return cached.latest;
    }

    // CHECK INTERNET BEFORE API CALL
    final hasInternet = await NetworkChecker.isConnected();

    if (!hasInternet) {
      if (cached != null) {
        // UX: show cached data
        throw const NetworkError();
      }
      throw const NetworkError();
    }

    try {
      final apiKey = _config.apiKey;

      final latest = await _api.fetchLatest(
        apiKey: apiKey,
        baseCurrency: baseCurrency,
      );

      await _cache.writeLatest(
        CachedLatestRates(fetchedAtMs: nowMs, latest: latest),
      );

      return latest;
    } on DioException catch (_) {
      if (cached != null) return cached.latest;
      throw const NetworkError();
    } on SocketException {
      if (cached != null) return cached.latest;
      throw const NetworkError();
    } catch (e) {
      if (cached != null) return cached.latest;
      if (e is AppError) rethrow;
      throw const NetworkError();
    }
  }
}
