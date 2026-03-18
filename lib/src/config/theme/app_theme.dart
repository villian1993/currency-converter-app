import 'package:currency_converter_app/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light({String? fontFamily}) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        );

    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.textNavyBlue,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: fontFamily == null
          ? base.textTheme
          : base.textTheme.apply(fontFamily: fontFamily),
    );
  }
}
