import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/lineup_repository.dart';

final class SaveLineup {
  const SaveLineup({required this.lineups, required this.clock});

  final LineupRepository lineups;
  final Clock clock;

  Future<PersonalLineup> call({LineupId? id, required LineupName name, required Lineup lineup, TacticId? basedOn}) =>
      lineups.save(
        PersonalLineup(
          id: id ?? LineupId('l-${clock.now().microsecondsSinceEpoch}'),
          name: name,
          lineup: lineup,
          basedOn: basedOn,
        ),
      );
}
