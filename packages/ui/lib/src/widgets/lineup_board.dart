import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'champion_hex.dart';
import 'item_icon.dart';

class UnitHex extends StatelessWidget {
  const UnitHex({super.key, required this.unit, this.size = 64});

  final Unit unit;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: size * 0.87,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ChampionHex(champion: unit.champion, size: size),
          if (unit.stars > 1)
            Positioned(
              top: -size * 0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  '★' * unit.stars,
                  semanticsLabel: '${unit.stars} zvezdice',
                  style: theme.textTheme.labelSmall?.copyWith(color: scheme.primary, height: 1.2),
                ),
              ),
            ),
          if (unit.items.isNotEmpty)
            Positioned(
              bottom: -size * 0.1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [for (final item in unit.items) ItemIcon(item: item, size: size * 0.28)],
              ),
            ),
        ],
      ),
    );
  }
}

class LineupBoard extends StatelessWidget {
  const LineupBoard({super.key, required this.lineup});

  final Lineup lineup;

  @override
  Widget build(BuildContext context) {
    final units = {for (final p in lineup.placements) (p.position.row, p.position.column): p.unit};
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / (HexPosition.columns + 0.5);
        final size = (width - 4) / 0.87;
        final step = width * 0.87;
        return SizedBox(
          height: step * (HexPosition.rows - 1) + size * 1.2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var row = HexPosition.rows - 1; row >= 0; row--)
                for (var column = 0; column < HexPosition.columns; column++)
                  Positioned(
                    left: (column + (row.isOdd ? 0.5 : 0)) * width,
                    top: row * step + size * 0.1,
                    child: switch (units[(row, column)]) {
                      null => EmptyHex(size: size),
                      final unit => UnitHex(unit: unit, size: size),
                    },
                  ),
            ],
          ),
        );
      },
    );
  }
}
