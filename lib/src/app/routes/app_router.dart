import 'package:flutter/material.dart';
import '../../features/converter/views/screens/currencies_list_screen.dart';
import '../../features/converter/views/screens/main_screen.dart';
import '../../features/converter/views/screens/settings_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.currencies:
        final args = settings.arguments;
        Map<String, dynamic> safeArgs = {};
        if (args is Map<String, dynamic>) {
          safeArgs = args;
        }
        return MaterialPageRoute<String>(
          builder: (_) => CurrenciesListScreen(
            isBaseSelection: safeArgs['isBase'] ?? false,
            selectedCode: safeArgs['selectedCode'] ?? '',
            viewOnly: safeArgs['viewOnly'] ?? false,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('No route found'))),
        );
    }
  }
}
