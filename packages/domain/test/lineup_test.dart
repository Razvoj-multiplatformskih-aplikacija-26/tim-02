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
  });
}
