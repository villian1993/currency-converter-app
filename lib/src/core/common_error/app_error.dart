sealed class AppError implements Exception {
  const AppError(this.message);
  final String message;

  @override
  String toString() => message;
}

// API Key Missing
class MissingApiKeyError extends AppError {
  const MissingApiKeyError()
      : super(
    'App setup incomplete. Please try again later or contact support.',
  );
}

//  Network Issues
class NetworkError extends AppError {
  const NetworkError([String? msg])
      : super(
    msg ??
        'No internet connection. Please check your network and try again.',
  );
}

// Invalid Amount
class InvalidAmountError extends AppError {
  const InvalidAmountError()
      : super(
    'Please enter a valid amount (e.g. 100 or 100.50).',
  );
}

// Unsupported Currency
class UnsupportedCurrencyError extends AppError {
  const UnsupportedCurrencyError(String code)
      : super(
    'Currency "$code" is not supported. Please select another currency.',
  );
}
