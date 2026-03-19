import 'package:currency_converter_app/src/config/native_api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiConfig {
  final String baseUrl;
  final String apiKey;

  ApiConfig({
    required this.baseUrl,
    required this.apiKey,
  });
}

final apiConfigProvider = Provider<ApiConfig>((ref) {
  final baseUrl = NativeApiConfig.baseUrl?.trim() ?? '';
  final apiKey = NativeApiConfig.apiKey?.trim() ?? '';

  if (baseUrl.isEmpty) {
    throw Exception('Base URL not found in FFI');
  }

  if (apiKey.isEmpty) {
    throw Exception('API Key not found in FFI');
  }

  return ApiConfig(
    baseUrl: baseUrl,
    apiKey: apiKey,
  );
});
