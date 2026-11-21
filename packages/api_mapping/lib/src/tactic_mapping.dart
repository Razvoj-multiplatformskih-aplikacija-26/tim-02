import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'catalog_mapping.dart';
import 'values.dart';

extension TacticStatusMapping on TacticStatus {
  TacticStatusDto toDto() => switch (this) {
    Draft() => const TacticStatusDto(kind: TacticStatusDto.draft),
    Published(:final at) => TacticStatusDto(kind: TacticStatusDto.published, at: at),
    Hidden(:final reason, :final by, :final at) => TacticStatusDto(
      kind: TacticStatusDto.hidden,
      at: at,
      reason: reason.text,
      by: by.value,
    ),
    Archived(:final at) => TacticStatusDto(kind: TacticStatusDto.archived, at: at),
  };
}

extension TacticStatusDtoMapping on TacticStatusDto {
  TacticStatus toDomain() => switch (this) {
    TacticStatusDto(kind: TacticStatusDto.draft) => const Draft(),
    TacticStatusDto(kind: TacticStatusDto.published, :final at?) => Published(at: at),
    TacticStatusDto(kind: TacticStatusDto.hidden, :final at?, :final reason?, :final by?) => Hidden(
      reason: accepted(HideReason.parse(reason)),
      by: UserId(by),
      at: at,
    ),
    TacticStatusDto(kind: TacticStatusDto.archived, :final at?) => Archived(at: at),
    _ => throw FormatException('Unknown tactic status', kind),
  };
}

extension UnitMapping on Unit {
  UnitDto toDto() => UnitDto(champion: champion.toDto(), stars: stars, items: [for (final item in items) item.toDto()]);
}

extension UnitDtoMapping on UnitDto {
  Result<Unit> toDomain() =>
      Unit.parse(champion.toDomain(), stars: stars, items: [for (final item in items) item.toDomain()]);
}

extension LineupMapping on Lineup {
  List<PlacementDto> toDto() => [
    for (final placement in placements)
      PlacementDto(row: placement.position.row, column: placement.position.column, unit: placement.unit.toDto()),
  ];
}

extension LineupDtoMapping on List<PlacementDto> {
  Result<Lineup> toLineup() {
    var lineup = const Lineup.empty();
    for (final placement in this) {
      final placed = switch ((HexPosition.parse(placement.row, placement.column), placement.unit.toDomain())) {
        (Success(value: final position), Success(value: final unit)) => lineup.place(
          Placement(unit: unit, position: position),
        ),
        (Failure(:final error), _) || (_, Failure(:final error)) => Failure<Lineup>(error),
      };
      if (placed case Failure(:final error)) return Failure(error);
      lineup = placed.valueOrNull!;
    }
    return Success(lineup);
  }
}

extension TacticVariantMapping on TacticVariant {
  TacticVariantDto toDto() => TacticVariantDto(
    name: name,
    playstyle: playstyle.name,
    difficulty: difficulty.name,
    early: early.toDto(),
    lineup: lineup.toDto(),
    flex: [for (final unit in flex) unit.toDto()],
    itemPriority: [for (final item in itemPriority) item.toDto()],
    tip: tip,
    stageTips: stageTips,
  );
}

extension TacticVariantDtoMapping on TacticVariantDto {
  Result<TacticVariant> toDomain() {
    final boards = (early.toLineup(), lineup.toLineup());
    final flexUnits = [for (final unit in flex) unit.toDomain()];
    if (boards case (Failure(:final error), _) || (_, Failure(:final error))) return Failure(error);
    if (flexUnits.map((unit) => unit.errorOrNull).nonNulls.firstOrNull case final error?) return Failure(error);
    return Success(
      TacticVariant(
        name: name,
        playstyle: byName(Playstyle.values, playstyle),
        difficulty: byName(Difficulty.values, difficulty),
        early: boards.$1.valueOrNull!,
        lineup: boards.$2.valueOrNull!,
        flex: [for (final unit in flexUnits) unit.valueOrNull!],
        itemPriority: [for (final item in itemPriority) item.toDomain()],
        tip: tip,
        stageTips: stageTips,
      ),
    );
  }
}

extension TacticMapping on Tactic {
  TacticDto toDto() => TacticDto(
    id: id.value,
    authorId: authorId.value,
    authorName: authorName,
    title: title,
    description: description,
    carry: carry.toDto(),
    status: status.toDto(),
    updatedAt: updatedAt,
    variants: [for (final variant in variants) variant.toDto()],
  );
}

extension TacticDtoMapping on TacticDto {
  Tactic toDomain() => Tactic(
    id: TacticId(id),
    authorId: UserId(authorId),
    authorName: authorName,
    title: title,
    description: description,
    carry: carry.toDomain(),
    status: status.toDomain(),
    updatedAt: updatedAt,
    variants: [for (final variant in variants) accepted(variant.toDomain())],
  );
}
