import 'package:currency_converter_app/src/core/app_error.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:dio/dio.dart';

abstract class ExchangeRatesDataSource {
  Future<List<CurrencySymbol>> fetchSymbols({required String apiKey});
  Future<ExchangeRates> fetchLatest({
    required String apiKey,
    required String baseCurrency,
  });
}

class ExchangeRatesApi implements ExchangeRatesDataSource {
  ExchangeRatesApi({required Dio dio, required String baseUrl})
    : _dio = dio,
      _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  @override
  Future<List<CurrencySymbol>> fetchSymbols({required String apiKey}) async {
    if (apiKey.trim().isEmpty) {
      throw const MissingApiKeyError();
    }

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/symbols',
        options: Options(headers: {'apikey': apiKey}),
      );
      final decoded = res.data;
      final symbols = decoded?['symbols'] as Map<String, dynamic>?;
      if (symbols == null) {
        throw const NetworkError('Invalid symbols response.');
      }

      final list =
          symbols.entries
              .map(
                (e) => CurrencySymbol(
                  code: e.key,
                  name: (e.value ?? '').toString(),
                ),
              )
              .toList()
            ..sort((a, b) => a.code.compareTo(b.code));
      return list;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      throw NetworkError('Failed to fetch symbols (${code ?? 'network'}).');
    }
  }

  @override
  Future<ExchangeRates> fetchLatest({
    required String apiKey,
    required String baseCurrency,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const MissingApiKeyError();
    }

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/latest',
        queryParameters: {'base': baseCurrency},
        options: Options(headers: {'apikey': apiKey}),
      );
      final decoded = res.data;
      if (decoded == null) {
        throw const NetworkError('Invalid latest response.');
      }
      final base = (decoded['base'] ?? '').toString();
      final date = (decoded['date'] ?? '').toString();
      final ratesDynamic = decoded['rates'];
      if (base.isEmpty || ratesDynamic is! Map) {
        throw const NetworkError('Invalid latest response.');
      }
      final rates = <String, double>{};
      for (final entry in ratesDynamic.entries) {
        final code = entry.key.toString();
        final value = entry.value;
        final d = value is num ? value.toDouble() : double.tryParse('$value');
        if (d != null) {
          rates[code] = d;
        }
      }

      return ExchangeRates(base: base, date: date, rates: rates);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      throw NetworkError(
        'Failed to fetch latest rates (${code ?? 'network'}).',
      );
    }
  }
}
