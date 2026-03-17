import 'package:currency_converter_app/src/data/api/exchange_rates_api.dart';
import 'package:currency_converter_app/src/data/cache/rates_cache.dart';
import 'package:currency_converter_app/src/data/repositories/exchange_rates_repository.dart';
import 'package:currency_converter_app/src/core/connectivity/network_issue_providers.dart';
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

  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        ref.read(dioNoInternetFlagProvider.notifier).state = false;
        handler.next(response);
      },
      onError: (error, handler) {
        if (_looksLikeNoInternet(error)) {
          ref.read(dioNoInternetFlagProvider.notifier).state = true;
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

bool _looksLikeNoInternet(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return true;
    case DioExceptionType.badResponse:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return false;
  }
}

final exchangeRatesApiProvider = Provider<ExchangeRatesDataSource>((ref) {
  return ExchangeRatesApi(dio: ref.watch(dioProvider));
});

final ratesCacheProvider = Provider<RatesCache>((ref) {
  return SharedPreferencesRatesCache();
});

final exchangeRatesRepositoryProvider = Provider<ExchangeRatesRepository>((ref) {
  return ExchangeRatesRepository(
    api: ref.watch(exchangeRatesApiProvider),
    cache: ref.watch(ratesCacheProvider),
  );
});

final converterViewModelProvider =
    AsyncNotifierProvider<ConverterViewModel, ConverterState>(
  ConverterViewModel.new,
);
