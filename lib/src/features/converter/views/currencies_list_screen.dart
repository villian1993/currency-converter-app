import 'package:currency_converter_app/src/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrenciesListScreen extends ConsumerStatefulWidget {
  const CurrenciesListScreen({super.key});

  static const routeName = '/currencies';

  @override
  ConsumerState<CurrenciesListScreen> createState() =>
      _CurrenciesListScreenState();
}

class _CurrenciesListScreenState extends ConsumerState<CurrenciesListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(converterViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Currencies')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (vmState) {
          final symbols = vmState.symbols.where((s) {
            if (_query.trim().isEmpty) return true;
            final q = _query.toLowerCase();
            return s.code.toLowerCase().contains(q) ||
                s.name.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: symbols.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final s = symbols[index];
                    return ListTile(
                      title: Text('${s.code} — ${s.name}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
