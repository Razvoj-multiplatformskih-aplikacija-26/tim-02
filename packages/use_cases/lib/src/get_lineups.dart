import 'package:domain/domain.dart';

import 'ports/lineup_repository.dart';

final class GetLineups {
  const GetLineups({required this.lineups});

  final LineupRepository lineups;

  Future<List<PersonalLineup>> call() => lineups.all();
}
