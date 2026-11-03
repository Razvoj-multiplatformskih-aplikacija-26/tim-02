import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../text/serbian.dart';
import 'champion_hex.dart';
import 'item_icon.dart';
import 'lineup_board.dart';
import 'status_badge.dart';

class TacticDetails extends StatelessWidget {
  const TacticDetails({
    super.key,
    required this.tactic,
    required this.tier,
    required this.variant,
    required this.early,
    required this.onVariantSelected,
    required this.onEarlySelected,
  });

  final Tactic tactic;
  final Tier? tier;
  final int variant;
  final bool early;
  final ValueChanged<int> onVariantSelected;
  final ValueChanged<bool> onEarlySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = tactic.status;
    final variants = tactic.variants;
    final selected = variants.isEmpty ? 0 : variant.clamp(0, variants.length - 1);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChampionHex(champion: tactic.carry, size: 88),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tactic.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    '${tactic.authorName} · izmenjeno ${formatDate(tactic.updatedAt)}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (status is! Published) StatusBadge(status: status),
                      if (tier case final tier?)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: scheme.outline),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tier == Tier.situational ? tier.label : 'Tier ${tier.label}',
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (status is Hidden) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sakrio administrator, ${formatDate(status.at)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(status.reason.text, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(tactic.description, style: theme.textTheme.bodyLarge),
        if (variants.isNotEmpty) ...[
          const SizedBox(height: 32),
          if (variants.length > 1) ...[
            Row(
              children: [
                Semantics(header: true, child: Text('VARIJANTE', style: theme.textTheme.headlineSmall)),
                const SizedBox(width: 12),
                Expanded(child: Divider(color: scheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (index, item) in variants.indexed)
                  ChoiceChip(
                    label: Text(item.name),
                    selected: index == selected,
                    onSelected: (_) => onVariantSelected(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _VariantView(
            variant: variants[selected],
            named: variants.length > 1,
            early: early,
            onEarlySelected: onEarlySelected,
          ),
        ],
      ],
    );
  }
}

class _VariantView extends StatelessWidget {
  const _VariantView({required this.variant, required this.named, required this.early, required this.onEarlySelected});

  final TacticVariant variant;
  final bool named;
  final bool early;
  final ValueChanged<bool> onEarlySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          [if (named) variant.name, variant.playstyle.label, variant.difficulty.label].join(' · '),
          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Rana igra')),
            ButtonSegment(value: false, label: Text('Kasna igra')),
          ],
          selected: {early},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onEarlySelected(selection.single),
        ),
        const SizedBox(height: 20),
        LineupBoard(lineup: early ? variant.early : variant.lineup, onUnitTap: (unit) => _showUnit(context, unit)),
        if (variant.flex.isNotEmpty)
          _Part(
            label: 'Fleksibilne jedinice',
            child: _Units(units: variant.flex),
          ),
        _Part(
          label: 'Prioritet predmeta',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in variant.itemPriority)
                ItemIcon(item: item, size: 36, triggerMode: TooltipTriggerMode.tap),
            ],
          ),
        ),
        _Part(
          label: 'Savet',
          child: Text(variant.tip, style: theme.textTheme.bodyMedium),
        ),
        for (final MapEntry(key: stage, value: tip) in variant.stageTips.entries)
          _Part(
            label: 'Faza $stage',
            child: Text(tip, style: theme.textTheme.bodyMedium),
          ),
      ],
    );
  }
}

class _Part extends StatelessWidget {
  const _Part({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Units extends StatelessWidget {
  const _Units({required this.units});

  final List<Unit> units;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 16,
      children: [
        for (final unit in units)
          InkWell(
            onTap: () => _showUnit(context, unit),
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              child: Column(
                children: [
                  UnitHex(unit: unit, size: 56),
                  const SizedBox(height: 10),
                  ExcludeSemantics(
                    child: Text(
                      unit.champion.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

void _showUnit(BuildContext context, Unit unit) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: UnitHex(unit: unit, size: 56),
            title: Text(unit.champion.name, style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text('${'★' * unit.stars} · jedinica od ${unit.champion.cost} zlatnika'),
          ),
          for (final item in unit.items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ItemIcon(item: item, size: 36),
              title: Text(item.name),
            ),
        ],
      ),
    ),
  );
}
