import 'json.dart';

final class TierPlacementDto {
  const TierPlacementDto({required this.tacticId, required this.tier});

  final String tacticId;
  final String tier;

  Map<String, Object?> toJson() => {'tacticId': tacticId, 'tier': tier};

  factory TierPlacementDto.fromJson(Map<String, Object?> json) =>
      TierPlacementDto(tacticId: jsonString(json, 'tacticId'), tier: jsonString(json, 'tier'));
}

final class TierListDto {
  const TierListDto({required this.patch, required this.placements});

  final String patch;
  final List<TierPlacementDto> placements;

  Map<String, Object?> toJson() => {
    'patch': patch,
    'placements': [for (final placement in placements) placement.toJson()],
  };

  factory TierListDto.fromJson(Map<String, Object?> json) => TierListDto(
    patch: jsonString(json, 'patch'),
    placements: [for (final placement in jsonObjects(json, 'placements')) TierPlacementDto.fromJson(placement)],
  );
}

final class TierChangeDto {
  const TierChangeDto({required this.tier});

  final String? tier;

  Map<String, Object?> toJson() => {'tier': tier};

  factory TierChangeDto.fromJson(Map<String, Object?> json) => TierChangeDto(tier: jsonOptionalString(json, 'tier'));
}
