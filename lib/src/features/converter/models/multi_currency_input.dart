class MultiCurrencyInput {
  const MultiCurrencyInput({
    required this.id,
    required this.currencyCode,
    required this.amountText,
  });

  final String id;
  final String currencyCode;
  final String amountText;

  MultiCurrencyInput copyWith({String? currencyCode, String? amountText}) =>
      MultiCurrencyInput(
        id: id,
        currencyCode: currencyCode ?? this.currencyCode,
        amountText: amountText ?? this.amountText,
      );
}

