import 'dart:convert';

import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RatesCache {
  Future<List<CurrencySymbol>?> readSymbols();
  Future<void> writeSymbols(List<CurrencySymbol> symbols);

  Future<String?> readBaseCurrency();
  Future<void> writeBaseCurrency(String code);

  Future<CachedLatestRates?> readLatest({required String baseCurrency});
  Future<void> writeLatest(CachedLatestRates latest);
}

class CachedLatestRates {
  const CachedLatestRates({
    required this.fetchedAtMs,
    required this.latest,
  });

  final int fetchedAtMs;
  final ExchangeRates latest;

  Map<String, Object?> toJson() => {
    'fetchedAtMs': fetchedAtMs,
    'latest': latest.toJson(),
  };

  static CachedLatestRates? fromJson(Map<String, dynamic> json) {
    final fetchedAtMs = json['fetchedAtMs'];
    final latestJson = json['latest'];

    if (fetchedAtMs is! int || latestJson is! Map<String, dynamic>) {
      return null;
    }

    final latest = ExchangeRates.fromJson(latestJson);
    if (latest == null) return null;

    return CachedLatestRates(
      fetchedAtMs: fetchedAtMs,
      latest: latest,
    );
  }
}

class SharedPreferencesRatesCache implements RatesCache {
  static const _symbolsKey = 'symbols.v1';
  static const _baseCurrencyKey = 'baseCurrency.v1';
  static String _latestKey(String base) => 'latest.v1.$base';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<CurrencySymbol>?> readSymbols() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_symbolsKey);
      if (raw == null) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      final out = <CurrencySymbol>[];

      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;

        final symbol = CurrencySymbol.fromJson(item);
        if (symbol != null) out.add(symbol);
      }

      return out.isEmpty ? null : out;
    } catch (_) {
      // Prevent crash on corrupted JSON
      return null;
    }
  }

  @override
  Future<void> writeSymbols(List<CurrencySymbol> symbols) async {
    final prefs = await _prefs;
    await prefs.setString(
      _symbolsKey,
      jsonEncode(symbols.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<String?> readBaseCurrency() async {
    final prefs = await _prefs;
    return prefs.getString(_baseCurrencyKey);
  }

  @override
  Future<void> writeBaseCurrency(String code) async {
    final prefs = await _prefs;
    await prefs.setString(_baseCurrencyKey, code);
  }

  @override
  Future<CachedLatestRates?> readLatest({
    required String baseCurrency,
  }) async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_latestKey(baseCurrency));
      if (raw == null) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      return CachedLatestRates.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeLatest(CachedLatestRates latest) async {
    final prefs = await _prefs;
    await prefs.setString(
      _latestKey(latest.latest.base),
      jsonEncode(latest.toJson()),
    );
  }
}

class MemoryRatesCache implements RatesCache {
  List<CurrencySymbol>? _symbols;
  String? _baseCurrency;
  final Map<String, CachedLatestRates> _latest = {};

  @override
  Future<List<CurrencySymbol>?> readSymbols() async => _symbols;

  @override
  Future<void> writeSymbols(List<CurrencySymbol> symbols) async {
    _symbols = List.unmodifiable(symbols); // safer
  }

  @override
  Future<String?> readBaseCurrency() async => _baseCurrency;

  @override
  Future<void> writeBaseCurrency(String code) async {
    _baseCurrency = code;
  }

  @override
  Future<CachedLatestRates?> readLatest({
    required String baseCurrency,
  }) async {
    return _latest[baseCurrency];
  }

  @override
  Future<void> writeLatest(CachedLatestRates latest) async {
    _latest[latest.latest.base] = latest;
  }
}
