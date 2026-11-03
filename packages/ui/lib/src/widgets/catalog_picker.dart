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

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      label: Text(label),
      initialSelection: initial,
      enableFilter: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 320,
      dropdownMenuEntries: [
        for (final option in options) DropdownMenuEntry(value: option, label: name(option), leadingIcon: icon(option)),
      ],
      onSelected: (option) {
        if (option != null) onSelected(option);
      },
    );
  }
}
