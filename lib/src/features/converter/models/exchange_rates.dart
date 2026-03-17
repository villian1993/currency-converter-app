class ExchangeRates {
  const ExchangeRates({
    required this.base,
    required this.date,
    required this.rates,
  });

  final String base;
  final String date;
  final Map<String, double> rates;

  Map<String, Object?> toJson() => {
        'base': base,
        'date': date,
        'rates': rates,
      };

  static ExchangeRates? fromJson(Map<String, dynamic> json) {
    final base = json['base'];
    final date = json['date'];
    final ratesJson = json['rates'];
    if (base is! String || date is! String || ratesJson is! Map) return null;
    final rates = <String, double>{};
    for (final entry in ratesJson.entries) {
      final code = entry.key.toString();
      final value = entry.value;
      final d = value is num ? value.toDouble() : double.tryParse('$value');
      if (d != null) rates[code] = d;
    }
    return ExchangeRates(base: base, date: date, rates: rates);
  }
}

