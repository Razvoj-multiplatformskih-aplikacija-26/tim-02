import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

extension ChampionMapping on Champion {
  ChampionDto toDto() => ChampionDto(id: id.value, name: name, cost: cost);
}

extension ChampionDtoMapping on ChampionDto {
  Champion toDomain() => Champion(id: ChampionId(id), name: name, cost: cost);
}

extension ItemMapping on Item {
  ItemDto toDto() => ItemDto(id: id.value, name: name);
}

extension ItemDtoMapping on ItemDto {
  Item toDomain() => Item(id: ItemId(id), name: name);
}

extension CatalogMapping on Catalog {
  CatalogDto toDto() => CatalogDto(
    champions: [for (final champion in champions) champion.toDto()],
    items: [for (final item in items) item.toDto()],
  );
}

extension CatalogDtoMapping on CatalogDto {
  Catalog toDomain() => Catalog(
    champions: [for (final champion in champions) champion.toDomain()],
    items: [for (final item in items) item.toDomain()],
  );
}
