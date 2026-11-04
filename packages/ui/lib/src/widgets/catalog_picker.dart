import 'package:flutter/material.dart';

class CatalogPicker<T extends Object> extends StatelessWidget {
  const CatalogPicker({
    super.key,
    required this.label,
    required this.options,
    required this.name,
    required this.icon,
    required this.onSelected,
    this.initial,
  });

  final String label;
  final List<T> options;
  final String Function(T option) name;
  final Widget Function(T option) icon;
  final ValueChanged<T> onSelected;
  final T? initial;

  Future<void> _choose(BuildContext context) async {
    final chosen = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CatalogSheet<T>(label: label, options: options, name: name, icon: icon),
    );
    if (chosen != null) onSelected(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final initial = this.initial;
    return switch (Theme.of(context).platform) {
      TargetPlatform.android || TargetPlatform.iOS => InkWell(
        onTap: () => _choose(context),
        child: InputDecorator(
          isEmpty: initial == null,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: initial == null ? null : Text(name(initial)),
        ),
      ),
      _ => DropdownMenu<T>(
        label: Text(label),
        initialSelection: initial,
        enableFilter: true,
        expandedInsets: EdgeInsets.zero,
        menuHeight: 320,
        dropdownMenuEntries: [
          for (final option in options)
            DropdownMenuEntry(value: option, label: name(option), leadingIcon: icon(option)),
        ],
        onSelected: (option) {
          if (option != null) onSelected(option);
        },
      ),
    };
  }
}

class _CatalogSheet<T extends Object> extends StatefulWidget {
  const _CatalogSheet({required this.label, required this.options, required this.name, required this.icon});

  final String label;
  final List<T> options;
  final String Function(T option) name;
  final Widget Function(T option) icon;

  @override
  State<_CatalogSheet<T>> createState() => _CatalogSheetState<T>();
}

class _CatalogSheetState<T extends Object> extends State<_CatalogSheet<T>> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final words = _query.trim().toLowerCase();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: 'Pretraga',
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (text) => setState(() => _query = text),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final option in widget.options)
                    if (widget.name(option).toLowerCase().contains(words))
                      ListTile(
                        leading: widget.icon(option),
                        title: Text(widget.name(option)),
                        onTap: () => Navigator.pop(context, option),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
