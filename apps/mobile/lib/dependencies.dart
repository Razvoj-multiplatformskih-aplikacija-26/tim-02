import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_tactics.dart';

final class AppDependencies {
  AppDependencies({required this.clock, required this.user, required TacticRepository tactics, this.fakeTactics})
    : getTactics = GetTactics(tactics: tactics),
      getTierList = GetTierList(tactics: tactics),
      changeTacticStatus = ChangeTacticStatus(tactics: tactics, clock: clock);

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final tactics = latency == null ? FakeTactics(clock: clock) : FakeTactics(clock: clock, latency: latency);
    return AppDependencies(
      clock: clock,
      user: const User(id: UserId('u-marko'), name: 'Marko', role: Role.creator),
      tactics: tactics,
      fakeTactics: tactics,
    );
  }

  final Clock clock;
  final User user;
  final GetTactics getTactics;
  final GetTierList getTierList;
  final ChangeTacticStatus changeTacticStatus;
  final FakeTactics? fakeTactics;
}
