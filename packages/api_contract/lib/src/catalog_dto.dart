import 'json.dart';

final class ChampionDto {
  const ChampionDto({required this.id, required this.name, required this.cost});

  final String id;
  final String name;
  final int cost;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'cost': cost};

  factory ChampionDto.fromJson(Map<String, Object?> json) =>
      ChampionDto(id: jsonString(json, 'id'), name: jsonString(json, 'name'), cost: jsonInt(json, 'cost'));
}

final class ItemDto {
  const ItemDto({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'name': name};

  factory ItemDto.fromJson(Map<String, Object?> json) =>
      ItemDto(id: jsonString(json, 'id'), name: jsonString(json, 'name'));
}

final class CatalogDto {
  const CatalogDto({required this.champions, required this.items});

  final List<ChampionDto> champions;
  final List<ItemDto> items;

  Map<String, Object?> toJson() => {
    'champions': [for (final champion in champions) champion.toJson()],
    'items': [for (final item in items) item.toJson()],
  };

  factory CatalogDto.fromJson(Map<String, Object?> json) => CatalogDto(
    champions: [for (final champion in jsonObjects(json, 'champions')) ChampionDto.fromJson(champion)],
    items: [for (final item in jsonObjects(json, 'items')) ItemDto.fromJson(item)],
  );
}
