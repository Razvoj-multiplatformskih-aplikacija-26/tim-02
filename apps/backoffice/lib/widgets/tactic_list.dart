import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'revealed.dart';

class TacticList extends StatelessWidget {
  const TacticList({super.key, required this.tactics, required this.selectedId, required this.onSelect});

  final List<Tactic> tactics;
  final TacticId? selectedId;
  final ValueChanged<Tactic> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      itemCount: tactics.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tactic = tactics[index];
        final selected = tactic.id == selectedId;
        final tile = ListTile(
          leading: ChampionHex(champion: tactic.carry, size: 40),
          title: Text(tactic.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${tactic.authorName} · ${formatDate(tactic.updatedAt)}'),
          trailing: StatusBadge(status: tactic.status),
          selected: selected,
          selectedTileColor: scheme.surfaceContainerHigh,
          onTap: () => onSelect(tactic),
        );
        return selected ? Revealed(key: ValueKey(tactic.id), child: tile) : tile;
      },
    );
  }
}
