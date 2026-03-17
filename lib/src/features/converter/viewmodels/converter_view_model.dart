import 'package:currency_converter_app/src/app/providers.dart';
import 'package:currency_converter_app/src/core/app_error.dart';
import 'package:currency_converter_app/src/data/repositories/exchange_rates_repository.dart';
import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:currency_converter_app/src/features/converter/models/multi_currency_input.dart';
import 'package:currency_converter_app/src/features/converter/services/converter_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConverterState {
  const ConverterState({
    required this.baseCurrency,
    required this.symbols,
    required this.inputs,
    required this.isBusy,
    this.normalizedTotal,
    this.lastRatesDate,
    this.message,
  });

  final String baseCurrency;
  final List<CurrencySymbol> symbols;
  final List<MultiCurrencyInput> inputs;
  final bool isBusy;
  final double? normalizedTotal;
  final String? lastRatesDate;
  final String? message;

  ConverterState copyWith({
    String? baseCurrency,
    List<CurrencySymbol>? symbols,
    List<MultiCurrencyInput>? inputs,
    bool? isBusy,
    double? normalizedTotal,
    String? lastRatesDate,
    String? message,
  }) =>
      ConverterState(
        baseCurrency: baseCurrency ?? this.baseCurrency,
        symbols: symbols ?? this.symbols,
        inputs: inputs ?? this.inputs,
        isBusy: isBusy ?? this.isBusy,
        normalizedTotal: normalizedTotal ?? this.normalizedTotal,
        lastRatesDate: lastRatesDate ?? this.lastRatesDate,
        message: message,
      );
}

class ConverterViewModel extends AsyncNotifier<ConverterState> {
  final ConverterCalculator _calculator = ConverterCalculator();

  ExchangeRatesRepository get _repository =>
      ref.read(exchangeRatesRepositoryProvider);

  @override
  Future<ConverterState> build() async {
    final baseCurrency = await _repository.getBaseCurrency(defaultValue: 'USD');
    try {
      final symbols = await _repository.getSymbols();
      return ConverterState(
        baseCurrency: baseCurrency,
        symbols: symbols,
        inputs: _ensureInputsValid(
          inputs: const [
            MultiCurrencyInput(id: '0', currencyCode: 'USD', amountText: ''),
          ],
          symbols: symbols,
        ),
        isBusy: false,
      );
    } catch (e) {
      if (e is MissingApiKeyError || e is NetworkError) {
        final symbols = _fallbackSymbols;
        return ConverterState(
          baseCurrency: baseCurrency,
          symbols: symbols,
          inputs: _ensureInputsValid(
            inputs: const [
              MultiCurrencyInput(id: '0', currencyCode: 'USD', amountText: ''),
            ],
            symbols: symbols,
          ),
          isBusy: false,
          message: (e is AppError) ? e.message : e.toString(),
        );
      }
      rethrow;
    }
  }

  Future<void> refreshSymbols() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(isBusy: true, message: null));
    try {
      final symbols = await _repository.getSymbols(forceRefresh: true);
      state = AsyncData(
        current.copyWith(
          symbols: symbols,
          inputs: _ensureInputsValid(inputs: current.inputs, symbols: symbols),
          isBusy: false,
          message: null,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isBusy: false,
          message: (e is AppError) ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> setBaseCurrency(String code) async {
    final current = state.valueOrNull;
    if (current == null || code == current.baseCurrency) return;

    state = AsyncData(
      current.copyWith(
        baseCurrency: code,
        normalizedTotal: null,
        lastRatesDate: null,
        message: null,
      ),
    );
    await _repository.setBaseCurrency(code);
  }

  void addCurrencyField() {
    final current = state.valueOrNull;
    if (current == null) return;
    final defaultCode =
        current.symbols.isNotEmpty ? current.symbols.first.code : 'USD';
    final newId = DateTime.now().microsecondsSinceEpoch.toString();
    state = AsyncData(
      current.copyWith(
        inputs: [
          ...current.inputs,
          MultiCurrencyInput(
            id: newId,
            currencyCode: defaultCode,
            amountText: '',
          ),
        ],
        message: null,
      ),
    );
  }

  void removeCurrencyField(String id) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.inputs.length <= 1) return;
    state = AsyncData(
      current.copyWith(
        inputs: current.inputs.where((e) => e.id != id).toList(),
        message: null,
      ),
    );
  }

  void updateAmount(String id, String amountText) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        inputs: current.inputs
            .map((e) => e.id == id ? e.copyWith(amountText: amountText) : e)
            .toList(),
        message: null,
      ),
    );
  }

  void updateCurrency(String id, String currencyCode) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        inputs: current.inputs
            .map((e) =>
                e.id == id ? e.copyWith(currencyCode: currencyCode) : e)
            .toList(),
        message: null,
      ),
    );
  }

  Future<void> calculateTotal() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(isBusy: true, message: null));
    try {
      final latest =
          await _repository.getLatestRates(baseCurrency: current.baseCurrency);
      final total = _calculator.calculateTotalInBase(
        inputs: current.inputs,
        baseCurrency: current.baseCurrency,
        latest: latest,
      );
      state = AsyncData(
        current.copyWith(
          isBusy: false,
          normalizedTotal: total,
          lastRatesDate: latest.date,
          message: null,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isBusy: false,
          message: (e is AppError) ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) {
      state = AsyncData(current.copyWith(message: 'API key cannot be empty.'));
      return;
    }

    await _repository.setApiKey(trimmed);
    state = AsyncData(current.copyWith(message: 'API key saved.'));
  }

  void clearMessage() {
    final current = state.valueOrNull;
    if (current == null || current.message == null) return;
    state = AsyncData(current.copyWith(message: null));
  }

  static List<MultiCurrencyInput> _ensureInputsValid({
    required List<MultiCurrencyInput> inputs,
    required List<CurrencySymbol> symbols,
  }) {
    if (symbols.isEmpty) return inputs;
    final codes = symbols.map((e) => e.code).toSet();
    final fallback = symbols.first.code;
    return inputs
        .map((e) => codes.contains(e.currencyCode)
            ? e
            : e.copyWith(currencyCode: fallback))
        .toList();
  }

  static const List<CurrencySymbol> _fallbackSymbols = [
    CurrencySymbol(code: 'USD', name: 'United States Dollar'),
    CurrencySymbol(code: 'EUR', name: 'Euro'),
    CurrencySymbol(code: 'GBP', name: 'British Pound Sterling'),
    CurrencySymbol(code: 'INR', name: 'Indian Rupee'),
    CurrencySymbol(code: 'JPY', name: 'Japanese Yen'),
    CurrencySymbol(code: 'AUD', name: 'Australian Dollar'),
    CurrencySymbol(code: 'CAD', name: 'Canadian Dollar'),
    CurrencySymbol(code: 'CHF', name: 'Swiss Franc'),
    CurrencySymbol(code: 'CNY', name: 'Chinese Yuan'),
    CurrencySymbol(code: 'HKD', name: 'Hong Kong Dollar'),
    CurrencySymbol(code: 'NZD', name: 'New Zealand Dollar'),
    CurrencySymbol(code: 'SEK', name: 'Swedish Krona'),
    CurrencySymbol(code: 'NOK', name: 'Norwegian Krone'),
    CurrencySymbol(code: 'DKK', name: 'Danish Krone'),
    CurrencySymbol(code: 'SGD', name: 'Singapore Dollar'),
    CurrencySymbol(code: 'ZAR', name: 'South African Rand'),
    CurrencySymbol(code: 'AED', name: 'United Arab Emirates Dirham'),
    CurrencySymbol(code: 'SAR', name: 'Saudi Riyal'),
    CurrencySymbol(code: 'BRL', name: 'Brazilian Real'),
    CurrencySymbol(code: 'MXN', name: 'Mexican Peso'),
  ];
}
