import 'package:currency_converter_app/src/app/providers.dart';
import 'package:currency_converter_app/src/core/widgets/custom_app_bar.dart';
import 'package:currency_converter_app/src/app/routes/app_routes.dart';
import 'package:currency_converter_app/src/features/converter/views/widgets/multi_currency_row.dart';
import 'package:currency_converter_app/src/features/converter/views/widgets/result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_font.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/common_snackbar.dart';
import '../../utils/input_validator.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final Map<String, String?> _errors = {};
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  Widget build(BuildContext context) {
    ref.listen(converterViewModelProvider, (prev, next) {
      final prevMsg = prev?.valueOrNull?.message;
      final nextMsg = next.valueOrNull?.message;

      if (nextMsg == null || nextMsg.isEmpty) return;
      if (nextMsg == prevMsg) return;

      showCustomSnackBar(context, nextMsg);

      ref.read(converterViewModelProvider.notifier).clearMessage();
    });

    final asyncState = ref.watch(converterViewModelProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        SystemNavigator.pop(); // exit app
      },
      child: Scaffold(
        appBar: CustomAppBar(
          titleText: 'Currency Converter',
          hideHomeButton: true,
          showTitleIcon: true,
          titleIcon: const Icon(Icons.currency_exchange),
          actions: [
            IconButton(
              tooltip: 'Currencies',
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.currencies,
                  arguments: {
                    'isBase': false,
                    'selectedCode': '',
                    'viewOnly': true,
                  },
                );
              },
              icon: const Icon(Icons.list),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: SafeArea(
          child: asyncState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (vmState) {
              return RefreshIndicator(
                onRefresh: () => ref
                    .read(converterViewModelProvider.notifier)
                    .refreshSymbols(),
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    // Top Info Card
                    Container(
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
                      child: Row(
                        children: [
                          AppText(
                            'Base Currency',
                            themeTextStyle: Theme.of(
                              context,
                            ).textTheme.bodyMedium,
                            fontWeight: AppFont.manropeSemiBold,
                            color: AppColors.lightBlackTextColor,
                            fontSize: 14,
                          ),
                          const SizedBox(width: 8),

                          // Chip styled better
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightCL,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AppText(
                              vmState.baseCurrency,
                              fontWeight: AppFont.manropeBold,
                              fontSize: 13,
                            ),
                          ),

                          const Spacer(),

                          if (vmState.isBusy)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Info Text
                    AppText(
                      'Enter amounts in different currencies and calculate total in base currency.',
                      themeTextStyle: Theme.of(context).textTheme.bodySmall,
                      fontWeight: AppFont.manropeRegular,
                      color: AppColors.darkGrayColor,
                      fontSize: 12,
                    ),

                    const SizedBox(height: 12),

                    // Input Card
                    Container(
                      padding: const EdgeInsets.all(8),
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
                        children: [
                          ...vmState.inputs.map((input) {
                            _itemKeys.putIfAbsent(input.id, () => GlobalKey());

                            return Container(
                              key: _itemKeys[input.id],
                              child: MultiCurrencyRow(
                                input: input,
                                errorText: _errors[input.id],
                                canRemove: vmState.inputs.length > 1,

                                onPickCurrency: () async {
                                  final picked = await Navigator.of(context)
                                      .pushNamed<String>(
                                        AppRoutes.currencies,
                                        arguments: {
                                          'isBase': false,
                                          'selectedCode': input.currencyCode,
                                        },
                                      );

                                  if (picked != null) {
                                    ref
                                        .read(
                                          converterViewModelProvider.notifier,
                                        )
                                        .updateCurrency(input.id, picked);
                                  }
                                },

                                onAmountChanged: (v) {
                                  ref
                                      .read(converterViewModelProvider.notifier)
                                      .updateAmount(input.id, v);

                                  // remove error instantly
                                  if (_errors.containsKey(input.id)) {
                                    _errors.remove(input.id);
                                    setState(() {});
                                  }
                                },

                                onRemove: () => ref
                                    .read(converterViewModelProvider.notifier)
                                    .removeCurrencyField(input.id),
                              ),
                            );
                          }),

                          const SizedBox(height: 8),

                          // ➕ Add Currency
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () => ref
                                  .read(converterViewModelProvider.notifier)
                                  .addCurrencyField(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add, size: 18),
                                  const SizedBox(width: 4),
                                  AppText(
                                    'Add Currency',
                                    fontWeight: AppFont.manropeSemiBold,
                                    fontSize: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: vmState.isBusy
                            ? null
                            : () async {
                                final validationErrors =
                                    InputValidator.validate(vmState.inputs);

                                setState(() {
                                  _errors
                                    ..clear()
                                    ..addAll(validationErrors);
                                });

                                if (_errors.isNotEmpty) return;

                                final notifier = ref.read(
                                  converterViewModelProvider.notifier,
                                );

                                await notifier.calculateTotal();

                                notifier.clearAllAmounts();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: AppText(
                          'Calculate Total',
                          themeTextStyle: Theme.of(
                            context,
                          ).textTheme.bodyMedium,
                          fontWeight: AppFont.manropeSemiBold,
                          color: AppColors.card,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Result Card
                    ResultCard(
                      baseCurrency: vmState.baseCurrency,
                      total: vmState.normalizedTotal,
                      lastRatesDate: vmState.lastRatesDate,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
