import 'package:currency_converter_app/src/data/api/exchange_rates_api.dart';
import 'package:currency_converter_app/src/data/cache/rates_cache.dart';
import 'package:currency_converter_app/src/data/repositories/exchange_rates_repository.dart';
import 'package:currency_converter_app/src/config/api_config.dart';
import 'package:currency_converter_app/src/features/converter/viewmodels/converter_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    ),
  );

  return dio;
});

final exchangeRatesApiProvider = Provider<ExchangeRatesDataSource>((ref) {
  final config = ref.watch(apiConfigProvider);
  return ExchangeRatesApi(
    dio: ref.watch(dioProvider),
    baseUrl: config.baseUrl,
  );
});

final ratesCacheProvider = Provider<RatesCache>((ref) {
  return SharedPreferencesRatesCache();
});

final exchangeRatesRepositoryProvider = Provider<ExchangeRatesRepository>((ref) {
  final api = ref.watch(exchangeRatesApiProvider);
  final cache = ref.watch(ratesCacheProvider);
  final config = ref.watch(apiConfigProvider);

  return ExchangeRatesRepository(
    api: api,
    cache: cache,
    config: config,
  );
});

final converterViewModelProvider =
    AsyncNotifierProvider<ConverterViewModel, ConverterState>(
      ConverterViewModel.new,
    );
