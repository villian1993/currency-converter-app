import 'package:currency_converter_app/src/core/connectivity/network_issue_providers.dart';
import 'package:currency_converter_app/src/core/connectivity/no_internet_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InternetPopupGate extends ConsumerStatefulWidget {
  const InternetPopupGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InternetPopupGate> createState() => _InternetPopupGateState();
}

class _InternetPopupGateState extends ConsumerState<InternetPopupGate> {
  bool _sheetShown = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(effectiveIsOnlineProvider, (prev, next) async {
      if (!mounted) return;
      if (next == false && _sheetShown == false) {
        _sheetShown = true;
        await _showNoInternetSheet(context);
      }
    });

    return widget.child;
  }

  Future<void> _showNoInternetSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoInternetBottomSheet(
        onRetry: () {
          ref.read(dioNoInternetFlagProvider.notifier).state = false;
          Navigator.of(context).pop();
        },
      ),
    );
    if (!mounted) return;
    _sheetShown = false;
  }
}
