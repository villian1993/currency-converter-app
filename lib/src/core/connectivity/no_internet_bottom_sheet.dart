import 'package:currency_converter_app/src/core/connectivity/connectivity_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoInternetBottomSheet extends ConsumerWidget {
  const NoInternetBottomSheet({
    super.key,
    required this.onRetry,
    this.title = 'No Internet',
    this.message = 'Please check your connection and try again.',
  });

  final VoidCallback onRetry;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            const Icon(Icons.wifi_off, size: 64, color: Colors.black54),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isOnline ? onRetry : null,
                child: const Text('Try Again'),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                isOnline ? 'Back online' : 'Waiting for connection…',
                key: ValueKey(isOnline),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOnline ? Colors.green : Colors.black54,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

