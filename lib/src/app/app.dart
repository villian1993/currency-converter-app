import 'package:currency_converter_app/src/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.main,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}