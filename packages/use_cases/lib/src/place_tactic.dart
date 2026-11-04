import 'package:domain/domain.dart';

import 'ports/tactic_repository.dart';

final class PlaceTactic {
  const PlaceTactic({required this.tactics});

  final TacticRepository tactics;

  Future<Result<TierList>> call({required TacticId id, required Tier? tier, required User by}) async {
    final tactic = await tactics.find(id);
    if (tactic == null) return const Failure(NotFound());
    return switch (placeTactic(await tactics.currentTierList(), tactic, tier: tier, by: by)) {
      Failure(:final error) => Failure(error),
      Success(:final value) => Success(await tactics.saveTierList(value)),
    };
  }
}
