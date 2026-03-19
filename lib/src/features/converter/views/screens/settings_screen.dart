import 'package:currency_converter_app/src/app/providers.dart';
import 'package:currency_converter_app/src/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_font.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../app/routes/app_routes.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(converterViewModelProvider);
    return Scaffold(
      appBar: const CustomAppBar(
        titleText: 'Settings',
        showBackButton: true,
        showTitleIcon: true,
        titleIcon: Icon(Icons.settings),
      ),
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (vmState) => Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Base Currency
                    InkWell(
                      onTap: () async {
                        if (vmState.symbols.isEmpty) return;
        
                        final picked = await Navigator.of(context).pushNamed<String>(
                          AppRoutes.currencies,
                          arguments: {
                            'isBase': true,
                            'selectedCode': vmState.baseCurrency,
                          },
                        );
        
                        if (picked != null) {
                          await ref
                              .read(converterViewModelProvider.notifier)
                              .setBaseCurrency(picked);
                        }
                      },
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.language, size: 20),
        
                            const SizedBox(width: 12),
        
                            // Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    'Base Currency',
                                    themeTextStyle:
                                    Theme.of(context).textTheme.bodyMedium,
                                    fontWeight: AppFont.manropeSemiBold,
                                    color: AppColors.lightBlackTextColor,
                                    fontSize: 14,
                                  ),
                                  const SizedBox(height: 2),
                                  AppText(
                                    vmState.baseCurrency,
                                    themeTextStyle:
                                    Theme.of(context).textTheme.bodySmall,
                                    fontWeight: AppFont.manropeRegular,
                                    color: AppColors.darkGrayColor,
                                    fontSize: 12,
                                  ),
                                ],
                              ),
                            ),
        
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
                      ),
                    ),
        
                    // Tip Card
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightCL,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          'Tip: You can pull-to-refresh on the main screens to refresh symbols.',
                          themeTextStyle: Theme.of(context).textTheme.bodySmall,
                          fontWeight: AppFont.manropeRegular,
                          color: AppColors.darkGrayColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


