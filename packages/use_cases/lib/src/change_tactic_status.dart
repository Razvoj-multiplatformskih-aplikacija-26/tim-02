import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/tactic_repository.dart';

final class ChangeTacticStatus {
  const ChangeTacticStatus({required this.tactics, required this.clock});

  final TacticRepository tactics;
  final Clock clock;

  Future<Result<Tactic>> call({required TacticId id, required TacticAction action, required User by}) async {
    final tactic = await tactics.find(id);
    if (tactic == null) return const Failure(NotFound());
    final result = switch (action) {
      TacticAction.archive => archiveTactic(tactic, by: by, now: clock.now()),
    };
    return switch (result) {
      Failure(:final error) => Failure(error),
      Success(:final value) => Success(await tactics.save(value)),
    };
  }
}
