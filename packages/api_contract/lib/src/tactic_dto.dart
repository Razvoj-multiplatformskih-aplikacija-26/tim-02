import 'catalog_dto.dart';
import 'json.dart';

final class TacticStatusDto {
  const TacticStatusDto({required this.kind, this.at, this.reason, this.by});

  static const draft = 'draft';
  static const published = 'published';
  static const hidden = 'hidden';
  static const archived = 'archived';

  final String kind;
  final DateTime? at;
  final String? reason;
  final String? by;

  Map<String, Object?> toJson() => {
    'kind': kind,
    if (at case final at?) 'at': instantToJson(at),
    'reason': ?reason,
    'by': ?by,
  };

  factory TacticStatusDto.fromJson(Map<String, Object?> json) => TacticStatusDto(
    kind: jsonString(json, 'kind'),
    at: jsonOptionalInstant(json, 'at'),
    reason: jsonOptionalString(json, 'reason'),
    by: jsonOptionalString(json, 'by'),
  );
}

final class UnitDto {
  const UnitDto({required this.champion, required this.stars, required this.items});

  final ChampionDto champion;
  final int stars;
  final List<ItemDto> items;

  Map<String, Object?> toJson() => {
    'champion': champion.toJson(),
    'stars': stars,
    'items': [for (final item in items) item.toJson()],
  };

  factory UnitDto.fromJson(Map<String, Object?> json) => UnitDto(
    champion: ChampionDto.fromJson(jsonObject(json['champion'])),
    stars: jsonInt(json, 'stars'),
    items: [for (final item in jsonObjects(json, 'items')) ItemDto.fromJson(item)],
  );
}

final class PlacementDto {
  const PlacementDto({required this.row, required this.column, required this.unit});

  final int row;
  final int column;
  final UnitDto unit;

  Map<String, Object?> toJson() => {'row': row, 'column': column, 'unit': unit.toJson()};

  factory PlacementDto.fromJson(Map<String, Object?> json) => PlacementDto(
    row: jsonInt(json, 'row'),
    column: jsonInt(json, 'column'),
    unit: UnitDto.fromJson(jsonObject(json['unit'])),
  );
}

final class TacticVariantDto {
  const TacticVariantDto({
    required this.name,
    required this.playstyle,
    required this.difficulty,
    required this.early,
    required this.lineup,
    required this.flex,
    required this.itemPriority,
    required this.tip,
    required this.stageTips,
  });

  final String name;
  final String playstyle;
  final String difficulty;
  final List<PlacementDto> early;
  final List<PlacementDto> lineup;
  final List<UnitDto> flex;
  final List<ItemDto> itemPriority;
  final String tip;
  final Map<int, String> stageTips;

  Map<String, Object?> toJson() => {
    'name': name,
    'playstyle': playstyle,
    'difficulty': difficulty,
    'early': [for (final placement in early) placement.toJson()],
    'lineup': [for (final placement in lineup) placement.toJson()],
    'flex': [for (final unit in flex) unit.toJson()],
    'itemPriority': [for (final item in itemPriority) item.toJson()],
    'tip': tip,
    'stageTips': {for (final MapEntry(:key, :value) in stageTips.entries) '$key': value},
  };

  factory TacticVariantDto.fromJson(Map<String, Object?> json) => TacticVariantDto(
    name: jsonString(json, 'name'),
    playstyle: jsonString(json, 'playstyle'),
    difficulty: jsonString(json, 'difficulty'),
    early: [for (final placement in jsonObjects(json, 'early')) PlacementDto.fromJson(placement)],
    lineup: [for (final placement in jsonObjects(json, 'lineup')) PlacementDto.fromJson(placement)],
    flex: [for (final unit in jsonObjects(json, 'flex')) UnitDto.fromJson(unit)],
    itemPriority: [for (final item in jsonObjects(json, 'itemPriority')) ItemDto.fromJson(item)],
    tip: jsonString(json, 'tip'),
    stageTips: _stageTips(jsonObject(json['stageTips'])),
  );
}

Map<int, String> _stageTips(Map<String, Object?> json) => {
  for (final stage in json.keys)
    int.tryParse(stage) ?? (throw FormatException('Expected a stage number', stage)): jsonString(json, stage),
};

final class TacticDto {
  const TacticDto({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.carry,
    required this.status,
    required this.updatedAt,
    required this.variants,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final ChampionDto carry;
  final TacticStatusDto status;
  final DateTime updatedAt;
  final List<TacticVariantDto> variants;

  Map<String, Object?> toJson() => {
    'id': id,
    'authorId': authorId,
    'authorName': authorName,
    'title': title,
    'description': description,
    'carry': carry.toJson(),
    'status': status.toJson(),
    'updatedAt': instantToJson(updatedAt),
    'variants': [for (final variant in variants) variant.toJson()],
  };

  factory TacticDto.fromJson(Map<String, Object?> json) => TacticDto(
    id: jsonString(json, 'id'),
    authorId: jsonString(json, 'authorId'),
    authorName: jsonString(json, 'authorName'),
    title: jsonString(json, 'title'),
    description: jsonString(json, 'description'),
    carry: ChampionDto.fromJson(jsonObject(json['carry'])),
    status: TacticStatusDto.fromJson(jsonObject(json['status'])),
    updatedAt: jsonInstant(json, 'updatedAt'),
    variants: [for (final variant in jsonObjects(json, 'variants')) TacticVariantDto.fromJson(variant)],
  );
}
