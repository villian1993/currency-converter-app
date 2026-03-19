import 'package:currency_converter_app/src/core/common_error/app_error.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/exchange_rates.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

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
        throw const NetworkError('Invalid response from server.');
      }

      return symbols.entries
          .map(
            (e) =>
                CurrencySymbol(code: e.key, name: (e.value ?? '').toString()),
          )
          .toList()
        ..sort((a, b) => a.code.compareTo(b.code));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkError('Request timed out. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkError('No internet connection.');
      }

      final statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        throw const MissingApiKeyError();
      } else if (statusCode != null && statusCode >= 500) {
        throw const NetworkError('Server error. Please try again later.');
      }

      throw const NetworkError('Unable to fetch currency list.');
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
        throw const NetworkError('Invalid response from server.');
      }

      final base = (decoded['base'] ?? '').toString();
      final date = (decoded['date'] ?? '').toString();
      final ratesDynamic = decoded['rates'];

      if (base.isEmpty || ratesDynamic is! Map) {
        throw const NetworkError('Invalid response format.');
      }

      final rates = <String, double>{};

      for (final entry in ratesDynamic.entries) {
        final value = entry.value;
        final d = value is num ? value.toDouble() : double.tryParse('$value');
        if (d != null) {
          rates[entry.key.toString()] = d;
        }
      }

      return ExchangeRates(base: base, date: date, rates: rates);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkError('Request timed out. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkError('No internet connection.');
      }

      final statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        throw const MissingApiKeyError();
      } else if (statusCode != null && statusCode >= 500) {
        throw const NetworkError('Server error. Please try again later.');
      }

      throw const NetworkError('Unable to fetch exchange rates.');
    }
  }
}
