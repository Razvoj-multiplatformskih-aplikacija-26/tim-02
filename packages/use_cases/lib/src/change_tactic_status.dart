import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/tactic_repository.dart';

final class ChangeTacticStatus {
  const ChangeTacticStatus({required this.tactics, required this.clock});

  final TacticRepository tactics;
  final Clock clock;

  Future<Result<Tactic>> call({
    required TacticId id,
    required TacticAction action,
    required User by,
    HideReason? reason,
  }) async {
    final tactic = await tactics.find(id);
    if (tactic == null) return const Failure(NotFound());
    final now = clock.now();
    final result = switch ((action, reason)) {
      (TacticAction.archive, _) => archiveTactic(tactic, by: by, now: now),
      (TacticAction.publish, _) => publishTactic(tactic, by: by, now: now),
      (TacticAction.hide, final reason?) => hideTactic(tactic, by: by, reason: reason, now: now),
      (TacticAction.hide, null) => const Failure<Tactic>(HideReasonTooShort(0)),
      (TacticAction.restore, _) => restoreTactic(tactic, by: by, now: now),
    };
    return switch (result) {
      Failure(:final error) => Failure(error),
      Success(:final value) => Success(await tactics.save(value)),
    };
  }
}
