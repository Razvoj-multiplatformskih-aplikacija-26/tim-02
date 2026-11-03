import 'package:equatable/equatable.dart';

import '../catalog.dart';
import '../errors.dart';
import '../result.dart';

final class HexPosition extends Equatable {
  const HexPosition._(this.row, this.column);

  static const rows = 4;
  static const columns = 7;

  final int row;
  final int column;

  static Result<HexPosition> parse(int row, int column) {
    if (row < 0 || row >= rows || column < 0 || column >= columns) return const Failure(InvalidPosition());
    return Success(HexPosition._(row, column));
  }

  @override
  List<Object?> get props => [row, column];
}

final class Unit extends Equatable {
  const Unit._(this.champion, this.stars, this.items);

  static const maxItems = 3;

  final Champion champion;
  final int stars;
  final List<Item> items;

  static Result<Unit> parse(Champion champion, {int stars = 1, List<Item> items = const []}) {
    if (items.length > maxItems) return Failure(TooManyItems(items.length));
    return Success(Unit._(champion, stars, List.unmodifiable(items)));
  }

  @override
  List<Object?> get props => [champion, stars, items];
}

final class Placement extends Equatable {
  const Placement({required this.unit, required this.position});

  final Unit unit;
  final HexPosition position;

  @override
  List<Object?> get props => [unit, position];
}

final class Lineup extends Equatable {
  const Lineup.empty() : placements = const [];

  const Lineup._(this.placements);

  final List<Placement> placements;

  Result<Lineup> place(Placement placement) {
    if (placements.any((p) => p.position == placement.position)) return Failure(HexOccupied(placement.position));
    return Success(Lineup._([...placements, placement]));
  }

  Lineup remove(HexPosition position) => Lineup._([
    for (final placement in placements)
      if (placement.position != position) placement,
  ]);

  Lineup move(HexPosition from, HexPosition to) => Lineup._([
    for (final placement in placements)
      if (placement.position == from)
        Placement(unit: placement.unit, position: to)
      else if (placement.position == to)
        Placement(unit: placement.unit, position: from)
      else
        placement,
  ]);

  Champion? get carry => placements.fold<Placement?>(null, _carryOf)?.unit.champion;

  static Placement _carryOf(Placement? carry, Placement next) {
    if (carry == null) return next;
    final order = [
      next.unit.items.length.compareTo(carry.unit.items.length),
      next.position.row.compareTo(carry.position.row),
      next.unit.champion.cost.compareTo(carry.unit.champion.cost),
    ].firstWhere((order) => order != 0, orElse: () => 0);
    return order >= 0 ? next : carry;
  }

  @override
  List<Object?> get props => [placements];
}
