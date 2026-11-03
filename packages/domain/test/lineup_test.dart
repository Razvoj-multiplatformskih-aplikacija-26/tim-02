import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  const ahri = Champion(id: ChampionId('ahri'), name: 'Ahri', cost: 4);
  const zyra = Champion(id: ChampionId('zyra'), name: 'Zyra', cost: 4);
  const items = [
    Item(id: ItemId('shojin'), name: 'Spear of Shojin'),
    Item(id: ItemId('gauntlet'), name: 'Jeweled Gauntlet'),
    Item(id: ItemId('flail'), name: "Striker's Flail"),
    Item(id: ItemId('deathcap'), name: "Rabadon's Deathcap"),
  ];
  final corner = HexPosition.parse(3, 0).valueOrNull!;

  group('HexPosition', () {
    test('accepts the last hex of the 4×7 board', () {
      expect(HexPosition.parse(3, 6).isSuccess, isTrue);
    });

    test('rejects a fifth row', () {
      expect(HexPosition.parse(4, 0), const Failure<HexPosition>(InvalidPosition()));
    });
  });

  group('Unit', () {
    test('accepts three items on a champion', () {
      expect(Unit.parse(ahri, items: items.take(3).toList()).valueOrNull?.items, hasLength(3));
    });

    test('rejects a fourth item', () {
      expect(Unit.parse(ahri, items: items), const Failure<Unit>(TooManyItems(4)));
    });
  });

  group('Lineup', () {
    test('rejects a second champion on a taken hex', () {
      final lineup = const Lineup.empty()
          .place(Placement(unit: Unit.parse(ahri).valueOrNull!, position: corner))
          .valueOrNull!;
      expect(
        lineup.place(Placement(unit: Unit.parse(zyra).valueOrNull!, position: corner)),
        Failure<Lineup>(HexOccupied(corner)),
      );
    });

    test('frees a hex when its champion is removed', () {
      final lineup = const Lineup.empty()
          .place(Placement(unit: Unit.parse(ahri).valueOrNull!, position: corner))
          .valueOrNull!
          .remove(corner);
      expect(lineup.place(Placement(unit: Unit.parse(zyra).valueOrNull!, position: corner)).isSuccess, isTrue);
    });

    test('moves a champion to an empty hex and swaps two champions', () {
      final front = HexPosition.parse(0, 3).valueOrNull!;
      final side = HexPosition.parse(0, 6).valueOrNull!;
      final lineup = const Lineup.empty()
          .place(Placement(unit: Unit.parse(ahri).valueOrNull!, position: corner))
          .valueOrNull!
          .place(Placement(unit: Unit.parse(zyra).valueOrNull!, position: front))
          .valueOrNull!;
      String at(Lineup lineup, HexPosition position) =>
          lineup.placements.singleWhere((p) => p.position == position).unit.champion.name;

      final moved = lineup.move(corner, side);
      expect(moved.placements.map((p) => p.position), unorderedEquals([side, front]));
      expect(at(moved, side), 'Ahri');

      final swapped = lineup.move(corner, front);
      expect(at(swapped, front), 'Ahri');
      expect(at(swapped, corner), 'Zyra');
    });

    test('takes the champion with the most items, then the one furthest back, as its carry', () {
      final front = HexPosition.parse(0, 0).valueOrNull!;
      Lineup board({required int frontItems, required int backItems}) {
        final zyraInFront = Unit.parse(zyra, items: items.take(frontItems).toList()).valueOrNull!;
        final ahriInBack = Unit.parse(ahri, items: items.take(backItems).toList()).valueOrNull!;
        final first = const Lineup.empty().place(Placement(unit: zyraInFront, position: front)).valueOrNull!;
        return first.place(Placement(unit: ahriInBack, position: corner)).valueOrNull!;
      }

      expect(board(frontItems: 3, backItems: 1).carry, zyra);
      expect(board(frontItems: 3, backItems: 3).carry, ahri);
      expect(const Lineup.empty().carry, isNull);
    });
  });
}
