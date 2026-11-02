import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/lineup_repository.dart';

final class SaveLineup {
  const SaveLineup({required this.lineups, required this.clock});

  final LineupRepository lineups;
  final Clock clock;

  Future<PersonalLineup> call({required LineupName name, required Lineup lineup}) =>
      lineups.save(PersonalLineup(id: LineupId('l-${clock.now().microsecondsSinceEpoch}'), name: name, lineup: lineup));
}
