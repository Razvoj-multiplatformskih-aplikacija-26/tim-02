import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class TacticTable extends StatelessWidget {
  const TacticTable({super.key, required this.tactics});

  final List<Tactic> tactics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle.merge(
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          child: const _TableRow(cells: [Text('Naslov'), Text('Autor'), Text('Stanje'), Text('Izmenjeno')]),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: tactics.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tactic = tactics[index];
              return _TableRow(
                cells: [
                  Row(
                    spacing: 12,
                    children: [
                      ChampionHex(champion: tactic.carry, size: 36),
                      Expanded(
                        child: Text(
                          tactic.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  Text(tactic.authorName),
                  StatusBadge(status: tactic.status),
                  Text(formatDate(tactic.updatedAt)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.cells});

  static const _flex = [5, 2, 2, 2];

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        spacing: 16,
        children: [
          for (final (index, cell) in cells.indexed)
            Expanded(
              flex: _flex[index],
              child: Align(alignment: AlignmentDirectional.centerStart, child: cell),
            ),
        ],
      ),
    );
  }
}
