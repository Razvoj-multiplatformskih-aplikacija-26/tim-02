import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'values.dart';

extension TierListMapping on TierList {
  TierListDto toDto() => TierListDto(
    patch: patch.value,
    placements: [
      for (final placement in placements) TierPlacementDto(tacticId: placement.tactic.value, tier: placement.tier.name),
    ],
  );
}

extension TierListDtoMapping on TierListDto {
  TierList toDomain() => TierList(
    patch: PatchId(patch),
    placements: [
      for (final placement in placements)
        TierPlacement(tactic: TacticId(placement.tacticId), tier: byName(Tier.values, placement.tier)),
    ],
  );
}
