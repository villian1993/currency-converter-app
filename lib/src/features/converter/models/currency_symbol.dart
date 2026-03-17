class CurrencySymbol {
  const CurrencySymbol({required this.code, required this.name});

  final String code;
  final String name;

  Map<String, Object?> toJson() => {'code': code, 'name': name};

  static CurrencySymbol? fromJson(Map<String, dynamic> json) {
    final code = json['code'];
    final name = json['name'];
    if (code is! String || name is! String) return null;
    return CurrencySymbol(code: code, name: name);
  }
}

