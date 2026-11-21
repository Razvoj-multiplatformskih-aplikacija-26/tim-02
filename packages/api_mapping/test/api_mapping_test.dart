import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:demo_data/demo_data.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';

Map<String, Object?> throughJson(Map<String, Object?> json) => jsonDecode(jsonEncode(json)) as Map<String, Object?>;

PlacementDto at(int row, int column, {List<Item> items = const []}) => PlacementDto(
  row: row,
  column: column,
  unit: UnitDto(champion: ahri.toDto(), stars: 2, items: [for (final item in items) item.toDto()]),
);

void main() {
  test('carries every seeded tactic to the contract and back', () {
    for (final tactic in seedTactics(DateTime.utc(2026, 11, 21))) {
      expect(TacticDto.fromJson(throughJson(tactic.toDto().toJson())).toDomain(), tactic, reason: tactic.title);
    }
  });

  test('carries the tier list and the catalog to the contract and back', () {
    expect(TierListDto.fromJson(throughJson(seedTierList.toDto().toJson())).toDomain(), seedTierList);
    expect(CatalogDto.fromJson(throughJson(seedCatalog.toDto().toJson())).toDomain(), seedCatalog);
  });

  test('carries every seeded user to the contract and back', () {
    for (final user in seedUsers) {
      expect(UserDto.fromJson(throughJson(user.toDto().toJson())).toDomain(), user);
    }
  });

  test('builds a board only through the rules of the domain', () {
    final items = [bfSword, bfSword, bfSword, bloodthirster];

    expect([at(3, 3, items: items)].toLineup(), const Failure<Lineup>(TooManyItems(4, max: 3)));
    expect([at(3, 3), at(3, 3)].toLineup(), Failure<Lineup>(HexOccupied(HexPosition.parse(3, 3).valueOrNull!)));
    expect([at(4, 0)].toLineup(), const Failure<Lineup>(InvalidPosition()));
    expect([at(3, 3), at(3, 4)].toLineup().valueOrNull?.placements, hasLength(2));
  });

  test('carries every domain error through a problem and back', () {
    final errors = <DomainError>[
      const HideReasonTooShort(4, min: 10),
      const InvalidPosition(),
      const TooManyItems(4, max: 3),
      HexOccupied(HexPosition.parse(2, 5).valueOrNull!),
      const InvalidTacticTitle(61, max: 60),
      const TacticArchived(),
      const EmptyBoard(),
      const NotPlaceable(),
      const NotAllowed(),
      const HiddenByAdmin(),
      const TierFull(Tier.s, max: 2),
      InvalidTransition(
        from: Archived(at: DateTime.utc(2026, 11, 20)),
        to: Published(at: DateTime.utc(2026, 11, 21)),
      ),
      const NotFound(),
    ];

    for (final error in errors) {
      expect(ProblemDto.fromJson(throughJson(error.toProblem().toJson())).toDomainError(), error);
    }
  });

  test('knows no domain error for a code it has not seen', () {
    const problem = ProblemDto(status: 409, code: 'patch-closed', title: 'Patch closed');

    expect(problem.toDomainError(), isNull);
  });
}
