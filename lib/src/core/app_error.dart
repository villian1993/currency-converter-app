sealed class AppError implements Exception {
  const AppError(this.message);
  final String message;

  @override
  String toString() => message;
}

class MissingApiKeyError extends AppError {
  const MissingApiKeyError()
      : super(
          'Missing API key. Run with --dart-define=APILAYER_API_KEY=YOUR_KEY or add it in Settings.',
        );
}

class NetworkError extends AppError {
  const NetworkError(super.message);
}

class InvalidAmountError extends AppError {
  const InvalidAmountError() : super('Invalid amount. Use numbers only.');
}

class UnsupportedCurrencyError extends AppError {
  const UnsupportedCurrencyError(String code)
      : super('Unsupported currency: $code');
}
