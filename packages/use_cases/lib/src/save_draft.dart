import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/tactic_repository.dart';

final class SaveDraft {
  const SaveDraft({required this.tactics, required this.clock});

  final TacticRepository tactics;
  final Clock clock;

  Future<Result<Tactic>> call({
    TacticId? id,
    required User by,
    required String title,
    required List<TacticVariant> variants,
  }) async {
    final now = clock.now();
    final draft = id == null ? null : await tactics.find(id);
    final result = draft == null
        ? draftTactic(
            id: TacticId('t-${now.microsecondsSinceEpoch}'),
            by: by,
            title: title,
            variants: variants,
            now: now,
          )
        : editTactic(draft, by: by, title: title, description: draft.description, variants: variants, now: now);
    return switch (result) {
      Failure(:final error) => Failure(error),
      Success(:final value) => Success(await tactics.save(value)),
    };
  }
}
