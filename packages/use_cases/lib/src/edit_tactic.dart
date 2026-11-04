import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/tactic_repository.dart';

final class EditTactic {
  const EditTactic({required this.tactics, required this.clock});

  final TacticRepository tactics;
  final Clock clock;

  Future<Result<Tactic>> call({
    required TacticId id,
    required User by,
    required String title,
    required String description,
    required List<TacticVariant> variants,
  }) async {
    final tactic = await tactics.find(id);
    if (tactic == null) return const Failure(NotFound());
    return switch (editTactic(
      tactic,
      by: by,
      title: title,
      description: description,
      variants: variants,
      now: clock.now(),
    )) {
      Failure(:final error) => Failure(error),
      Success(:final value) => Success(await tactics.save(value)),
    };
  }
}
