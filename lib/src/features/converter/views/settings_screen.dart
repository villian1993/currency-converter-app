import 'package:currency_converter_app/src/app/providers.dart';
import 'package:currency_converter_app/src/config/env.dart';
import 'package:currency_converter_app/src/features/converter/views/widgets/currency_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(converterViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (vmState) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('Base currency'),
              subtitle: Text(vmState.baseCurrency),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                if (vmState.symbols.isEmpty) return;
                final picked = await showModalBottomSheet<String>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (_) => CurrencyPickerSheet(
                    symbols: vmState.symbols,
                    selectedCode: vmState.baseCurrency,
                  ),
                );
                if (picked != null) {
                  await ref
                      .read(converterViewModelProvider.notifier)
                      .setBaseCurrency(picked);
                }
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('API key'),
              subtitle: Text(
                Env.apilayerApiKey.trim().isNotEmpty
                    ? 'Using --dart-define'
                    : 'Saved locally (tap to update)',
              ),
              trailing: const Icon(Icons.key),
              onTap: () async {
                final key = await showDialog<String>(
                  context: context,
                  builder: (_) => const _ApiKeyDialog(),
                );
                if (key == null) return;
                await ref
                    .read(converterViewModelProvider.notifier)
                    .saveApiKey(key);
              },
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Tip: You can pull-to-refresh on the main screen to refresh symbols.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog();

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set API key'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'APILayer API key',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
