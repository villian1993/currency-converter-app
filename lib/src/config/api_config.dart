import 'package:currency_converter_app/src/config/env.dart';
import 'package:currency_converter_app/src/config/native_api_config.dart';

enum ApiKeySource { ffi, dartDefine, saved }

class ApiConfig {
  static String get baseUrl =>
      NativeApiConfig.baseUrl?.trim().isNotEmpty == true
      ? NativeApiConfig.baseUrl!.trim()
      : Env.apilayerBaseUrl.trim();

  static String get apiKeyFromDefine => Env.apilayerApiKey.trim();

  static String get apiKeyFromFfi => (NativeApiConfig.apiKey ?? '').trim();

  static ApiKeySource keySource({required bool hasSavedKey}) {
    if (apiKeyFromFfi.isNotEmpty) return ApiKeySource.ffi;
    if (apiKeyFromDefine.isNotEmpty) return ApiKeySource.dartDefine;
    return ApiKeySource.saved;
  }
}
