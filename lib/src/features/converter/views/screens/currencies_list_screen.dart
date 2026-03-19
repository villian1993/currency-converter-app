import 'package:currency_converter_app/src/app/providers.dart';
import 'package:currency_converter_app/src/core/widgets/app_text.dart';
import 'package:currency_converter_app/src/core/widgets/common_gradient_divider.dart';
import 'package:currency_converter_app/src/core/widgets/custom_app_bar.dart';
import 'package:currency_converter_app/src/features/converter/views/widgets/currency_search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_font.dart';


class CurrenciesListScreen extends ConsumerStatefulWidget {
  const CurrenciesListScreen({
    super.key,
    required this.isBaseSelection,
    required this.selectedCode,
    this.viewOnly = false,
  });

  final bool isBaseSelection;
  final String selectedCode;
  final bool viewOnly;

  @override
  ConsumerState<CurrenciesListScreen> createState() =>
      _CurrenciesListScreenState();
}

class _CurrenciesListScreenState
    extends ConsumerState<CurrenciesListScreen> {
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(converterViewModelProvider);

    return Scaffold(
      appBar: CustomAppBar(
        titleText: widget.isBaseSelection
            ? 'Select Base Currency'
            : 'Select Currency',
        showBackButton: true,
        showTitleIcon: true,
        titleIcon: Icon(Icons.currency_exchange),
      ),
      backgroundColor: AppColors.lightScreenBackgroundColor,
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (vmState) {
            final filtered = vmState.symbols.where((s) {
              if (_query.trim().isEmpty) return true;
              final q = _query.toLowerCase();
              return s.code.toLowerCase().contains(q) ||
                  s.name.toLowerCase().contains(q);
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(12),
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
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // SEARCH
                      CurrencySearchBox(
                        controller: _searchController,
                        title: "Search Currency",
                        onSearchPressed: () {},
                        onSearchChanged: (value) {
                          setState(() => _query = value);
                        },
                      ),

                      const SizedBox(height: 8),

                      // LIST
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                          const GradientDivider(),
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            final selectedCode = widget.isBaseSelection
                                ? vmState.baseCurrency
                                : widget.selectedCode;

                            final isSelected = !widget.viewOnly && s.code == selectedCode;

                            return InkWell(
                              onTap: widget.viewOnly
                                  ? null
                                  : () async {
                                if (widget.isBaseSelection) {
                                  await ref
                                      .read(converterViewModelProvider.notifier)
                                      .setBaseCurrency(s.code);
                                }

                                Navigator.pop(context, s.code);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                color: isSelected
                                    ? AppColors.lightCL
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    // TEXT
                                    Expanded(
                                      child: AppText(
                                        '${s.code} — ${s.name}',
                                        themeTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        fontWeight:
                                        AppFont.manropeSemiBold,
                                        color: AppColors
                                            .lightBlackTextColor,
                                        fontSize: 14,
                                      ),
                                    ),

                                    // SELECTED ICON
                                    if (isSelected)
                                      const Icon(Icons.check, size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
