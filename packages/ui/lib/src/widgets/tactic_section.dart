import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'champion_tile.dart';
import 'tile_section.dart';

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
    return TileSection(
      label: label,
      columns: 3,
      highlighted: highlighted,
      children: [
        for (final tactic in tactics)
          ChampionTile(champion: tactic.carry, title: tactic.title, onOpen: () => onOpen(tactic)),
      ],
    );
  }
}
