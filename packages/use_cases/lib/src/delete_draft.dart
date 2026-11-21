import 'package:domain/domain.dart';

import 'ports/tactic_repository.dart';

final class DeleteDraft {
  const DeleteDraft({required this.tactics});

  final TacticRepository tactics;

  Future<Result<TacticId>> call(TacticId id, {required User by}) async {
    final draft = await tactics.find(id);
    if (draft == null) return const Failure(NotFound());
    return switch (deleteDraft(draft, by: by)) {
      Failure(:final error) => Failure(error),
      Success() => await tactics.delete(id),
    };
  }
}
