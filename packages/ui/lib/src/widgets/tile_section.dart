import 'package:flutter/material.dart';

class TileSection extends StatelessWidget {
  const TileSection({
    super.key,
    required this.label,
    required this.columns,
    required this.children,
    this.highlighted = false,
  });

  final String label;
  final int columns;
  final List<Widget> children;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Semantics(
                header: true,
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: highlighted ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: scheme.outlineVariant)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = ((constraints.maxWidth - 12 * (columns - 1)) / columns).floorToDouble();
              return Wrap(
                spacing: 12,
                runSpacing: 20,
                children: [for (final child in children) SizedBox(width: width, child: child)],
              );
            },
          ),
        ],
      ),
    );
  }
}
