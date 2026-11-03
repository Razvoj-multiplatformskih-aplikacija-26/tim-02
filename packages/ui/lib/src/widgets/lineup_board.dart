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
  const LineupBoard({super.key, required this.lineup, this.selected, this.onTap, this.onMove, this.onUnitTap});

  final Lineup lineup;
  final HexPosition? selected;
  final ValueChanged<HexPosition>? onTap;
  final void Function(HexPosition from, HexPosition to)? onMove;
  final ValueChanged<Unit>? onUnitTap;

  Widget _movable(BuildContext context, HexPosition position, Unit? unit, double size) {
    final hex = unit == null ? EmptyHex(size: size) : UnitHex(unit: unit, size: size);
    final onMove = this.onMove;
    if (onMove == null) return hex;
    final touch = switch (Theme.of(context).platform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
    final cell = switch ((unit, touch)) {
      (null, _) => hex,
      (_, true) => LongPressDraggable<HexPosition>(
        data: position,
        feedback: hex,
        childWhenDragging: EmptyHex(size: size),
        child: hex,
      ),
      (_, false) => Draggable<HexPosition>(
        data: position,
        feedback: hex,
        childWhenDragging: EmptyHex(size: size),
        child: hex,
      ),
    };
    return DragTarget<HexPosition>(
      onWillAcceptWithDetails: (details) => details.data != position,
      onAcceptWithDetails: (details) => onMove(details.data, position),
      builder: (context, candidates, rejected) => candidates.isEmpty
          ? cell
          : Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -3,
                  top: -3.5,
                  child: EmptyHex(size: size + 7, color: Theme.of(context).colorScheme.primary),
                ),
                cell,
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final units = {for (final p in lineup.placements) (p.position.row, p.position.column): p.unit};
    final selected = this.selected;
    final onTap = this.onTap;
    final onUnitTap = this.onUnitTap;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / (HexPosition.columns + 0.5);
        final size = (width - 4) / 0.87;
        final step = width * 0.87;
        double left(int row, int column) => (column + (row.isOdd ? 0.5 : 0)) * width;
        double top(int row) => row * step + size * 0.1;
        return SizedBox(
          height: step * (HexPosition.rows - 1) + size * 1.2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (selected != null)
                Positioned(
                  left: left(selected.row, selected.column) - 3,
                  top: top(selected.row) - 3.5,
                  child: EmptyHex(size: size + 7, color: Theme.of(context).colorScheme.onSurface),
                ),
              for (var row = HexPosition.rows - 1; row >= 0; row--)
                for (var column = 0; column < HexPosition.columns; column++)
                  Positioned(
                    left: left(row, column),
                    top: top(row),
                    child: switch ((units[(row, column)], onTap)) {
                      (final unit, final onTap?) => Semantics(
                        button: true,
                        selected: selected?.row == row && selected?.column == column,
                        label: 'Red ${row + 1}, kolona ${column + 1}',
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => onTap(HexPosition.parse(row, column).valueOrNull!),
                            child: _movable(context, HexPosition.parse(row, column).valueOrNull!, unit, size),
                          ),
                        ),
                      ),
                      (null, null) => EmptyHex(size: size),
                      (final unit?, null) when onUnitTap != null => Semantics(
                        button: true,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => onUnitTap(unit),
                            child: UnitHex(unit: unit, size: size),
                          ),
                        ),
                      ),
                      (final unit?, null) => UnitHex(unit: unit, size: size),
                    },
                  ),
            ],
          ),
        );
      },
    );
  }
}
