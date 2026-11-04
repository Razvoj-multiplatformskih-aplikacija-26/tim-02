import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_lineups.dart';
import 'data/fake_tactics.dart';

final class AppDependencies {
  AppDependencies({
    required this.clock,
    required this.user,
    required TacticRepository tactics,
    required LineupRepository lineups,
    this.fakeTactics,
  }) : getTactics = GetTactics(tactics: tactics),
       getTierList = GetTierList(tactics: tactics),
       changeTacticStatus = ChangeTacticStatus(tactics: tactics, clock: clock),
       placeTactic = PlaceTactic(tactics: tactics),
       getLineups = GetLineups(lineups: lineups),
       getCatalog = GetCatalog(catalog: lineups),
       saveLineup = SaveLineup(lineups: lineups, clock: clock),
       deleteLineup = DeleteLineup(lineups: lineups);

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final tactics = latency == null ? FakeTactics(clock: clock) : FakeTactics(clock: clock, latency: latency);
    return AppDependencies(
      clock: clock,
      user: const User(id: UserId('u-marko'), name: 'Marko', role: Role.creator),
      tactics: tactics,
      lineups: latency == null ? FakeLineups() : FakeLineups(latency: latency),
      fakeTactics: tactics,
    );
  }

  final Clock clock;
  final User user;
  final GetTactics getTactics;
  final GetTierList getTierList;
  final ChangeTacticStatus changeTacticStatus;
  final PlaceTactic placeTactic;
  final GetLineups getLineups;
  final GetCatalog getCatalog;
  final SaveLineup saveLineup;
  final DeleteLineup deleteLineup;
  final FakeTactics? fakeTactics;
}
