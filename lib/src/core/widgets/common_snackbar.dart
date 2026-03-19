import 'package:currency_converter_app/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String msg, {Color? bg}) {
  // If the context is already unmounted, don’t proceed
  if (!context.mounted) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Double-check again inside the frame callback (context may change)
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar() // optional: hides existing ones
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            backgroundColor: bg ?? AppColors.primary,
            content: Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  });
}