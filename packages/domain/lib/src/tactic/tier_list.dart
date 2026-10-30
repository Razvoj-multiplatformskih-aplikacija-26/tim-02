import 'package:equatable/equatable.dart';

import '../identifiers.dart';
import 'tactic.dart';
import 'tactic_status.dart';

enum Tier { s, a, b, c, situational }

final class TierPlacement extends Equatable {
  const TierPlacement({required this.tactic, required this.tier});

  final TacticId tactic;
  final Tier tier;

  @override
  List<Object?> get props => [tactic, tier];
}

final class TierList extends Equatable {
  const TierList({required this.patch, required this.placements});

  final PatchId patch;
  final List<TierPlacement> placements;

  Tier? tierOf(TacticId tactic) => placements.where((p) => p.tactic == tactic).firstOrNull?.tier;

  Map<Tier, List<Tactic>> comps(Iterable<Tactic> tactics) {
    final published = {
      for (final tactic in tactics)
        if (tactic.status is Published) tactic.id: tactic,
    };
    return {
      for (final tier in Tier.values)
        tier: [
          for (final placement in placements)
            if (published[placement.tactic] case final tactic? when placement.tier == tier) tactic,
        ],
    };
  }

  @override
  List<Object?> get props => [patch, placements];
}
