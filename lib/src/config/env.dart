class Env {
  static const apilayerApiKey = String.fromEnvironment(
    'APILAYER_API_KEY',
    defaultValue: '',
  );

  static const apilayerBaseUrl = String.fromEnvironment(
    'APILAYER_BASE_URL',
    defaultValue: 'https://api.apilayer.com/exchangerates_data',
  );
}
