import 'package:currency_converter_app/src/core/widgets/app_text.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_font.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.baseCurrency,
    required this.total,
    required this.lastRatesDate,
  });

  final String baseCurrency;
  final double? total;
  final String? lastRatesDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Normalized Total',
            themeTextStyle: Theme.of(context).textTheme.bodyMedium,
            fontWeight: AppFont.manropeSemiBold,
            color: AppColors.lightBlackTextColor,
            fontSize: 14,
          ),
          const SizedBox(height: 6),
          AppText(
            total == null ? '—' : '${total!.toStringAsFixed(2)} $baseCurrency',
            themeTextStyle: Theme.of(context).textTheme.bodyMedium,
            fontWeight: AppFont.manropeBold,
            color: AppColors.primary,
          ),
          if (lastRatesDate != null) ...[
            const SizedBox(height: 6),
            AppText(
              'Rates date: $lastRatesDate',
              themeTextStyle: Theme.of(context).textTheme.bodyMedium,
              fontWeight: AppFont.manropeRegular,
              color: AppColors.darkGrayColor,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }
}
