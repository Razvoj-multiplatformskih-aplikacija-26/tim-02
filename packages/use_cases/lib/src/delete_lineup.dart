import 'package:domain/domain.dart';

import 'ports/lineup_repository.dart';

final class DeleteLineup {
  const DeleteLineup({required this.lineups});

  final LineupRepository lineups;

  Future<void> call(LineupId id) => lineups.delete(id);
}
