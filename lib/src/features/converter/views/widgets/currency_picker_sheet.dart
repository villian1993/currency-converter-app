import 'package:currency_converter_app/src/features/converter/models/currency_symbol.dart';
import 'package:flutter/material.dart';

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({
    super.key,
    required this.symbols,
    required this.selectedCode,
  });

  final List<CurrencySymbol> symbols;
  final String selectedCode;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.symbols.where((s) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return s.code.toLowerCase().contains(q) || s.name.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search currency',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final symbol = filtered[index];
                  final isSelected = symbol.code == widget.selectedCode;
                  return ListTile(
                    title: Text('${symbol.code} — ${symbol.name}'),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(symbol.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

