import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'champion_hex.dart';

class TacticSection extends StatelessWidget {
  const TacticSection({
    super.key,
    required this.label,
    required this.tactics,
    required this.onOpen,
    this.highlighted = false,
  });

  final String label;
  final List<Tactic> tactics;
  final ValueChanged<Tactic> onOpen;
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
              final width = ((constraints.maxWidth - 24) / 3).floorToDouble();
              return Wrap(
                spacing: 12,
                runSpacing: 20,
                children: [
                  for (final tactic in tactics)
                    SizedBox(
                      width: width,
                      child: _TacticTile(tactic: tactic, onOpen: () => onOpen(tactic)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TacticTile extends StatelessWidget {
  const _TacticTile({required this.tactic, required this.onOpen});

  final Tactic tactic;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            ChampionHex(champion: tactic.carry, size: 76),
            const SizedBox(height: 8),
            Text(
              tactic.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
