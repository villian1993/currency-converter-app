import 'package:currency_converter_app/src/features/converter/views/currencies_list_screen.dart';
import 'package:currency_converter_app/src/features/converter/views/main_screen.dart';
import 'package:currency_converter_app/src/features/converter/views/settings_screen.dart';
import 'package:currency_converter_app/src/config/theme/app_theme.dart';
import 'package:currency_converter_app/src/core/connectivity/internet_popup_gate.dart';
import 'package:flutter/material.dart';

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: AppTheme.light(),
      builder: (context, child) =>
          InternetPopupGate(child: child ?? const SizedBox.shrink()),
      routes: {
        '/': (_) => const MainScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        CurrenciesListScreen.routeName: (_) => const CurrenciesListScreen(),
      },
    );
  }
}
